function setinteractorstyle(interactor, cam)
{
    if (cam=="2D")
        interactor.setInteractorStyle(vtk.Interaction.Style.vtkInteractorStyleImage.newInstance());
    else
        interactor.setInteractorStyle(vtk.Interaction.Style.vtkInteractorStyleTrackballCamera.newInstance());
}


function vtkupdate(uuid,jsdict,invalidation)
{
    var points=jsdict["xpoints"]
    var dataset=window.dataset
    dataset.getPoints().setData(points, 3);
    dataset.modified()
    renderWindow.render();
}

function vtkplot(uuid,jsdict,invalidation)
{
    window.renderWindow = vtk.Rendering.Core.vtkRenderWindow.newInstance();
    var renderWindow=window.renderWindow
    var renderer = vtk.Rendering.Core.vtkRenderer.newInstance();

    // OpenGlRenderWindow
    var openGlRenderWindow = vtk.Rendering.OpenGL.vtkRenderWindow.newInstance();
    renderWindow.addView(openGlRenderWindow);
    renderer.setBackground(1,1,1)

    // Interactor
    var interactor = vtk.Rendering.Core.vtkRenderWindowInteractor.newInstance();
    interactor.setView(openGlRenderWindow);
    interactor.initialize();

    interactor.setInteractorStyle(vtk.Interaction.Style.vtkInteractorStyleTrackballCamera.newInstance());

    //ensure to plot to the right place
    var rootContainer = document.getElementById(uuid);
    openGlRenderWindow.setContainer(rootContainer);
    const dims = rootContainer.getBoundingClientRect();	
    openGlRenderWindow.setSize(dims.width, dims.height);
    interactor.bindEvents(rootContainer);
    renderWindow.addRenderer(renderer)

    // Loop over content of jsdict
    var cmdcount=jsdict.cmdcount
    for (var icmd = 1 ; icmd <= cmdcount ; icmd++)
    {  
        var cmd=icmd.toString() 
        if (jsdict[cmd]=="triplot")
        {
    	    var points=jsdict[cmd+"_points"]
 	    var polys=jsdict[cmd+"_polys"]
 	    var cam=jsdict[cmd+"_cam"]

            // Loop over content of jsdict
            window.actor = vtk.Rendering.Core.vtkActor.newInstance();
            var mapper = vtk.Rendering.Core.vtkMapper.newInstance();
            
            // Apply transformation to the points coordinates // figure this out later
            //    vtkMatrixBuilder
            ///      .buildFromRadian()
            ///      .translate(...model.center)
            ///      .rotateFromDirections([1, 0, 0], model.direction)
            ///      .apply(points);
            
            window.dataset = vtk.Common.DataModel.vtkPolyData.newInstance();
            window.dataset.getPoints().setData(points, 3);
            window.dataset.getPolys().setData(polys,1);
            mapper.setInputData(window.dataset);
            window.actor.setMapper(mapper);
            renderer.addActor(window.actor);
            setinteractorstyle(interactor,cam)
        }
        else if (jsdict[cmd]=="plot")
        {
    	    var points=jsdict[cmd+"_points"]
 	    var lines=jsdict[cmd+"_lines"]

            window.actor = vtk.Rendering.Core.vtkActor.newInstance();
            var mapper = vtk.Rendering.Core.vtkMapper.newInstance();

            var dataset=vtk.Common.DataModel.vtkPolyData.newInstance();
            dataset.getPoints().setData(points, 3);
            dataset.getLines().setData(lines);
            mapper.setInputData(dataset);
            window.actor.setMapper(mapper);
            window.actor.getProperty().setColor(0, 0, 0)
            renderer.addActor(window.actor);
            setinteractorstyle(interactor,cam)
        }
        else if (jsdict[cmd]=="tricolor")
        {

            // for line see https://discourse.vtk.org/t/manually-create-polydata-in-vtk-js/885/15
    	    var points=jsdict[cmd+"_points"]
 	    var polys=jsdict[cmd+"_polys"]

    	    var isopoints=jsdict[cmd+"_isopoints"]
 	    var isolines=jsdict[cmd+"_isolines"]


            var colors=jsdict[cmd+"_colors"]
 	    var cam=jsdict[cmd+"_cam"]

            window.actor = vtk.Rendering.Core.vtkActor.newInstance();
            var mapper = vtk.Rendering.Core.vtkMapper.newInstance();
            
            
            var  dataset = vtk.Common.DataModel.vtkPolyData.newInstance();
            dataset.getPoints().setData(points, 3);
            dataset.getPolys().setData(polys,1);
            var colorData = vtk.Common.Core.vtkDataArray.newInstance({
                name: 'Colors',
                values: colors,
                numberOfComponents: 3,
            });

            
            dataset.getPointData().setScalars(colorData);        
            dataset.getPointData().setActiveScalars('Colors');

            mapper.setInputData(dataset);
            mapper.setColorModeToDirectScalars()
            window.actor.setMapper(mapper);
            renderer.addActor(window.actor);
            
            //https://discourse.vtk.org/t/manually-create-polydata-in-vtk-js/885/4
            var isodataset=vtk.Common.DataModel.vtkPolyData.newInstance();
            isodataset.getPoints().setData(isopoints, 3);
            isodataset.getLines().setData(isolines);

            var isomapper = vtk.Rendering.Core.vtkMapper.newInstance();
            var isoactor = vtk.Rendering.Core.vtkActor.newInstance();
            isomapper.setInputData(isodataset);
            isoactor.setMapper(isomapper);
            isoactor.getProperty().setColor(0, 0, 0)
            renderer.addActor(isoactor);
            
            setinteractorstyle(interactor,cam)
        }
        else if (jsdict[cmd]=="axis3d")
        {
 	    var cam=jsdict[cmd+"_cam"]
            var cubeAxes = vtk.Rendering.Core.vtkCubeAxesActor.newInstance();

            var  camera=renderer.getActiveCamera()
	    cubeAxes.setCamera(camera);
            cubeAxes.setAxisLabels(['x','y','z'])
//	    cubeAxes.setDataBounds(jsdict[cmd+"_bounds"]);
	    cubeAxes.setDataBounds(window.actor.getBounds());

            cubeAxes.setTickTextStyle({fontColor: "black"})
            cubeAxes.setTickTextStyle({fontFamily: "Arial"})
            cubeAxes.setTickTextStyle({fontSize: "10"})

            cubeAxes.setAxisTextStyle({fontColor: "black"})
            cubeAxes.setAxisTextStyle({fontFamily: "Arial"})
            cubeAxes.setAxisTextStyle({fontSize: "12"})

            cubeAxes.getProperty().setColor(0,0,0);
	    renderer.addActor(cubeAxes);
            renderWindow.render();

            if (cam=="2D")
                cubeAxes.setGridLines(false)

            setinteractorstyle(interactor,cam)
        }
    }
    
    //renderer.setLayer(0);
    renderer.resetCamera();
    
    renderWindow.render();

    // The invalidation promise is resolved when the cell starts rendering a newer output. We use it to release the WebGL context. (More info at https://plutocon2021-demos.netlify.app/fonsp%20%E2%80%94%20javascript%20inside%20pluto or https://observablehq.com/@observablehq/invalidation )
    invalidation.then(() => {
        renderWindow.delete();
        openGlRenderWindow.delete();
        interactor.delete();
    });
}

    
