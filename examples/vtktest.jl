### A Pluto.jl notebook ###
# v0.19.16

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

# ╔═╡ 08980845-f030-4a64-a4b2-ab027b3a2721
begin  
     using Pkg
     Pkg.activate(joinpath(@__DIR__,"..","test"))
     using Revise
	Pkg.update()
	Pkg.develop("PlutoVista")
end	

# ╔═╡ d6c0fb79-4129-444a-978a-bd2222b53df6
begin
    using PlutoUI
    using PlutoVista
    using GridVisualize
    using Printf
    using Triangulate
	using ExtendableGrids
end

# ╔═╡ 93ca4fd0-8f61-4174-b459-55f5395c0f56
md"""
# Test Notebook for [PlutoVista](https://github.com/j-fu/PlutoVista.jl) and [vtk.js](https://kitware.github.io/vtk-js/index.html)
"""

# ╔═╡ 7c06fcf0-8c98-49f7-add8-435f57a9c9da
function maketriangulation(maxarea)
    triin=Triangulate.TriangulateIO()
    triin.pointlist=Matrix{Cdouble}([-1.0 -1.0 ; 1.0 -1.0 ; 1.0 2 ; -1.0 1.0]')
    triin.segmentlist=Matrix{Cint}([1 2 ; 2 3 ; 3 4 ; 4 1; 4 2 ]')
    triin.segmentmarkerlist=Vector{Int32}([1, 2, 3, 4, 5])
    triin.regionlist=Matrix{Cdouble}([-0.9 0.9; -0.9 0.9; 1 2 ; 2.0*maxarea maxarea])
    (triout, vorout)=triangulate("paADQ", triin)
    triout.pointlist, triout.trianglelist,Int.(vec(triout.triangleattributelist)),triout.segmentlist,triout.segmentmarkerlist
end

# ╔═╡ 60dcfcf5-391e-418f-8e7c-3a0fe94f1e0d
p=PlutoVTKPlot(resolution=(300,300),tickfontsize=10)

# ╔═╡ db2823d9-aa6d-4be3-af5c-873c072cfd2b
md"""
Change grid resolution: $(@bind resolution Slider(5:200))
"""

# ╔═╡ 890710fe-dac0-4256-b1ba-79776f1ea7e5
(pts,tris,markers,edges,edgemarkers)=maketriangulation(1/resolution^2)

# ╔═╡ b8a976e3-7fef-4527-ae6a-4da31c93a04f
func=0.5.+0.5*[sin(10*pts[1,i])*cos(10*pts[2,i]) for i=1:size(pts,2)]

# ╔═╡ 401b36bd-fa8f-4a9c-9556-bbc82c3ddbca
 md"""
Change time: $(@bind time Slider(0:0.1:10,show_value=true))
"""

# ╔═╡ 6fd4a1ee-7a4a-405b-8e1f-5819eababe10
ft=0.5*[sin(10*pts[1,i]-time)*cos(10*pts[2,i]-time) for i=1:size(pts,2)];

# ╔═╡ e76f8a6a-ab91-454a-b200-cfc8b57eb331
triplot!(p,pts,tris,ft)

# ╔═╡ bce0cfe7-4112-4bb8-aac6-43885f3746a9
md"""Number of gridpoints: $(size(pts,2)) """

# ╔═╡ 81046dcd-3cfb-4133-943f-61b9b3cdb183
let
	p=PlutoVTKPlot(resolution=(300,300),axisfontsize=20)
	tricontour!(p,pts,tris,func;cmap=:spring,levels=(0.1:0.2:1),limits=(0,1),xlabel="a",aspect=1.1)
end

# ╔═╡ 7019ce3f-f2db-4581-8bd9-64f76231a62a
let
	p=PlutoVTKPlot(resolution=(300,300),legendfontsize=15)
	trimesh!(p,pts,tris;
		markers=markers,
		edges=edges,edgemarkers=edgemarkers
	)
end

# ╔═╡ 2e3546f6-eb47-4693-aa00-902570fab7b5
function grid3d(;n=15)
    X=collect(0:1/n:1)
    g=simplexgrid(X,X,X)
end

# ╔═╡ bd0a59a2-564d-42bd-ab6f-a50b26f9241f
function func3d(;n=15)
    g=grid3d(n=n)
    g, map((x,y,z)->sinpi(2*x)*sinpi(3.5*y)*sinpi(1.5*z),g)
end

# ╔═╡ 368b8cf5-fabd-4b84-b33c-b15c4452393b
	g,f=func3d(;n=20)

# ╔═╡ f64729e4-d2b4-40d3-acbb-1395dbe0337d
p3d=PlutoVTKPlot(resolution=(300,300))

# ╔═╡ 7be35f33-5f7a-4765-8bb6-1487e209efc8
md"""
f: $(@bind flevel Slider(0:0.01:1,show_value=true,default=0.45))

x: $(@bind xplane Slider(0:0.01:1,show_value=true,default=0.45))
y: $(@bind yplane Slider(0:0.01:1,show_value=true,default=0.45))
z: $(@bind zplane Slider(0:0.01:1,show_value=true,default=0.45))
"""

# ╔═╡ 3681ef5b-c794-44da-9fe7-cedcd68b426c
tetcontour!(p3d,g[Coordinates],g[CellNodes],f;levels=[flevel],
	faces=g[BFaceNodes],
	facemarkers=g[BFaceRegions],
	xplanes=[xplane],yplanes=[yplane],zplanes=[zplane],outlinealpha=0.1, levelalpha=0.25)

# ╔═╡ 0f440c27-7ff1-4db5-b4eb-8ce1e9018ef1
g[BFaceNodes]

# ╔═╡ 606f6837-f3b7-4a52-b9c3-034799c7bf93
g3x=let
	n=10
X=collect(0:1/n:1)
simplexgrid(X,X,X)
end

# ╔═╡ ecb3bb5e-6ae5-4d6e-9834-d52ce977b3fc
p3dx=PlutoVTKPlot(resolution=(300,300))

# ╔═╡ 90ff6ffc-84dc-45fd-8d09-9eb916397630
 md"""
x: $(@bind gxplane Slider(0:0.01:1,show_value=true,default=0.45))
y: $(@bind gyplane Slider(0:0.01:1,show_value=true,default=0.45))
z: $(@bind gzplane Slider(0:0.01:1,show_value=true,default=0.45))
"""

# ╔═╡ ae5707d9-41b7-4937-924a-fb54b83c31db
alpha=0.15

# ╔═╡ 519d106f-3f6f-4db1-b4e4-c5e7ef176857
tetmesh!(p3dx,g3x[Coordinates],g3x[CellNodes];
		markers=g3x[CellRegions],
	faces=g3x[BFaceNodes],
	facemarkers=g3x[BFaceRegions],
	xplanes=gxplane,yplanes=gyplane,zplanes=gzplane,outlinealpha=0)

# ╔═╡ 4263e897-d878-4fab-acae-a6c4dae37c5e
qp=PlutoVTKPlot(resolution=(500,500))

# ╔═╡ 5dfb1dde-06ed-483a-bac3-6a21a7f98856
@bind x0 Slider(1:0.01:9)

# ╔═╡ 6d7547c6-5667-463f-99dc-2f3fbaeb4c4d
let
	n=50
	X=0:10/n:10
	g=simplexgrid(X,X)
	pts=g[Coordinates]
    f(x,y)=sin(x-x0)*cos(y)+0.05*(x-x0)*y
    fx(x,y)=-cos(x-x0)*cos(y)-0.05*y
    fy(x,y)=sin(x-x0)*sin(y)-0.05*(x-x0)
    v=map(f,g)
    ∇v=0.5*vcat(map(fx,g)',map(fy,g)')
	
	tricontour!(qp,pts,g[CellNodes],v,colormap=:summer,levels=5)
	quiver2d!(qp,pts,∇v)
end

# ╔═╡ 23c75823-e69f-4ca0-a3ca-783612ba9c3c
html"""<hr>"""

# ╔═╡ Cell order:
# ╟─93ca4fd0-8f61-4174-b459-55f5395c0f56
# ╠═d6c0fb79-4129-444a-978a-bd2222b53df6
# ╠═7c06fcf0-8c98-49f7-add8-435f57a9c9da
# ╠═890710fe-dac0-4256-b1ba-79776f1ea7e5
# ╠═b8a976e3-7fef-4527-ae6a-4da31c93a04f
# ╠═60dcfcf5-391e-418f-8e7c-3a0fe94f1e0d
# ╟─db2823d9-aa6d-4be3-af5c-873c072cfd2b
# ╟─401b36bd-fa8f-4a9c-9556-bbc82c3ddbca
# ╠═6fd4a1ee-7a4a-405b-8e1f-5819eababe10
# ╠═e76f8a6a-ab91-454a-b200-cfc8b57eb331
# ╟─bce0cfe7-4112-4bb8-aac6-43885f3746a9
# ╠═81046dcd-3cfb-4133-943f-61b9b3cdb183
# ╠═7019ce3f-f2db-4581-8bd9-64f76231a62a
# ╠═2e3546f6-eb47-4693-aa00-902570fab7b5
# ╠═bd0a59a2-564d-42bd-ab6f-a50b26f9241f
# ╠═368b8cf5-fabd-4b84-b33c-b15c4452393b
# ╠═f64729e4-d2b4-40d3-acbb-1395dbe0337d
# ╟─7be35f33-5f7a-4765-8bb6-1487e209efc8
# ╠═3681ef5b-c794-44da-9fe7-cedcd68b426c
# ╠═0f440c27-7ff1-4db5-b4eb-8ce1e9018ef1
# ╠═606f6837-f3b7-4a52-b9c3-034799c7bf93
# ╠═ecb3bb5e-6ae5-4d6e-9834-d52ce977b3fc
# ╟─90ff6ffc-84dc-45fd-8d09-9eb916397630
# ╠═ae5707d9-41b7-4937-924a-fb54b83c31db
# ╠═519d106f-3f6f-4db1-b4e4-c5e7ef176857
# ╠═4263e897-d878-4fab-acae-a6c4dae37c5e
# ╠═5dfb1dde-06ed-483a-bac3-6a21a7f98856
# ╠═6d7547c6-5667-463f-99dc-2f3fbaeb4c4d
# ╟─23c75823-e69f-4ca0-a3ca-783612ba9c3c
# ╠═08980845-f030-4a64-a4b2-ab027b3a2721
