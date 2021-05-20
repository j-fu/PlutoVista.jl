
function vtkplot(uuid,jsdict,invalidation)
{
    var renderWindow = vtk.Rendering.Core.vtkRenderWindow.newInstance();
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
            var actor = vtk.Rendering.Core.vtkActor.newInstance();
            var mapper = vtk.Rendering.Core.vtkMapper.newInstance();
            
            // for color, see 	https://github.com/Kitware/vtk-js/issues/1167
            // Apply transformation to the points coordinates // figure this out later
            //    vtkMatrixBuilder
            ///      .buildFromRadian()
            ///      .translate(...model.center)
            ///      .rotateFromDirections([1, 0, 0], model.direction)
            ///      .apply(points);
            
            var  dataset = vtk.Common.DataModel.vtkPolyData.newInstance();
            dataset.getPoints().setData(points, 3);
            dataset.getPolys().setData(polys,1);
            mapper.setInputData(dataset);
            actor.setMapper(mapper);
            renderer.addActor(actor);
            if (cam=="2D")
                interactor.setInteractorStyle(vtk.Interaction.Style.vtkInteractorStyleImage.newInstance());
            else
                interactor.setInteractorStyle(vtk.Interaction.Style.vtkInteractorStyleTrackballCamera.newInstance());

        }
        if (jsdict[cmd]=="tricolor")
        {
    	    var points=jsdict[cmd+"_points"]
 	    var polys=jsdict[cmd+"_polys"]
 	    var colors=jsdict[cmd+"_colors"]
 	    var cam=jsdict[cmd+"_cam"]

            // Loop over content of jsdict
            var actor = vtk.Rendering.Core.vtkActor.newInstance();
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
            actor.setMapper(mapper);
            renderer.addActor(actor);

            if (cam=="2D")
                interactor.setInteractorStyle(vtk.Interaction.Style.vtkInteractorStyleImage.newInstance());
            else
                interactor.setInteractorStyle(vtk.Interaction.Style.vtkInteractorStyleTrackballCamera.newInstance());

        }
        else if (jsdict[cmd]=="axis3d")
        {
 	    var cam=jsdict[cmd+"_cam"]
            var cubeAxes = vtk.Rendering.Core.vtkCubeAxesActor.newInstance();
            
	    cubeAxes.setCamera(renderer.getActiveCamera());
            cubeAxes.setTickTextStyle({fontColor: "black"})
            cubeAxes.setAxisTextStyle({fontColor: "black"})
	    cubeAxes.setDataBounds(jsdict[cmd+"_bounds"]);
            cubeAxes.getProperty().setColor(0,0,0);
	    renderer.addActor(cubeAxes);

            if (cam=="2D")
            {
                interactor.setInteractorStyle(vtk.Interaction.Style.vtkInteractorStyleImage.newInstance());
                cubeAxes.setGridLines(false)
            }
            else
            {
                interactor.setInteractorStyle(vtk.Interaction.Style.vtkInteractorStyleTrackballCamera.newInstance());
            }
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

    
