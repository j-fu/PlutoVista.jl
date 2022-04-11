### A Pluto.jl notebook ###
# v0.19.0

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ c102e87a-b570-4d86-b087-3506396fc065
begin
	using PlutoUI
	import Triangulate
	import TetGen
	using HypertextLiteral
	using SimplexGridFactory
	using ExtendableGrids
    using PlutoVista
	using GridVisualize
end

# ╔═╡ 0c0ae400-84f6-4381-800d-f65e481b8786
html"""
<font size=+4>
<b> Pluto Hackathon 2022</b><br>

<b>PlutoVista.jl</b><br>
</font>

<font size=+3>
<b>Fast 1/2/3D visualization in the browser</b>
</font><br>

April 11, 2022
"""

# ╔═╡ 93ca4fd0-8f61-4174-b459-55f5395c0f56
md"""
# [PlutoVista.jl](https://github.com/j-fu/PlutoVista.jl)

Jürgen Fuhrmann

Weierstrass Institute for Applied Analysis and Stochastics, Berlin

[https://www.wias-berlin.de/people/fuhrmann](https://www.wias-berlin.de/people/fuhrmann)
"""

# ╔═╡ b23455e6-1289-410d-b32f-b21178b4b409
md"""
- __Duty:__ Numerical Math, PDE based simulation algorithms, application projects
- __Secret interest:__ in-situ visualization from within 1/2/3D unstructured grid PDE solvers
  - Plot output during simulation run
  - Non-intrusive API so it can be added to any code
  - Utilization of GPU hardware
"""

# ╔═╡ 56ae9a6e-0c07-4bc4-9a48-bf17e8caefb9
md"""
- Did use some [GKS](https://en.wikipedia.org/wiki/Graphical_Kernel_System) in the early times
- Rolled my own: [gms](https://github.com/j-fu/gms) with Postscript, X11, regis, Tektronix backends.
- Switched to OpenGL: [gltools](https://github.com/j-fu/gltools)
  - Uses fixed function pipeline OpenGL standard
  - `gltools2` with FLTK gui included in [WIAS simulation code](http://pdelib.org)  
    (we think about making this available to Julia)
- tried vtk: [vtkfig](https://github.com/j-fu/vtkfig), [VTKView.jl](https://github.com/j_fu/VTKView.jl), see my [vizcon2 talk](https://www.youtube.com/watch?v=DmueA_Lvigs) from March 2020
"""

# ╔═╡ 0c089e2e-9c50-4c7a-ae6a-febe2696eeb3
md"""
## Purpose of PlutoVista:
- Pluto specific backend for plotting results of 1D/2D/3D simulations on simplex grids
- Primitives: 
   - 1D: lines, markers
   - 2D: "heatmaps", isolines on triangles
   - 3D: isosurfaces, plane cuts on tetrahedra
- No sophisticated data structures
- Ability to handle large datasets
"""

# ╔═╡ 53f55db7-225f-4717-ab62-e024211e98a2
md"""
## 1D Data

1D Data are plotted using the [plotly.js](https://plotly.com/javascript/) javascript plotting library as backend.
"""

# ╔═╡ f07005f9-afc4-442e-921a-684f602c3556
html"""
<iframe
    src="https://plotly.com/javascript/"
    style="width: 100%; height: 300px;"
></iframe>
"""

# ╔═╡ 08def42a-8abc-4314-856f-293d4d987e47
md"""
Plotly.js is called directly, without resorting to a Julia wrapper package. Due to its focus, PlutoVista mostly uses line charts.
"""

# ╔═╡ a0d24213-62cb-478f-86bf-2dfd9be283e5
md"""
Just use javascript with some __magic:__
- Set up a `div` to define a plot region
- In  a `<script>` set up some trace data for plotly in javascript
- Call `newPlot`

__The magic:__ 
Instead of interpolating the data directly into javascript (which would involve ASCII encoding in Julia and decoding in javascript), we use `PlutoRunner.publish_to_js()` to [pass binary data without recoding from Julia to javascript](https://github.com/fonsp/Pluto.jl/pull/1124).
"""

# ╔═╡ cd45439e-b5bf-4599-83d3-ccd42899e804
x1=collect(0:0.01:10)

# ╔═╡ 0f25d2fd-a6ac-4b6a-8827-e8ab83510766
y1=sin.(x1)

# ╔═╡ 95aa063b-71e4-42f9-81d4-039af37a9a30
htl"""
<script>
var trace1 = {
  x: $(Main.PlutoRunner.publish_to_js(x1)),
  y: $(Main.PlutoRunner.publish_to_js(y1)),
  type: 'scatter'
};
var data = [trace1];
var layout = {
  xaxis: {title: 'x'},
  yaxis: {title: 'sin(x)'}
};
Plotly.newPlot('myDiv', data, layout);
</script>
<div id="myDiv" style= "width: 500px; height: 300px; ; display: inline-block; "></div
"""

# ╔═╡ feb26251-2eef-4a51-a7f7-5c0bc4664222
md"""
__But:__

["Julia: come for the syntax, stay for the speed"](https://www.nature.com/articles/d41586-019-02310-3) on nature.com:

"Julia circumvents that two-language problem because it runs like C, but reads like Python. And it includes built-in features to accelerate computationally intensive problems, such as distributed computing, that otherwise require multiple languages. "

Here, we have to use _four_ languages: Julia, html, javascript, (css). This will not work for the student or scientist who focuses on her topic an just wants to use an efficient tool for computation and visualization.
"""

# ╔═╡ f855d3a2-9721-4f0e-b38a-4539127b4f7a
md"""
__PlutoVista__ just puts a (hopefully nice) Julia wrapper around this:
"""

# ╔═╡ 2e92c42c-2923-4f35-9d43-6e38eee3f8f6
plot(x1,y1,resolution=(500,300))

# ╔═╡ 76d7a50d-40da-4367-a84f-3e2324e0c78d
md"""
For changing data, we can create the plot first and fill it afterwards, just updating the plotly plot.
"""

# ╔═╡ c3b719cd-5134-4395-8f36-4daab6ee3bf0
p1=plot(resolution=(600,300),axisfontsize=20);p1

# ╔═╡ bdde2452-cf28-4d56-935c-693e6a1ca8a9
md"""
 xscale1: $(@bind xscale1 Slider(1:0.1:10,show_value=true))
"""

# ╔═╡ cf9f4d1a-ebcd-4b59-bb0c-cc0d6b3239ca
begin
	plot!(p1,x1,sin.(x1*xscale1);label="sin",color=:red,linestyle=:dashdot,clear=true)
	plot!(p1,x1,cos.(x1*xscale1);label="cos",color=:green,linestyle=:dot,clear=false,show=true,xlabel="x",ylabel="y")
end

# ╔═╡ d0ea4e21-9d8c-416e-bf68-d7522e2ece20
md"""
## 2D Data

For 2D data, the package uses  [vtk.js](https://kitware.github.io/vtk-js/index.html)
as a backend and thus uses GPU acceleration WebGL interface.
"""

# ╔═╡ 59e28117-11ba-44c6-9e64-24aeefb548cf
md"""
### [VTK](https://vtk.org)

- Started in 1993, BSD license
- Well maintained, reasonable evolution with legacy edges
- First class citizen of CMake universe (both maintained by Kitware)
- C++ Library behind Paraview, the number one open source 3D visualization application for scientific computing
   - Paraview can be used off-line from Julia: write out data with [WriteVTK.jk](https://github.com/jipolanco/WriteVTK.jl),  load "vtk" file into paraview
"""

# ╔═╡ 72be6b7b-7c2a-4b8e-99ea-410788541cfe
html"""
<iframe
    src="https://www.paraview.org/"
    style="width: 100%; height: 300px;"
></iframe>
"""

# ╔═╡ 2c5c1614-43fe-44c1-87a1-bd26c5c7e5e1
md"""
PlutoVista uses vtk.js, the javascript version of VTK's rendering engine using WebGL

- Again pass data with `PlutoRunner.publish_to_js()`
"""

# ╔═╡ f15a91a4-a03b-4125-ba58-e44d9792a7e3
md"""
Let us make a triangulation using the [SimplexGridFactory.jl](https://github.com/j-fu/SimplexGridFactory.jl) package with [Triangulate.jl](https://github.com/JuliaGeometry/Triangulate.jl) as backend, plot it, define a piecewise linear function on it and plot this function.
"""

# ╔═╡ ab232244-4fe2-4ab0-a0bf-d1d9510802d2
function grid2d(;maxvolume=0.1)
    builder=SimplexGridBuilder(Generator=Triangulate)
  
	# attach a region number and a volume
	cellregion!(builder,1)
    maxvolume!(builder,maxvolume)
    regionpoint!(builder,0.1,0.1)

    # define some points
    p1=point!(builder,0,0)
    p2=point!(builder,10,0)
    p3=point!(builder,10,12)
    p4=point!(builder,0,10)

	# join points by lines
    facetregion!(builder,1)
    facet!(builder,p1,p2)
    facet!(builder,p2,p3)
    facet!(builder,p3,p4)
    facet!(builder,p4,p1)

	# create the grid
    simplexgrid(builder)
end

# ╔═╡ 724495e1-d501-4a03-be88-16b644938afd
md"""
Change grid resolution: $(@bind resolution Slider(1:1:20))
"""

# ╔═╡ d3ad0d4f-859d-44ac-a387-aac8d465cc6d
grid2=grid2d(maxvolume=1/resolution^2)

# ╔═╡ e010e502-784c-4dd2-9a8e-06a9958b3ffa
pts=grid2[Coordinates]

# ╔═╡ e8096502-de27-452c-87e0-5e7113bebaf2
tris=grid2[CellNodes]

# ╔═╡ da3bdabb-b81c-4c05-90cd-aee7b209e605
md"""
### trimesh
"""

# ╔═╡ 83be4a71-4f01-4f70-9cbe-f4e9b9222428
trimesh(pts,tris)

# ╔═╡ 8186bd23-5727-4d87-805c-5e5c6a092535
md"""
### tricontour
"""

# ╔═╡ ee9a6fb2-3978-40f4-803b-7cb8d50b4fac
func2=map((x,y)->sin(x)*cos(y),grid2)

# ╔═╡ 8b25e922-12db-4fae-8f28-65fe4faf40f3
tricontour(pts,tris,func2;colormap=:hot,levels=-0.5:0.2:0.5)

# ╔═╡ 20a88415-f2b4-4806-9ffc-6be979d12d0a
data(pts,t)=0.5*[sin(pts[1,i]-t)*cos(pts[2,i]-t)+t for i=1:size(pts,2)];

# ╔═╡ 39412087-3ee3-41fb-818f-23e5396abba3
p2=tricontour()

# ╔═╡ 68cba79c-2577-4250-b045-08e954bde4e5
md"""
shift: $(@bind shift1 Slider(-8:0.1:8,show_value=true))
"""

# ╔═╡ a221d0da-e16f-49a1-86b1-d1b8e3256d00
tricontour!(p2,pts,tris,data(pts,shift1);colormap=:hot,levels=5)

# ╔═╡ d3055a1a-5b55-4c43-ac09-7704186e714a
tricontour!(p2,pts,tris,data(pts,shift1),colormap=:hot,levels=5)

# ╔═╡ 387bbdee-0175-4a25-9a97-49fdb8afb7fc
md"""
Alternatively, we can use  Plotly as backend:
"""

# ╔═╡ d46ab20a-0b2b-4841-ae79-3226d3bd760f
tricontour(pts,tris,func2;colormap=:hot,levels=collect(-0.5:0.2:0.5),backend=:plotly)

# ╔═╡ a8c153f7-1fac-4065-9631-a4aa5e8a3dbe
md"""
### 2D Summary:
- Data structure independent API (just 1D, 2D arrays)
- vtk backend, optional use of Plotly.js
- Color+isoline calculation in Julia, rendering in javascript
"""

# ╔═╡ d1e13f8c-7cb8-4cb5-9dda-1a9b5d6142b6
md"""
## 3D Data
"""

# ╔═╡ 1864bb61-b900-407f-ae9a-494b3b104b62
md"""
3D visualization is a challenge - what to show at all ?

Our choice:
- Heatmaps on cutplanes
- Isosurfaces
- Transparency
- Possibility for interactive exploration
"""

# ╔═╡ a2bb8861-493d-4003-8a4e-e0ea051fbb72
md"""
### tetmesh
"""

# ╔═╡ 411d8975-f67a-4236-b827-c030675db91c
function sphere_with_hole()
    
    builder=SimplexGridBuilder(Generator=TetGen)
    facetregion!(builder,7)
    cellregion!(builder,1)
    maxvolume!(builder,0.001)
    regionpoint!(builder,(0,0,1.5))
    sphere!(builder,(0,0,0),2.0,nref=3)
    
    rect3d!(builder,[-0.5,-0.5,-0.5],[0.5,0.5,0.5], facetregions=[1,2,3,4,5,6])
    holepoint!(builder,(0,0,0))
        
    simplexgrid(builder)
end


# ╔═╡ b1f255ac-7347-4cf0-8ca1-491713fcb6b0
g3=sphere_with_hole()

# ╔═╡ 39def16b-87e6-461f-8c6f-224c094b3585
pts3=g3[Coordinates]

# ╔═╡ 0d5a620d-f8d0-4928-9214-0c4024c69755
tets=g3[CellNodes]

# ╔═╡ da36cf26-8105-4569-9d09-6f16383000a0
md"""
x: $(@bind gxplane Slider(0:0.01:1,show_value=true,default=0.45))
y: $(@bind gyplane Slider(0:0.01:1,show_value=true,default=0.45))
z: $(@bind gzplane Slider(0:0.01:1,show_value=true,default=0.45))
"""

# ╔═╡ d009c4cb-9ef6-45bd-960f-0213880f662a
 tetmesh(pts3,tets;
		markers=g3[CellRegions],
	faces=g3[BFaceNodes],
	facemarkers=g3[BFaceRegions],
	xplanes=[gxplane],yplanes=[gyplane],zplanes=[gzplane],resolution=(500,500))

# ╔═╡ b33a9e6b-7c93-475c-96f4-7259b30c2c47
md"""
### tetcontour
"""

# ╔═╡ aded5964-8229-423c-b9f3-c80358b95fcc
f3=map(g3) do x,y,z
	sinpi(x/2)*cospi(y/2)*cospi(z/2)
end

# ╔═╡ 6af0b5d7-5324-43b5-8f99-6f5d35d5deba
TableOfContents()

# ╔═╡ 809ceb74-8201-4cc1-8cdc-656dc070e020
p3d=tetcontour(resolution=(500,500));p3d

# ╔═╡ c222b16b-0ddc-4287-a029-779bdd77dd7b
md"""
f: $(@bind flevel Slider(0:0.01:1,show_value=true,default=0.45))

x: $(@bind xplane Slider(-2:0.01:2,show_value=true,default=-1.1))
y: $(@bind yplane Slider(-2:0.01:2,show_value=true,default=-1.1))
z: $(@bind zplane Slider(-2:0.01:2,show_value=true,default=-1.1))
"""

# ╔═╡ 36e48e9c-9452-4b07-bce4-c1cfe3c19409
tetcontour!(p3d,g3[Coordinates],g3[CellNodes],f3;levels=[flevel],
	xplanes=[xplane],yplanes=[yplane],zplanes=[zplane],levelalpha=0.7,colormap=:hot)

# ╔═╡ c3ae6e3d-5dc2-4eaa-9506-64d54058ba37
md"""
### 3D Summary
- Data structure independent API (just 1D, 2D arrays)
- Color+cutplane+isosurface calculation in Julia, rendering in javascript via vtk.js
"""

# ╔═╡ 8f5a6192-3d0e-4c52-a3f4-a2e11a570e32
md"""
# GridVisualize.jl

Wrapper around PyPlot, PlutoVista, Makie, Plots for plotting on grids managed by ExtendableGrids.jl, SimplexGridFactory.jl
"""

# ╔═╡ 4320f51b-6781-45cb-b8a8-2f00e8ff9163
gridplot(grid2,Plotter=PlutoVista)

# ╔═╡ aad2f0ee-2bb9-4c1f-a743-fd2c586ed5f9
scalarplot(grid2,func2,Plotter=PlutoVista)

# ╔═╡ 5b4f6f75-a0d9-42cb-8132-1f90f65c671c
XX=0:0.1:10

# ╔═╡ 57b7a6e8-4919-4180-bb6b-4a9c24c77ebf
g3big=simplexgrid(XX,XX,XX)

# ╔═╡ 7199e666-7ae6-4440-a76f-f3cd66ec0421
f3big=map((x,y,z)->sinpi(x)*cospi(y)*sinpi(z),g3big)

# ╔═╡ 2e0fcab1-5718-49fb-853f-e801cf978f7b
scalarplot(g3big,f3big,Plotter=PlutoVista)

# ╔═╡ 31e394d2-f781-49e6-b049-1a607f6906d8
md"""
# Some plans...
- Integration into Julia geometry universe (GeometryBasics.mesh)
- More primitives: `trisurf` plots, vector fields (partially done)
- Factor out isoline/isosurface calculation into own package
- More element types (quadrilaterals, hexahedra, prisms)
- Artifacts for vtk.js, plotly.js
- Join forces with other plotly bases packages
"""

# ╔═╡ b074a389-bd07-4548-a75c-efa8c7663b15
html"""<hr>"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
ExtendableGrids = "cfc395e8-590f-11e8-1f13-43a2532b2fa8"
GridVisualize = "5eed8a63-0fb0-45eb-886d-8d5a387d12b8"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
PlutoVista = "646e1f28-b900-46d7-9d87-d554eb38a413"
SimplexGridFactory = "57bfcd06-606e-45d6-baf4-4ba06da0efd5"
TetGen = "c5d3f3f7-f850-59f6-8a2e-ffc6dc1317ea"
Triangulate = "f7e6ffb2-c36d-4f8f-a77e-16e897189344"

[compat]
ExtendableGrids = "~0.9.5"
GridVisualize = "~0.5.1"
HypertextLiteral = "~0.9.3"
PlutoUI = "~0.7.38"
PlutoVista = "~0.8.12"
SimplexGridFactory = "~0.5.15"
TetGen = "~1.3.0"
Triangulate = "~2.1.2"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.0-beta3"
manifest_format = "2.0"
project_hash = "3f7468e3c88c814e79704905a0f574a5fde5d402"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.AbstractTrees]]
git-tree-sha1 = "03e0550477d86222521d254b741d470ba17ea0b5"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.3.4"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "af92965fb30777147966f58acb05da51c5616b5f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.3"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "12fc73e5e0af68ad3137b886e3f7c1eacfca2640"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.17.1"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

[[deps.ElasticArrays]]
deps = ["Adapt"]
git-tree-sha1 = "a0fcc1bb3c9ceaf07e1d0529c9806ce94be6adf9"
uuid = "fdbdab4c-e67f-52f5-8c3f-e7b388dad3d4"
version = "1.2.9"

[[deps.ExtendableGrids]]
deps = ["AbstractTrees", "Dates", "DocStringExtensions", "ElasticArrays", "InteractiveUtils", "LinearAlgebra", "Printf", "Random", "SparseArrays", "StaticArrays", "Test", "WriteVTK"]
git-tree-sha1 = "cec19e62fc126df338de88585f45a763f7601bd3"
uuid = "cfc395e8-590f-11e8-1f13-43a2532b2fa8"
version = "0.9.5"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "246621d23d1f43e3b9c368bf3b72b2331a27c286"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.13.2"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "83ea630384a13fc4f002b77690bc0afeb4255ac9"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.2"

[[deps.GridVisualize]]
deps = ["ColorSchemes", "Colors", "DocStringExtensions", "ElasticArrays", "ExtendableGrids", "GeometryBasics", "HypertextLiteral", "LinearAlgebra", "Observables", "OrderedCollections", "PkgVersion", "Printf", "StaticArrays"]
git-tree-sha1 = "5d845bccf5d690879f4f5f01c7112e428b1fa543"
uuid = "5eed8a63-0fb0-45eb-886d-8d5a387d12b8"
version = "0.5.1"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.81.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[deps.LightXML]]
deps = ["Libdl", "XML2_jll"]
git-tree-sha1 = "e129d9391168c677cd4800f5c0abb1ed8cb3794f"
uuid = "9c8b4983-aa76-5018-a973-4c85ecc9e179"
version = "0.9.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Observables]]
git-tree-sha1 = "fe29afdef3d0c4a8286128d4e45cc50621b1e43d"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.4.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "621f4f3b4977325b9128d5fae7a8b4829a0c2222"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.2.4"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "a7a7e1a88853564e551e4eba8650f8c38df79b37"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.1.1"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "670e559e5c8e191ded66fa9ea89c97f10376bb4c"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.38"

[[deps.PlutoVista]]
deps = ["ColorSchemes", "Colors", "DocStringExtensions", "GridVisualize", "HypertextLiteral", "UUIDs"]
git-tree-sha1 = "2435d1d3e02db324414f268f30999b5c06a0d10f"
uuid = "646e1f28-b900-46d7-9d87-d554eb38a413"
version = "0.8.12"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "d3538e7f8a790dc8903519090857ef8e1283eecd"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.5"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SimplexGridFactory]]
deps = ["DocStringExtensions", "ElasticArrays", "ExtendableGrids", "GridVisualize", "LinearAlgebra", "Printf", "Test"]
git-tree-sha1 = "5504be2daef28d7d99b845ebabbe5b7608106fec"
uuid = "57bfcd06-606e-45d6-baf4-4ba06da0efd5"
version = "0.5.15"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "4f6ec5d99a28e1a749559ef7dd518663c5eca3d5"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.4.3"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "57617b34fa34f91d536eb265df67c2d4519b8b98"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.5"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "5ce79ce186cc678bbb5c5681ca3379d1ddae11a1"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.7.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TetGen]]
deps = ["DocStringExtensions", "GeometryBasics", "LinearAlgebra", "Printf", "StaticArrays", "TetGen_jll"]
git-tree-sha1 = "2f1d87ccacd2a7faf9e0bade918946ec4d90bfdf"
uuid = "c5d3f3f7-f850-59f6-8a2e-ffc6dc1317ea"
version = "1.3.0"

[[deps.TetGen_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bc67a0d0b799fe248b1f199a5c893ccf316f0e60"
uuid = "b47fdcd6-d2c1-58e9-bbba-c1cee8d8c179"
version = "1.5.2+0"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[deps.Triangle_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bfdd9ef1004eb9d407af935a6f36a4e0af711369"
uuid = "5639c1d2-226c-5e70-8d55-b3095415a16a"
version = "1.6.1+0"

[[deps.Triangulate]]
deps = ["DocStringExtensions", "Libdl", "Printf", "Test", "Triangle_jll"]
git-tree-sha1 = "ffa6491b39ad78fd977e3b09fc6a21f28d82a4ae"
uuid = "f7e6ffb2-c36d-4f8f-a77e-16e897189344"
version = "2.1.2"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.WriteVTK]]
deps = ["Base64", "CodecZlib", "FillArrays", "LightXML", "TranscodingStreams"]
git-tree-sha1 = "bff2f6b5ff1e60d89ae2deba51500ce80014f8f6"
uuid = "64499a7a-5c06-52f2-abe2-ccb03c286192"
version = "1.14.2"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "1acf5bdf07aa0907e0a37d3718bb88d4b687b74a"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.12+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.41.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "16.2.1+1"
"""

# ╔═╡ Cell order:
# ╟─0c0ae400-84f6-4381-800d-f65e481b8786
# ╟─93ca4fd0-8f61-4174-b459-55f5395c0f56
# ╟─b23455e6-1289-410d-b32f-b21178b4b409
# ╟─56ae9a6e-0c07-4bc4-9a48-bf17e8caefb9
# ╟─0c089e2e-9c50-4c7a-ae6a-febe2696eeb3
# ╟─53f55db7-225f-4717-ab62-e024211e98a2
# ╟─f07005f9-afc4-442e-921a-684f602c3556
# ╟─08def42a-8abc-4314-856f-293d4d987e47
# ╟─a0d24213-62cb-478f-86bf-2dfd9be283e5
# ╠═cd45439e-b5bf-4599-83d3-ccd42899e804
# ╠═0f25d2fd-a6ac-4b6a-8827-e8ab83510766
# ╠═95aa063b-71e4-42f9-81d4-039af37a9a30
# ╟─feb26251-2eef-4a51-a7f7-5c0bc4664222
# ╟─f855d3a2-9721-4f0e-b38a-4539127b4f7a
# ╠═2e92c42c-2923-4f35-9d43-6e38eee3f8f6
# ╟─76d7a50d-40da-4367-a84f-3e2324e0c78d
# ╠═c3b719cd-5134-4395-8f36-4daab6ee3bf0
# ╠═cf9f4d1a-ebcd-4b59-bb0c-cc0d6b3239ca
# ╟─bdde2452-cf28-4d56-935c-693e6a1ca8a9
# ╟─d0ea4e21-9d8c-416e-bf68-d7522e2ece20
# ╟─59e28117-11ba-44c6-9e64-24aeefb548cf
# ╟─72be6b7b-7c2a-4b8e-99ea-410788541cfe
# ╟─2c5c1614-43fe-44c1-87a1-bd26c5c7e5e1
# ╟─f15a91a4-a03b-4125-ba58-e44d9792a7e3
# ╠═ab232244-4fe2-4ab0-a0bf-d1d9510802d2
# ╠═d3ad0d4f-859d-44ac-a387-aac8d465cc6d
# ╠═e010e502-784c-4dd2-9a8e-06a9958b3ffa
# ╠═e8096502-de27-452c-87e0-5e7113bebaf2
# ╟─724495e1-d501-4a03-be88-16b644938afd
# ╟─da3bdabb-b81c-4c05-90cd-aee7b209e605
# ╠═83be4a71-4f01-4f70-9cbe-f4e9b9222428
# ╟─8186bd23-5727-4d87-805c-5e5c6a092535
# ╠═ee9a6fb2-3978-40f4-803b-7cb8d50b4fac
# ╠═8b25e922-12db-4fae-8f28-65fe4faf40f3
# ╠═20a88415-f2b4-4806-9ffc-6be979d12d0a
# ╠═39412087-3ee3-41fb-818f-23e5396abba3
# ╠═a221d0da-e16f-49a1-86b1-d1b8e3256d00
# ╟─68cba79c-2577-4250-b045-08e954bde4e5
# ╠═d3055a1a-5b55-4c43-ac09-7704186e714a
# ╟─387bbdee-0175-4a25-9a97-49fdb8afb7fc
# ╠═d46ab20a-0b2b-4841-ae79-3226d3bd760f
# ╟─a8c153f7-1fac-4065-9631-a4aa5e8a3dbe
# ╟─d1e13f8c-7cb8-4cb5-9dda-1a9b5d6142b6
# ╟─1864bb61-b900-407f-ae9a-494b3b104b62
# ╟─a2bb8861-493d-4003-8a4e-e0ea051fbb72
# ╠═411d8975-f67a-4236-b827-c030675db91c
# ╠═b1f255ac-7347-4cf0-8ca1-491713fcb6b0
# ╠═39def16b-87e6-461f-8c6f-224c094b3585
# ╠═0d5a620d-f8d0-4928-9214-0c4024c69755
# ╟─da36cf26-8105-4569-9d09-6f16383000a0
# ╠═d009c4cb-9ef6-45bd-960f-0213880f662a
# ╟─b33a9e6b-7c93-475c-96f4-7259b30c2c47
# ╠═aded5964-8229-423c-b9f3-c80358b95fcc
# ╟─6af0b5d7-5324-43b5-8f99-6f5d35d5deba
# ╠═809ceb74-8201-4cc1-8cdc-656dc070e020
# ╟─c222b16b-0ddc-4287-a029-779bdd77dd7b
# ╠═36e48e9c-9452-4b07-bce4-c1cfe3c19409
# ╟─c3ae6e3d-5dc2-4eaa-9506-64d54058ba37
# ╟─8f5a6192-3d0e-4c52-a3f4-a2e11a570e32
# ╠═4320f51b-6781-45cb-b8a8-2f00e8ff9163
# ╠═aad2f0ee-2bb9-4c1f-a743-fd2c586ed5f9
# ╠═5b4f6f75-a0d9-42cb-8132-1f90f65c671c
# ╠═57b7a6e8-4919-4180-bb6b-4a9c24c77ebf
# ╠═7199e666-7ae6-4440-a76f-f3cd66ec0421
# ╠═2e0fcab1-5718-49fb-853f-e801cf978f7b
# ╟─31e394d2-f781-49e6-b049-1a607f6906d8
# ╟─b074a389-bd07-4548-a75c-efa8c7663b15
# ╠═c102e87a-b570-4d86-b087-3506396fc065
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
