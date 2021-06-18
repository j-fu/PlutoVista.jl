var documenterSearchIndex = {"docs":
[{"location":"api/#Public-API","page":"API","title":"Public API","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"Modules = [PlutoVista]\nPrivate = false\nPages = [\"common.jl\",\"pyplot.jl\",\"vtk.jl\"]","category":"page"},{"location":"api/#PlutoVista.VTKPlot","page":"API","title":"PlutoVista.VTKPlot","text":"Structure containig plot information.  In particular it contains dict of data sent to javascript.\n\n\n\n\n\n","category":"type"},{"location":"api/#PlutoVista.VTKPlot-Tuple{}","page":"API","title":"PlutoVista.VTKPlot","text":"    VTKPlot(;resolution=(300,300))\n\nCreate a canvas plot with given resolution in the notebook and given \"world coordinate\" range.\n\n\n\n\n\n","category":"method"},{"location":"api/#PlutoVista.axis2d!-Tuple{VTKPlot}","page":"API","title":"PlutoVista.axis2d!","text":"axis2d!(vtkplot)\n\nAdd 2D coordinate system axes to the plot. Sets camera handling to 2D mode.\n\n\n\n\n\n","category":"method"},{"location":"api/#PlutoVista.axis3d!-Tuple{VTKPlot}","page":"API","title":"PlutoVista.axis3d!","text":"axis3d!(vtkplot)\n\nAdd 3D coordinate system axes to the plot. Sets camera handling to 3D mode.\n\n\n\n\n\n","category":"method"},{"location":"api/#PlutoVista.tricontour!-Tuple{VTKPlot, Any, Any, Any}","page":"API","title":"PlutoVista.tricontour!","text":" tricontour!(p::VTKPlot,pts, tris,f; colormap)\n\nPlot piecewise linear function on  triangular grid given as \"heatmap\" \n\n\n\n\n\n","category":"method"},{"location":"api/#PlutoVista.triplot!-Tuple{VTKPlot, Any, Any, Any}","page":"API","title":"PlutoVista.triplot!","text":" triplot!(p::VTKPlot,pts, tris,f)\n\nPlot piecewise linear function on  triangular grid given by points and triangles as matrices\n\n\n\n\n\n","category":"method"},{"location":"#PlutoVista.jl","page":"Home","title":"PlutoVista.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Incubator for a plot library for Pluto notebooks based on plotly.js for 1D data and vtk.js (thus using WebGL)  for 2/3D data.","category":"page"},{"location":"","page":"Home","title":"Home","text":"This uses the Pluto 💁 API to make objects available inside JS to pass plot data from Julia to HTML5.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Please see:","category":"page"},{"location":"","page":"Home","title":"Home","text":"example notebook.","category":"page"},{"location":"","page":"Home","title":"Home","text":"So far, this package is in an early state.","category":"page"}]
}