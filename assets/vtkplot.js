function setinteractorstyle(interactor, cam)
{
    if (cam=="2D")
        interactor.setInteractorStyle(vtk.Interaction.Style.vtkInteractorStyleImage.newInstance());
    else
        interactor.setInteractorStyle(vtk.Interaction.Style.vtkInteractorStyleTrackballCamera.newInstance());
}


function vtkupdate(uuid,jsdict,invalidation)
{
    var win=window[uuid+"data"]
    var points=jsdict["xpoints"]
    var dataset=win.dataset
    dataset.getPoints().setData(points, 3);
    dataset.modified()
    win.renderWindow.render();
}

function vtkplot(uuid,jsdict,invalidation)
{
    if (window[uuid+"data"]==undefined)
    {
        window[uuid+"data"]={}
        var win=window[uuid+"data"]
        win.renderWindow = vtk.Rendering.Core.vtkRenderWindow.newInstance();
        win.renderer = vtk.Rendering.Core.vtkRenderer.newInstance();

        // OpenGlRenderWindow
        win.openGlRenderWindow = vtk.Rendering.OpenGL.vtkRenderWindow.newInstance();
        win.renderWindow.addView(win.openGlRenderWindow);
        win.renderer.setBackground(1,1,1)

        // Interactor
        win.interactor = vtk.Rendering.Core.vtkRenderWindowInteractor.newInstance();
        win.interactor.setView(win.openGlRenderWindow);
        win.interactor.initialize();

        win.interactor.setInteractorStyle(vtk.Interaction.Style.vtkInteractorStyleTrackballCamera.newInstance());

        //ensure to plot to the right place
        var rootContainer = document.getElementById(uuid);
        win.openGlRenderWindow.setContainer(rootContainer);
        const dims = rootContainer.getBoundingClientRect();	
        win.openGlRenderWindow.setSize(dims.width, dims.height);
        win.interactor.bindEvents(rootContainer);
        win.renderWindow.addRenderer(win.renderer)
        
    }
    
    // Loop over content of jsdict
    for (var cmd = 1 ; cmd <= jsdict.cmdcount ; cmd++)
    {  
        if (jsdict[cmd]=="tricontour")
        {
            var win=window[uuid+"data"]
            // for line see https://discourse.vtk.org/t/manually-create-polydata-in-vtk-js/885/15
    	    var points=jsdict[cmd+"points"]
 	    var polys=jsdict[cmd+"polys"]

            var colors=jsdict[cmd+"colors"]
            win.actor = vtk.Rendering.Core.vtkActor.newInstance();
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
            win.actor.setMapper(mapper);
            win.renderer.addActor(win.actor);
            
            var isopoints=jsdict[cmd+"isopoints"]
 	    var isolines=jsdict[cmd+"isolines"]
            if (isopoints != "none")
            {
                //https://discourse.vtk.org/t/manually-create-polydata-in-vtk-js/885/4
                var isodataset=vtk.Common.DataModel.vtkPolyData.newInstance();
                isodataset.getPoints().setData(isopoints, 3);
                isodataset.getLines().setData(isolines);
                
                var isomapper = vtk.Rendering.Core.vtkMapper.newInstance();
                var isoactor = vtk.Rendering.Core.vtkActor.newInstance();
                isomapper.setInputData(isodataset);
                isoactor.setMapper(isomapper);
                isoactor.getProperty().setColor(0, 0, 0)
                win.renderer.addActor(isoactor);
            }
        }
        else if (jsdict[cmd]=="axis")
        {
            var win=window[uuid+"data"]
 	    var cam=jsdict[cmd+"cam"]
            var cubeAxes = vtk.Rendering.Core.vtkCubeAxesActor.newInstance();
            var camera=win.renderer.getActiveCamera()
	    cubeAxes.setCamera(camera);
            cubeAxes.setAxisLabels(['x','y','z'])
	    cubeAxes.setDataBounds(win.actor.getBounds());

            cubeAxes.setTickTextStyle({fontColor: "black"})
            cubeAxes.setTickTextStyle({fontFamily: "Arial"})
            cubeAxes.setTickTextStyle({fontSize: "10"})

            cubeAxes.setAxisTextStyle({fontColor: "black"})
            cubeAxes.setAxisTextStyle({fontFamily: "Arial"})
            cubeAxes.setAxisTextStyle({fontSize: "12"})

            cubeAxes.getProperty().setColor(0,0,0);
	    win.renderer.addActor(cubeAxes);
            win.renderer.resetCamera();
            win.renderWindow.render();

            if (cam=="2D")
                cubeAxes.setGridLines(false)
            setinteractorstyle(win.interactor,cam)
        }
        else if (jsdict[cmd]=="triplot")
        {// Experimental
            var win=window[uuid+"data"]

    	    var points=jsdict[cmd+"points"]
 	    var polys=jsdict[cmd+"polys"]
 	    var cam=jsdict[cmd+"cam"]
            // Loop over content of jsdict
            win.actor = vtk.Rendering.Core.vtkActor.newInstance();
            var mapper = vtk.Rendering.Core.vtkMapper.newInstance();
            
            // Apply transformation to the points coordinates // figure this out later
            //    vtkMatrixBuilder
            ///      .buildFromRadian()
            ///      .translate(...model.center)
            ///      .rotateFromDirections([1, 0, 0], model.direction)
            ///      .apply(points);
            
            win.dataset = vtk.Common.DataModel.vtkPolyData.newInstance();
            win.dataset.getPoints().setData(points, 3);
            win.dataset.getPolys().setData(polys,1);
            mapper.setInputData(win.dataset);
            win.actor.setMapper(mapper);
            win.renderer.addActor(win.actor);
            setinteractorstyle(win.interactor,cam)
        }
        else if (jsdict[cmd]=="plot")
        {// Experimental
            var win=window[uuid+"data"]
    	    var points=jsdict[cmd+"points"]
 	    var lines=jsdict[cmd+"lines"]

            win.actor = vtk.Rendering.Core.vtkActor.newInstance();
            var mapper = vtk.Rendering.Core.vtkMapper.newInstance();

            var dataset=vtk.Common.DataModel.vtkPolyData.newInstance();
            dataset.getPoints().setData(points, 3);
            dataset.getLines().setData(lines);
            mapper.setInputData(dataset);
            win.actor.setMapper(mapper);
            win.actor.getProperty().setColor(0, 0, 0)
            win.renderer.addActor(window.actor);
            setinteractorstyle(interactor,cam)
        }
    }
    
    //renderer.setLayer(0);
    var win=window[uuid+"data"]
    win.renderer.resetCamera();
    win.renderWindow.render();

    // The invalidation promise is resolved when the cell starts rendering a newer output.
    // We use it to release the WebGL context.
    // (More info at https://plutocon2021-demos.netlify.app/fonsp%20%E2%80%94%20javascript%20inside%20pluto or https://observablehq.com/@observablehq/invalidation )
    invalidation.then(() => {
        win.renderWindow.delete();
        win.openGlRenderWindow.delete();
        win.interactor.delete();
    });
}

    
