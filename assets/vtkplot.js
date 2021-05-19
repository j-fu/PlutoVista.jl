function vtkplot(uuid,jsdict)
{
    var renderWindow = vtk.Rendering.Core.vtkRenderWindow.newInstance();
    var renderer = vtk.Rendering.Core.vtkRenderer.newInstance();

    // OpenGlRenderWindow
    var openGlRenderWindow = vtk.Rendering.OpenGL.vtkRenderWindow.newInstance();
    renderWindow.addView(openGlRenderWindow);
    
    
    
    // Interactor
    var interactor = vtk.Rendering.Core.vtkRenderWindowInteractor.newInstance();
    interactor.setView(openGlRenderWindow);
    interactor.initialize();
    interactor.setInteractorStyle(vtk.Interaction.Style.vtkInteractorStyleTrackballCamera.newInstance());
    
    renderWindow.addRenderer(renderer);
    var actor = vtk.Rendering.Core.vtkActor.newInstance();
    var mapper = vtk.Rendering.Core.vtkMapper.newInstance();
    
    // we need to set up  the triangle data for vtk. 
    // Coding is  [3, i1, i2, i3,   3, i1, i2, i3]
    // Careful: js indexing counts from zero
    
    const ntri=jsdict.tris.length/3	
    const polys = new Uint32Array(4*ntri);
    
    var ipoly=0
    var itri=0
    for (let i = 0; i <  ntri; i++) {
        polys[ipoly++] = 3;
        polys[ipoly++] = jsdict.tris[itri++]-1
        polys[ipoly++] = jsdict.tris[itri++]-1
        polys[ipoly++] = jsdict.tris[itri++]-1
    }
    
    // for color, see 	https://github.com/Kitware/vtk-js/issues/1167
    // Apply transformation to the points coordinates // figure this out later
    //    vtkMatrixBuilder
    ///      .buildFromRadian()
    ///      .translate(...model.center)
    ///      .rotateFromDirections([1, 0, 0], model.direction)
    ///      .apply(points);
    
    var  dataset = vtk.Common.DataModel.vtkPolyData.newInstance();
    dataset.getPoints().setData(jsdict.points, 3);
    dataset.getPolys().setData(polys,1);
    
    mapper.setInputData(dataset);
    
    
    actor.setMapper(mapper);
    
    const cubeAxes = vtk.Rendering.Core.vtkCubeAxesActor.newInstance();
    cubeAxes.setCamera(renderer.getActiveCamera());
    cubeAxes.setDataBounds(actor.getBounds());
    renderer.addActor(cubeAxes);
    
    //	renderer.setLayer(0);
    renderer.addActor(actor);
    renderer.addActor(cubeAxes);
    //	renderer.resetCamera();
    
    //ensure to plot to the right place
    var rootContainer = document.getElementById(uuid);
    openGlRenderWindow.setContainer(rootContainer);
    const dims = rootContainer.getBoundingClientRect();	
    openGlRenderWindow.setSize(dims.width, dims.height);
    interactor.bindEvents(rootContainer);
    
    renderWindow.render();
}

    
