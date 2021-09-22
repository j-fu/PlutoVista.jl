function setinteractorstyle(interactor, cam)
{
    if (cam=="2D")
        interactor.setInteractorStyle(vtk.Interaction.Style.vtkInteractorStyleImage.newInstance());
    else
        interactor.setInteractorStyle(vtk.Interaction.Style.vtkInteractorStyleTrackballCamera.newInstance());
}


function plutovtkplot(uuid,jsdict,invalidation)
{


    if (window[uuid+"data"]==undefined)
    {
        window[uuid+"data"]={}
        var win=window[uuid+"data"]
        win.renderWindow = vtk.Rendering.Core.vtkRenderWindow.newInstance();
        win.renderer = vtk.Rendering.Core.vtkRenderer.newInstance();
        win.update=false
        
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
    var win=window[uuid+"data"]
    win.update=true
    
    // Loop over content of jsdict
    for (var cmd = 1 ; cmd <= jsdict.cmdcount ; cmd++)
    {  
        if (jsdict[cmd]=="tricontour")
        {
            // see https://discourse.vtk.org/t/manually-create-polydata-in-vtk-js/885/15
            if (win.dataset==undefined)
            {
                win.update=false
            }

    	    var points=jsdict[cmd+"points"]
 	    var polys=jsdict[cmd+"polys"]
            var isopoints=jsdict[cmd+"isopoints"]
 	    var isolines=jsdict[cmd+"isolines"]
            var colors=jsdict[cmd+"colors"]

            /// need to use LUT here!
            var colorData = vtk.Common.Core.vtkDataArray.newInstance({
                name: 'Colors',
                values: colors,
                numberOfComponents: 3,
            });

            
            if (!win.update)
            {
                win.dataset = vtk.Common.DataModel.vtkPolyData.newInstance();
                win.actor = vtk.Rendering.Core.vtkActor.newInstance();
                var mapper = vtk.Rendering.Core.vtkMapper.newInstance();
                mapper.setInputData(win.dataset);
                mapper.setColorModeToDirectScalars()
                win.actor.setMapper(mapper);
                win.renderer.addActor(win.actor);
            }
            
            win.dataset.getPoints().setData(points, 3);
            win.dataset.getPolys().setData(polys,1);
            win.dataset.getPointData().setActiveScalars('Colors');
            win.dataset.getPointData().setScalars(colorData);        
            win.dataset.modified()

            if (isopoints != "none")
            {
                //https://discourse.vtk.org/t/manually-create-polydata-in-vtk-js/885/4
                
                if (!win.update)
                {
                    var isomapper = vtk.Rendering.Core.vtkMapper.newInstance();
                    var isoactor = vtk.Rendering.Core.vtkActor.newInstance();
                    win.isodataset=vtk.Common.DataModel.vtkPolyData.newInstance();
                    isomapper.setInputData(win.isodataset);
                    isoactor.setMapper(isomapper);
                    isoactor.getProperty().setColor(0, 0, 0)
                    win.renderer.addActor(isoactor);
                }
                
                win.isodataset.getPoints().setData(isopoints, 3);
                win.isodataset.getLines().setData(isolines);
                win.isodataset.modified()
            }
            win.renderWindow.render();
        }
        if (jsdict[cmd]=="tetcontour")
        {

            // see https://discourse.vtk.org/t/manually-create-polydata-in-vtk-js/885/15
            if (win.dataset==undefined)
            {
                win.update=false
            }
    	    var points=jsdict[cmd+"points"]
 	    var polys=jsdict[cmd+"polys"]
            var colors=jsdict[cmd+"colors"]


            var outline=jsdict[cmd+"outline"]
    	    var opoints=jsdict[cmd+"opoints"]
 	    var opolys=jsdict[cmd+"opolys"]
            var ocolors=jsdict[cmd+"ocolors"]

            if (outline==1)
            {
                var ocolorData = vtk.Common.Core.vtkDataArray.newInstance({
                    name: 'Colors',
                    values: ocolors,
                    numberOfComponents: 4,
                });

            }

            
            /// need to use LUT here!
            var colorData = vtk.Common.Core.vtkDataArray.newInstance({
                name: 'Colors',
                values: colors,
                numberOfComponents: 3,
            });

            
            if (!win.update)
            {
                win.dataset = vtk.Common.DataModel.vtkPolyData.newInstance();
                win.actor = vtk.Rendering.Core.vtkActor.newInstance();
                var mapper = vtk.Rendering.Core.vtkMapper.newInstance();
                mapper.setInputData(win.dataset);
                mapper.setColorModeToDirectScalars()
                win.actor.setMapper(mapper);
                win.renderer.addActor(win.actor);

                if (outline==1)
                {
                    win.odataset = vtk.Common.DataModel.vtkPolyData.newInstance();
                    win.oactor = vtk.Rendering.Core.vtkActor.newInstance();
		    var omapper = vtk.Rendering.Core.vtkMapper.newInstance();
		    omapper.setInputData(win.odataset);
                    omapper.setColorModeToDirectScalars()
                    win.oactor.setForceTranslucent(true) //  https://discourse.vtk.org/t/wireframe-not-visible-behind-transparent-surfaces/6671
		    win.oactor.setMapper(omapper);
                    win.renderer.addActor(win.oactor);
                }



            }
            

            if (outline==1)
            {
                win.odataset.getPoints().setData(opoints, 3);
                win.odataset.getPolys().setData(opolys,1);
                win.odataset.getCellData().setActiveScalars('Colors');
                win.odataset.getCellData().setScalars(ocolorData);        
                win.odataset.modified()
            }


            win.dataset.getPoints().setData(points, 3);
            win.dataset.getPolys().setData(polys,1);
            win.dataset.getPointData().setActiveScalars('Colors');
            win.dataset.getPointData().setScalars(colorData);        
            win.dataset.modified()
            win.renderWindow.render();
        }
        else if (jsdict[cmd]=="trimesh")
        {
            // see https://discourse.vtk.org/t/manually-create-polydata-in-vtk-js/885/15
            if (win.dataset==undefined)
            {
                win.update=false
            }

    	    var points=jsdict[cmd+"points"]
 	    var polys=jsdict[cmd+"polys"]
            var colors=jsdict[cmd+"colors"]
            var lines=jsdict[cmd+"lines"]
            var linecolors=jsdict[cmd+"linecolors"]

            if (colors!="none")
            {
                /// need to use LUT here!
                var colorData = vtk.Common.Core.vtkDataArray.newInstance({
                    name: 'Colors',
                    values: colors,
                    numberOfComponents: 3,
                });
            }
            
            if (!win.update)
            {
                if (colors!="none")
                {
                    win.celldataset = vtk.Common.DataModel.vtkPolyData.newInstance();
                    win.cellactor = vtk.Rendering.Core.vtkActor.newInstance();
		    var cellmapper = vtk.Rendering.Core.vtkMapper.newInstance();
		    cellmapper.setInputData(win.celldataset);
                    cellmapper.setColorModeToDirectScalars()
		    win.cellactor.setMapper(cellmapper);
                    win.renderer.addActor(win.cellactor);
                }

                
                win.dataset = vtk.Common.DataModel.vtkPolyData.newInstance();
                win.actor = vtk.Rendering.Core.vtkActor.newInstance();
		var mapper = vtk.Rendering.Core.vtkMapper.newInstance();
                mapper.setColorModeToDefault()
		win.actor.getProperty().setRepresentation(1);
		win.actor.getProperty().setColor(0, 0, 0);
		win.actor.getProperty().setLineWidth(1.5);
		mapper.setInputData(win.dataset);
		win.actor.setMapper(mapper);
		win.renderer.addActor(win.actor);
            }
            

            if (colors !="none")
            {
                win.celldataset.getPoints().setData(points, 3);
                win.celldataset.getPolys().setData(polys,1);
                win.celldataset.getCellData().setActiveScalars('Colors');
                win.celldataset.getCellData().setScalars(colorData);        
                win.celldataset.modified()
            }
            win.dataset.getPoints().setData(points, 3);
            win.dataset.getPolys().setData(polys,1);
            win.dataset.modified()

            if (linecolors!="none")
            {
                /// need to use LUT here!
                var linecolorData = vtk.Common.Core.vtkDataArray.newInstance({
                    name: 'Colors',
                    values: linecolors,
                    numberOfComponents: 3,
                });
            }
            


            if (lines != "none")
            {
                //https://discourse.vtk.org/t/manually-create-polydata-in-vtk-js/885/4
                
                if (!win.update)
                {
                    var linemapper = vtk.Rendering.Core.vtkMapper.newInstance();
                    var lineactor = vtk.Rendering.Core.vtkActor.newInstance();
                    win.linedataset=vtk.Common.DataModel.vtkPolyData.newInstance();
                    linemapper.setInputData(win.linedataset);
                    lineactor.setMapper(linemapper);
                    lineactor.getProperty().setColor(0, 0, 0)
		    lineactor.getProperty().setLineWidth(4);

                    win.renderer.addActor(lineactor);
                }
                
                win.linedataset.getPoints().setData(points, 3);
                win.linedataset.getLines().setData(lines);
                if (linecolors!="none")
                    {
                        win.linedataset.getCellData().setActiveScalars('Colors');
                        win.linedataset.getCellData().setScalars(linecolorData);
                    }
                win.linedataset.modified()
            }

            win.renderWindow.render();

        }
        else if (jsdict[cmd]=="tetmesh")
        {
            // see https://discourse.vtk.org/t/manually-create-polydata-in-vtk-js/885/15
            if (win.dataset==undefined)
            {
                win.update=false
            }
    	    var points=jsdict[cmd+"points"]
 	    var polys=jsdict[cmd+"polys"]
            var colors=jsdict[cmd+"colors"]

            if (colors!="none")
            {
                /// need to use LUT here!
                var colorData = vtk.Common.Core.vtkDataArray.newInstance({
                    name: 'Colors',
                    values: colors,
                    numberOfComponents: 3,
                });
            }

            var outline=jsdict[cmd+"outline"]
    	    var opoints=jsdict[cmd+"opoints"]
 	    var opolys=jsdict[cmd+"opolys"]
            var ocolors=jsdict[cmd+"ocolors"]

            if (outline==1)
            {
                var ocolorData = vtk.Common.Core.vtkDataArray.newInstance({
                    name: 'Colors',
                    values: ocolors,
                    numberOfComponents: 4,
                });

            }


            
            if (!win.update)
            {
                if (colors!="none")
                {
                    win.celldataset = vtk.Common.DataModel.vtkPolyData.newInstance();
                    win.cellactor = vtk.Rendering.Core.vtkActor.newInstance();
		    var cellmapper = vtk.Rendering.Core.vtkMapper.newInstance();
		    cellmapper.setInputData(win.celldataset);
                    cellmapper.setColorModeToDirectScalars()
		    win.cellactor.setMapper(cellmapper);
                    win.renderer.addActor(win.cellactor);
                }

                if (outline==1)
                {
                    win.odataset = vtk.Common.DataModel.vtkPolyData.newInstance();
                    win.oactor = vtk.Rendering.Core.vtkActor.newInstance();
		    var omapper = vtk.Rendering.Core.vtkMapper.newInstance();
		    omapper.setInputData(win.odataset);
                    omapper.setColorModeToDirectScalars()
                    win.oactor.setForceTranslucent(true) //  https://discourse.vtk.org/t/wireframe-not-visible-behind-transparent-surfaces/6671
		    win.oactor.setMapper(omapper);
                    win.renderer.addActor(win.oactor);
                }

                
                win.dataset = vtk.Common.DataModel.vtkPolyData.newInstance();
                win.actor = vtk.Rendering.Core.vtkActor.newInstance();
		var mapper = vtk.Rendering.Core.vtkMapper.newInstance();
                mapper.setColorModeToDefault()
		win.actor.getProperty().setRepresentation(1);
		win.actor.getProperty().setColor(0, 0, 0);
		win.actor.getProperty().setLineWidth(1.5);
		mapper.setInputData(win.dataset);
		win.actor.setMapper(mapper);
		win.renderer.addActor(win.actor);
            }
            

            if (colors !="none")
            {
                win.celldataset.getPoints().setData(points, 3);
                win.celldataset.getPolys().setData(polys,1);
                win.celldataset.getCellData().setActiveScalars('Colors');
                win.celldataset.getCellData().setScalars(colorData);        
                win.celldataset.modified()
            }

            if (outline==1)
            {
                win.odataset.getPoints().setData(opoints, 3);
                win.odataset.getPolys().setData(opolys,1);
                win.odataset.getCellData().setActiveScalars('Colors');
                win.odataset.getCellData().setScalars(ocolorData);        
                win.odataset.modified()
            }


            
            win.dataset.getPoints().setData(points, 3);
            win.dataset.getPolys().setData(polys,1);
            win.dataset.modified()

            win.renderWindow.render();

        }
        else if (jsdict[cmd]=="axis")
        {

            if (!win.update)
            {
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
        }
        else if (jsdict[cmd]=="triplot")
        {// Experimental

    	    var points=jsdict[cmd+"points"]
 	    var polys=jsdict[cmd+"polys"]
 	    var cam=jsdict[cmd+"cam"]

            if (win.dataset==undefined)
            {
                win.update=false
            }
            

            if (!win.update)
            {
                win.actor = vtk.Rendering.Core.vtkActor.newInstance();
                var mapper = vtk.Rendering.Core.vtkMapper.newInstance();
                win.dataset = vtk.Common.DataModel.vtkPolyData.newInstance();
                mapper.setInputData(win.dataset);
                win.actor.setMapper(mapper);
                win.renderer.addActor(win.actor);
                setinteractorstyle(win.interactor,cam)
            }
            
            // Apply transformation to the points coordinates // figure this out later
            //    vtkMatrixBuilder
            ///      .buildFromRadian()
            ///      .translate(...model.center)
            ///      .rotateFromDirections([1, 0, 0], model.direction)
            ///      .apply(points);
            
            win.dataset.getPoints().setData(points, 3);
            win.dataset.getPolys().setData(polys,1);
            win.dataset.modified()
            win.renderWindow.render();
        }
        else if (jsdict[cmd]=="plot")
        {// Experimental
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

//    win.renderer.resetCamera();
    win.renderWindow.render();


    // The invalidation promise is resolved when the cell starts rendering a newer output.
    // We use it to release the WebGL context.
    // (More info at https://plutocon2021-demos.netlify.app/fonsp%20%E2%80%94%20javascript%20inside%20pluto or https://observablehq.com/@observablehq/invalidation )
    invalidation.then(() => {
        if (!win.update) // run this only if called from original cell
        {
            win.renderWindow.delete();
            win.openGlRenderWindow.delete();
            win.interactor.delete();
        }
    });
}

    
