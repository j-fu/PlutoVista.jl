// overwrite handleKeyPress and others
// kind of modeled after https://kitware.github.io/vtk-js/api/Rendering_Core_Follower.html 

function vtkMyInteractorStyleTrackballCamera2D(publicAPI, model)
{
    model.classHierarchy.push('vtkMyInteractorStyleTrackballCamera2D');
    publicAPI.handleKeyPress = (k) => {}
    publicAPI.handleMouseRotate= (renderer, pos) => {}
    publicAPI.handleMouseSpin= (renderer, pos) => {renderer.resetCamera()}
}

function vtkMyInteractorStyleTrackballCamera(publicAPI, model)
{
    model.classHierarchy.push('vtkMyInteractorStyleTrackballCamera');
    publicAPI.handleKeyPress = (k) => {}
    publicAPI.handleMouseSpin= (renderer, pos) => {renderer.resetCamera()}
}

function extend2d(publicAPI, model, initialValues = {})
{
    vtk.Interaction.Style.vtkInteractorStyleTrackballCamera.extend(publicAPI, model, initialValues);
    vtkMyInteractorStyleTrackballCamera2D(publicAPI, model);
}

function extend3d(publicAPI, model, initialValues = {})
{
    vtk.Interaction.Style.vtkInteractorStyleTrackballCamera.extend(publicAPI, model, initialValues);
    vtkMyInteractorStyleTrackballCamera(publicAPI, model);
}


function setinteractorstyle(interactor, cam)
{
    const mynewInstance2d = vtk.macro.newInstance(extend2d, 'vtkMyInteractorStyleTrackballCamera2D');
    const mynewInstance3d = vtk.macro.newInstance(extend3d, 'vtkMyInteractorStyleTrackballCamera');
    if (cam=="2D")
//        var style=vtk.Interaction.Style.vtkMyInteractorStyleImage.newInstance()
        var style=mynewInstance2d()
    else
//        var style=vtk.Interaction.Style.vtkInteractorStyleTrackballCamera.newInstance()
        var style=mynewInstance3d()
    
    style.invokeInteractionEvent({ type: 'InteractionEvent' });
    interactor.setInteractorStyle(style)
}


function add_outline_dataset(win,opoints,opolys,ocolors)
{
    var ocolorData = vtk.Common.Core.vtkDataArray.newInstance({
        name: 'Colors',
        values: ocolors,
        numberOfComponents: 4,
    });
    
    if (win.outline_dataset==undefined)
    {
        win.outline_dataset = vtk.Common.DataModel.vtkPolyData.newInstance();
        var actor = vtk.Rendering.Core.vtkActor.newInstance();
	var mapper = vtk.Rendering.Core.vtkMapper.newInstance();
	mapper.setInputData(win.outline_dataset);
        mapper.setColorModeToDirectScalars()
        actor.setForceTranslucent(true) //  https://discourse.vtk.org/t/wireframe-not-visible-behind-transparent-surfaces/6671
	actor.setMapper(mapper);
        win.renderer.addActor(actor);
    }
    win.outline_dataset.getPoints().setData(opoints, 3);
    win.outline_dataset.getPolys().setData(opolys,1);
    win.outline_dataset.getCellData().setActiveScalars('Colors');
    win.outline_dataset.getCellData().setScalars(ocolorData);        
    win.outline_dataset.modified()
}

function plutovtkplot(uuid,jsdict,invalidation)
{
    
    if (window[uuid+"data"] == undefined)
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
        
        //ensure to plot to the right place
        var rootContainer = document.getElementById(uuid);
        win.openGlRenderWindow.setContainer(rootContainer);
        const dims = rootContainer.getBoundingClientRect();	
        win.openGlRenderWindow.setSize(dims.width, dims.height);
        win.interactor.bindEvents(rootContainer);
        win.renderWindow.addRenderer(win.renderer)

        // The invalidation promise is resolved when the cell starts rendering a newer output.
        // We use it to release the WebGL context.
        // (More info at https://plutocon2021-demos.netlify.app/fonsp%20%E2%80%94%20javascript%20inside%20pluto or https://observablehq.com/@observablehq/invalidation )
        invalidation.then(() => {
            win.renderWindow.delete();
            win.openGlRenderWindow.delete();
            win.interactor.delete();
        });
    }
    

    var win=window[uuid+"data"]
    
    // Loop over content of jsdict
    for (var cmd = 1 ; cmd <= jsdict["cmdcount"] ; cmd++)
    {
        
        /////////////////////////////////////////////////////////////////
        if (jsdict[cmd]=="tricontour")
        {
    	    var points=jsdict[cmd+"points"]
 	    var polys=jsdict[cmd+"polys"]
            var isopoints=jsdict[cmd+"isopoints"]
 	    var isolines=jsdict[cmd+"isolines"]
            var colors=jsdict[cmd+"colors"]

            { // Gouraud shaded triangles
                if (win.color_triangle_dataset == undefined)
                {
                    win.color_triangle_dataset = vtk.Common.DataModel.vtkPolyData.newInstance();
                    var actor = vtk.Rendering.Core.vtkActor.newInstance();
                    var mapper = vtk.Rendering.Core.vtkMapper.newInstance();
                    mapper.setInputData(win.color_triangle_dataset);
                    mapper.setColorModeToDirectScalars()
                    actor.setMapper(mapper);
                    win.renderer.addActor(actor);
                    
                    // the axis actor is later used to read axis bounds
                    win.axis_actor=actor
                }
                
                var colorData = vtk.Common.Core.vtkDataArray.newInstance({
                    name: 'Colors',
                    values: colors,
                    numberOfComponents: 3,
                });
                
                win.color_triangle_dataset.getPoints().setData(points, 3);
                win.color_triangle_dataset.getPolys().setData(polys,1);
                win.color_triangle_dataset.getPointData().setActiveScalars('Colors');
                win.color_triangle_dataset.getPointData().setScalars(colorData);        
                win.color_triangle_dataset.modified()
            }

            if (isolines != "none")
            { // Optional isolines
                
                //https://discourse.vtk.org/t/manually-create-polydata-in-vtk-js/885/4
                
                if (win.isoline_dataset == undefined)
                {
                    win.isoline_dataset=vtk.Common.DataModel.vtkPolyData.newInstance();
                    var mapper = vtk.Rendering.Core.vtkMapper.newInstance();
                    var actor = vtk.Rendering.Core.vtkActor.newInstance();
                    mapper.setInputData(win.isoline_dataset);
                    actor.setMapper(mapper);
                    actor.getProperty().setColor(0, 0, 0)
                    win.renderer.addActor(actor);
                }
                
                win.isoline_dataset.getPoints().setData(isopoints, 3);
                win.isoline_dataset.getLines().setData(isolines);
                win.isoline_dataset.modified()
            }
        }
        /////////////////////////////////////////////////////////////////
        else if (jsdict[cmd]=="quiver")
        { // 2D quiver
            var qpoints=jsdict[cmd+"points"]
 	    var qlines=jsdict[cmd+"lines"]
            
            if (win.quiver_dataset == undefined)
            {
                win.quiver_dataset=vtk.Common.DataModel.vtkPolyData.newInstance();
                var mapper = vtk.Rendering.Core.vtkMapper.newInstance();
                var actor = vtk.Rendering.Core.vtkActor.newInstance();
                mapper.setInputData(win.quiver_dataset);
                actor.setMapper(mapper);
                actor.getProperty().setColor(0, 0, 0)
                win.renderer.addActor(actor);

                if (win.axis_actor == undefined)
                {
                    win.axis_actor=actor
                }
            }
            
            win.quiver_dataset.getPoints().setData(qpoints, 3);
	    win.quiver_dataset.getLines().setData(qlines);
	    win.quiver_dataset.modified()
        }
        /////////////////////////////////////////////////////////////////
        else if (jsdict[cmd]=="tetcontour")
        {

            var points=jsdict[cmd+"points"]
 	    var polys=jsdict[cmd+"polys"]
            var colors=jsdict[cmd+"colors"]


            var outline=jsdict[cmd+"outline"]
    	    var opoints=jsdict[cmd+"opoints"]
 	    var opolys=jsdict[cmd+"opolys"]
            var ocolors=jsdict[cmd+"ocolors"]
            var transparent=jsdict[cmd+"transparent"]


            { // isosurfaces and plane sections
                
                if (win.iso_plane_dataset == undefined)
                {
                    win.iso_plane_dataset = vtk.Common.DataModel.vtkPolyData.newInstance();
                    var actor = vtk.Rendering.Core.vtkActor.newInstance();
                    var mapper = vtk.Rendering.Core.vtkMapper.newInstance();
                    mapper.setInputData(win.iso_plane_dataset);
                    mapper.setColorModeToDirectScalars()
                    if (transparent==1)
                    {
                        actor.setForceTranslucent(true) //  https://discourse.vtk.org/t/wireframe-not-visible-behind-transparent-surfaces/6671
                    }
                    actor.setMapper(mapper);
                    win.renderer.addActor(actor);
                    win.axis_actor=actor
                }
                
                if (transparent==1)
                {
                    var colorData = vtk.Common.Core.vtkDataArray.newInstance({
                        name: 'Colors',
                        values: colors,
                        numberOfComponents: 4,
                    });
                }
                else
                {
                    var colorData = vtk.Common.Core.vtkDataArray.newInstance({
                        name: 'Colors',
                        values: colors,
                        numberOfComponents: 3,
                    });
                }
                win.iso_plane_dataset.getPoints().setData(points, 3);
                win.iso_plane_dataset.getPolys().setData(polys,1);
                win.iso_plane_dataset.getPointData().setActiveScalars('Colors');
                win.iso_plane_dataset.getPointData().setScalars(colorData);        
                win.iso_plane_dataset.modified()
            }

            
            if (outline==1)
            {
                add_outline_dataset(win,opoints,opolys,ocolors)
            }
        }
        /////////////////////////////////////////////////////////////////
        else if (jsdict[cmd]=="trimesh")
        {

    	    var points=jsdict[cmd+"points"]
 	    var polys=jsdict[cmd+"polys"]
            var colors=jsdict[cmd+"colors"]
            var lines=jsdict[cmd+"lines"]
            var linecolors=jsdict[cmd+"linecolors"]
            
            if (colors!="none")
            {   // clolored triangles
                
                if (win.colored_triangle_dataset == undefined)
                {
                    win.colored_triangle_dataset = vtk.Common.DataModel.vtkPolyData.newInstance();
                    var actor = vtk.Rendering.Core.vtkActor.newInstance();
		    var mapper = vtk.Rendering.Core.vtkMapper.newInstance();
		    mapper.setInputData(win.colored_triangle_dataset);
                    mapper.setColorModeToDirectScalars()
		    actor.setMapper(mapper);
                    win.renderer.addActor(actor);

                    win.axis_actor=actor
                }
                
                var colorData = vtk.Common.Core.vtkDataArray.newInstance({
                    name: 'Colors',
                    values: colors,
                    numberOfComponents: 3,
                });
                
                win.colored_triangle_dataset.getPoints().setData(points, 3);
                win.colored_triangle_dataset.getPolys().setData(polys,1);
                win.colored_triangle_dataset.getCellData().setActiveScalars('Colors');
                win.colored_triangle_dataset.getCellData().setScalars(colorData);        
                win.colored_triangle_dataset.modified()
            }

            { // triangle edges
                
                if (win.triangle_edges == undefined)
                {
                    win.triangle_edges = vtk.Common.DataModel.vtkPolyData.newInstance();
                    var actor = vtk.Rendering.Core.vtkActor.newInstance();
		    var mapper = vtk.Rendering.Core.vtkMapper.newInstance();
                    mapper.setColorModeToDefault()
		    actor.getProperty().setRepresentation(1);
		    actor.getProperty().setColor(0, 0, 0);
		    actor.getProperty().setLineWidth(1.5);
		    mapper.setInputData(win.triangle_edges);
		    actor.setMapper(mapper);
		    win.renderer.addActor(actor);
                }
                
                
                win.triangle_edges.getPoints().setData(points, 3);
                win.triangle_edges.getPolys().setData(polys,1);
                win.triangle_edges.modified()
            }


            if (lines != "none")
            { // boundary edges
            
                if (linecolors!="none")
                {
                    var linecolorData = vtk.Common.Core.vtkDataArray.newInstance({
                        name: 'Colors',
                        values: linecolors,
                        numberOfComponents: 3,
                    });
                }
                
                if (win.boundary_edge_dataset == undefined)
                {
                    win.boundary_edge_dataset=vtk.Common.DataModel.vtkPolyData.newInstance();
                    var mapper = vtk.Rendering.Core.vtkMapper.newInstance();
                    var actor = vtk.Rendering.Core.vtkActor.newInstance();
                    mapper.setInputData(win.boundary_edge_dataset);
                    actor.setMapper(mapper);
                    actor.getProperty().setColor(0, 0, 0)
		    actor.getProperty().setLineWidth(4);
                    win.renderer.addActor(actor);
                }
                
                win.boundary_edge_dataset.getPoints().setData(points, 3);
                win.boundary_edge_dataset.getLines().setData(lines);
                if (linecolors!="none")
                {
                    win.boundary_edge_dataset.getCellData().setActiveScalars('Colors');
                    win.boundary_edge_dataset.getCellData().setScalars(linecolorData);
                }
                win.boundary_edge_dataset.modified()
            }

        }
        /////////////////////////////////////////////////////////////////
        else if (jsdict[cmd]=="tetmesh")
        {
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


            
            { // colored cells
                if (colors!="none")
                {
                    if (win.cell_color_dataset == undefined)
                    {
                        win.cell_color_dataset = vtk.Common.DataModel.vtkPolyData.newInstance();
                        var actor = vtk.Rendering.Core.vtkActor.newInstance();
                        var mapper = vtk.Rendering.Core.vtkMapper.newInstance();
                        mapper.setInputData(win.cell_color_dataset);
                        mapper.setColorModeToDirectScalars()
                        actor.setMapper(mapper);
                        win.renderer.addActor(actor);
                    }
                    win.cell_color_dataset.getPoints().setData(points, 3);
                    win.cell_color_dataset.getPolys().setData(polys,1);
                    win.cell_color_dataset.getCellData().setActiveScalars('Colors');
                    win.cell_color_dataset.getCellData().setScalars(colorData);        
                    win.cell_color_dataset.modified()
                }
            }
            { // edges of cells
                
                if (win.cell_edge_dataset == undefined)
                {
                    
                    win.cell_edge_dataset = vtk.Common.DataModel.vtkPolyData.newInstance();
                    var actor = vtk.Rendering.Core.vtkActor.newInstance();
		    var mapper = vtk.Rendering.Core.vtkMapper.newInstance();
                    mapper.setColorModeToDefault()
		    actor.getProperty().setRepresentation(1);
		    actor.getProperty().setColor(0, 0, 0);
		    actor.getProperty().setLineWidth(1.5);
		    mapper.setInputData(win.cell_edge_dataset);
		    actor.setMapper(mapper);
		    win.renderer.addActor(actor);
                    win.axis_actor=actor
                }
                
                win.cell_edge_dataset.getPoints().setData(points, 3);
                win.cell_edge_dataset.getPolys().setData(polys,1);
                win.cell_edge_dataset.modified()
            }
            
            if (outline==1)
            {
                add_outline_dataset(win,opoints,opolys,ocolors)
            }

        }
        /////////////////////////////////////////////////////////////////
        else if (jsdict[cmd]=="axis")
        {
            var axisfontsize= jsdict[cmd+"axisfontsize"] 
            var tickfontsize= jsdict[cmd+"tickfontsize"]
            if (win.cubeAxes == undefined)
            {
 	        var camstyle=jsdict[cmd+"cam"]




                win.cubeAxes = vtk.Rendering.Core.vtkCubeAxesActor.newInstance();
  	        win.renderer.addActor(win.cubeAxes);

                win.interactor.initialize();
                setinteractorstyle(win.interactor,camstyle)
                


                var camera=win.renderer.getActiveCamera()
                if (camstyle=="3D")
                {
                    camera.roll(-30);
                    camera.elevation(-60);
                }

                win.cubeAxes.setCamera(camera);
                
                win.cubeAxes.setAxisLabels(['x','y','z'])
                if (camstyle=="2D")
                    win.cubeAxes.setGridLines(false)

                win.cubeAxes.setTickTextStyle({fontColor: "black"})
                win.cubeAxes.setTickTextStyle({fontFamily: "Arial"})
                win.cubeAxes.setTickTextStyle({fontSize: tickfontsize})
                
                win.cubeAxes.setAxisTextStyle({fontColor: "black"})
                win.cubeAxes.setAxisTextStyle({fontFamily: "Arial"})
                win.cubeAxes.setAxisTextStyle({fontSize: axisfontsize})
                
                win.cubeAxes.getProperty().setColor(0.75,0.75,0.75);
	        win.cubeAxes.setDataBounds(win.axis_actor.getBounds());

                win.renderer.resetCamera();
            }
        }
        /////////////////////////////////////////////////////////////////
        else if (jsdict[cmd]=="triplot")
        {// Experimental

            if (win.triplot_dataset == undefined)
            {
                win.triplot_dataset = vtk.Common.DataModel.vtkPolyData.newInstance();
                var actor = vtk.Rendering.Core.vtkActor.newInstance();
                var mapper = vtk.Rendering.Core.vtkMapper.newInstance();
                mapper.setInputData(win.triplot_dataset);
                actor.setMapper(mapper);
                win.renderer.addActor(actor);
                win.axis_actor=actor
            }
            
    	    var points=jsdict[cmd+"points"]
 	    var polys=jsdict[cmd+"polys"]
            win.triplot_dataset.getPoints().setData(points, 3);
            win.triplot_dataset.getPolys().setData(polys,1);
            win.triplot_dataset.modified()
        }
        /////////////////////////////////////////////////////////////////
        else if (jsdict[cmd]=="plot")
        {// Experimental
    	    var points=jsdict[cmd+"points"]
 	    var lines=jsdict[cmd+"lines"]
            
            var actor = vtk.Rendering.Core.vtkActor.newInstance();
            var mapper = vtk.Rendering.Core.vtkMapper.newInstance();

            win.plotdataset=vtk.Common.DataModel.vtkPolyData.newInstance();
            win.plotdataset.getPoints().setData(points, 3);
            win.plotdataset.getLines().setData(lines);
            mapper.setInputData(dataset);
            actor.setMapper(mapper);
            actor.getProperty().setColor(0, 0, 0)
            win.renderer.addActor(actor);
        }
    }
    win.renderWindow.render()
}

    
