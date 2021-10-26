### A Pluto.jl notebook ###
# v0.16.4

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ fdf728b9-ade9-46f3-8aaf-cf22aaaa55d2
md"""
begin
   using Pkg
   Pkg.activate(".testenv")
   Pkg.add("Revise"); using Revise
   Pkg.add(["PlutoUI","Triangulate","ExtendableGrids","SimplexGridFactory","TetGen"])
   Pkg.develop("PlutoVista")
   #PkgCellForTest
end
"""

# ╔═╡ c102e87a-b570-4d86-b087-3506396fc065
begin
	using PlutoUI
	import Triangulate
	import TetGen
	using SimplexGridFactory
	using ExtendableGrids
        using PlutoVista
end

# ╔═╡ 93ca4fd0-8f61-4174-b459-55f5395c0f56
md"""
# Test Notebook for [PlutoVista](https://github.com/j-fu/PlutoVista.jl)
"""

# ╔═╡ 53f55db7-225f-4717-ab62-e024211e98a2
md"""
## 1D Data

1D Data are plotted using the [plotly.js](https://plotly.com/javascript/) javascript plotting library as backend.

### plot
"""

# ╔═╡ b8a976e3-7fef-4527-ae6a-4da31c93a04f
X=0:0.01:10

# ╔═╡ 133d0c31-eea9-4200-88d2-4afdc61a16bd
md"""
The simplest way to plot 1D data is to just plot:
"""

# ╔═╡ 2e92c42c-2923-4f35-9d43-6e38eee3f8f6
plot(X,cos.(X))

# ╔═╡ 09cfb361-b897-40b1-8792-23b00151b995
md"""
More complicated plots can be combined.
"""

# ╔═╡ 60dcfcf5-391e-418f-8e7c-3a0fe94f1e0d
md"""
let
    p=PlutoVistaPlot(resolution=(500,300),titlefontsize=20)
	plot!(p,X,yscale*sin.(X*xscale);label="sin",color=:red,linestyle=:dashdot)
	plot!(p,X,cos.(X*xscale);label="cos",color=:green,linewidth=1,markertype=:star5)
	plot!(p,X,X./X[end];color=:blue,linestyle=:dash,title="test",legend=:rt,xlabel="x")
end
"""

# ╔═╡ f44deb76-e715-477c-9e8a-dcf5cd68577f
md"""
xscale $(@bind xscale Slider(1:0.1:10,show_value=true))

yscale: $(@bind yscale Slider(1:0.1:10,show_value=true)), 
"""

# ╔═╡ 76d7a50d-40da-4367-a84f-3e2324e0c78d
md"""
For changing data, we can create the plot first and fill it afterwards.
"""

# ╔═╡ c3b719cd-5134-4395-8f36-4daab6ee3bf0
p1=plot(resolution=(600,300),axisfontsize=20)

# ╔═╡ bdde2452-cf28-4d56-935c-693e6a1ca8a9
md"""
 xscale1: $(@bind xscale1 Slider(1:0.1:10,show_value=true))
"""

# ╔═╡ cf9f4d1a-ebcd-4b59-bb0c-cc0d6b3239ca
begin
	plot!(p1,X,sin.(X*xscale1);label="sin",color=:red,linestyle=:dashdot,clear=true)
	plot!(p1,X,cos.(X*xscale1);label="cos",color=:green,linestyle=:dot,clear=false,show=true,xlabel="x",ylabel="y")
end

# ╔═╡ d5240960-7759-48b8-94fd-3436f7b1573d
md"""
### Discontinuous function
"""

# ╔═╡ b4afef75-450c-45a9-af8b-87224c3591e9
begin 
	Xm=collect(-1:0.01:0)
	Xp=collect(0:0.01:1)
	Xpm=vcat(Xp,[NaN],Xm)
	F=vcat(map(x->sin(4π*x),Xm),[NaN],map(x->cos(4π*x),Xp))

end

# ╔═╡ 0c8bc23a-cee1-4d6b-a63e-8f2391fc3f3c
PlutoVista.plot(Xpm,F,markertype=:star5,markercount=20)

# ╔═╡ d0ea4e21-9d8c-416e-bf68-d7522e2ece20
md"""
## 2D Data

For 2D data, the package uses  [vtk.js](https://kitware.github.io/vtk-js/index.html)
as a backend and ths us uses GPU acceleration via the WebGL interface.
"""

# ╔═╡ f15a91a4-a03b-4125-ba58-e44d9792a7e3
md"""
Let us make a triangulation using the Triangulate.jl package, plot it, define a piecewise linear function on it and plot this function.
"""

# ╔═╡ ab232244-4fe2-4ab0-a0bf-d1d9510802d2
function maketriangulation(maxarea)
     triin=Triangulate.TriangulateIO()
    triin.pointlist=Matrix{Cdouble}([-1.0 -1.0 ; 1.0 -1.0 ; 1.0 2 ; -1.0 1.0]')
    triin.segmentlist=Matrix{Cint}([1 2 ; 2 3 ; 3 4 ; 4 1; 4 2 ]')
    triin.segmentmarkerlist=Vector{Int32}([1, 2, 3, 4, 6])
    triin.regionlist=Matrix{Cdouble}([-0.9 0.9; -0.9 0.9; 1 2 ; 2.0*maxarea maxarea])
    (triout, vorout)=Triangulate.triangulate("paADQ", triin)
    triout.pointlist, triout.trianglelist,Int.(vec(triout.triangleattributelist)),triout.segmentlist,triout.segmentmarkerlist
end;

# ╔═╡ 724495e1-d501-4a03-be88-16b644938afd
md"""
Change grid resolution: $(@bind resolution Slider(10:1:100))
"""

# ╔═╡ d3ad0d4f-859d-44ac-a387-aac8d465cc6d
(pts,tris,markers,edges,edgemarkers)=maketriangulation(1/resolution^2);

# ╔═╡ 83c7bffd-16c6-4cc7-8a68-87cbd739f3f4
md"""
The grid has $(size(pts,2)) points and $(size(tris,2))  triangles.
"""

# ╔═╡ da3bdabb-b81c-4c05-90cd-aee7b209e605
md"""
### trimesh
"""

# ╔═╡ 83be4a71-4f01-4f70-9cbe-f4e9b9222428
trimesh(pts,tris;markers=markers,edges=edges,edgemarkers=edgemarkers)

# ╔═╡ 8186bd23-5727-4d87-805c-5e5c6a092535
md"""
### tricontour
"""

# ╔═╡ ee9a6fb2-3978-40f4-803b-7cb8d50b4fac
func=0.5*[sin(10*pts[1,i])*cos(10*pts[2,i]) for i=1:size(pts,2)];

# ╔═╡ c6d700ec-91a1-4ef7-a104-8574cc162b9a
tricontour(pts,tris,func;colormap=:viridis),
tricontour(pts,tris,func;colormap=:summer,levels=3)

# ╔═╡ 8b25e922-12db-4fae-8f28-65fe4faf40f3
tricontour(pts,tris,func;colormap=:hot,levels=-0.5:0.2:0.5)

# ╔═╡ dce20465-d227-4273-82b7-c6a4621942b9
md"""
Above, we have shown  three ways to specify isolines: 
- to have no isolines (default)
- a fixed number of automaticaly generated isolines
- a fixed range of isolines
Colormaps can be chosen from [ColorSchemes.jl](https://juliagraphics.github.io/ColorSchemes.jl/stable/basics/#Pre-defined-schemes)
"""

# ╔═╡ 20a88415-f2b4-4806-9ffc-6be979d12d0a
data(pts,t)=0.5*[sin(10*pts[1,i]-t)*cos(10*pts[2,i]-t)+t for i=1:size(pts,2)];

# ╔═╡ 39412087-3ee3-41fb-818f-23e5396abba3
p2=tricontour(resolution=(200,200))

# ╔═╡ 68cba79c-2577-4250-b045-08e954bde4e5
md"""
shift: $(@bind shift1 Slider(-8:0.1:8,show_value=true))
"""

# ╔═╡ d3055a1a-5b55-4c43-ac09-7704186e714a
tricontour!(p2,pts,tris,data(pts,shift1),colormap=:hot,levels=5)

# ╔═╡ 387bbdee-0175-4a25-9a97-49fdb8afb7fc
md"""
Alternatively, we can use the Plotly backend:
"""

# ╔═╡ 06fb9e66-c7c0-4028-80d9-2a7e36a6626d
md"""
### contour
A contour plot lives on a rectangular grid.
"""

# ╔═╡ 732b8e6a-68e0-4229-a2f9-52abe3ee5a40
md"""
shift: $(@bind shift Slider(-8:0.1:8,show_value=true))
"""

# ╔═╡ fe7fdb00-88a1-4d24-aedd-cedb6e50120b
f(x,y)=sqrt((x-shift)^2+(y-5)^2)*cos(x)*cos(y)

# ╔═╡ 5745f449-abc7-4f9a-a439-645698b781ea
X1=-10:0.1:10

# ╔═╡ 595539f8-f14e-418f-90d6-b6040292a9b6
Y1=0:0.1:10

# ╔═╡ 2eadced9-9e4a-4fa3-aea4-5f163933cb02
contour(X1,Y1,[f(x,y) for x∈X1, y∈Y1],resolution=(600,300),levels=-20:5:20 )

# ╔═╡ d1e13f8c-7cb8-4cb5-9dda-1a9b5d6142b6
md"""
## 3D Data
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

# ╔═╡ 0a363d31-5a48-49ad-aba2-bc0058ce1225
p3dgrid=tetmesh(resolution=(300,300))

# ╔═╡ da36cf26-8105-4569-9d09-6f16383000a0
md"""
x: $(@bind gxplane Slider(0:0.01:1,show_value=true,default=0.45))
y: $(@bind gyplane Slider(0:0.01:1,show_value=true,default=0.45))
z: $(@bind gzplane Slider(0:0.01:1,show_value=true,default=0.45))
"""

# ╔═╡ d009c4cb-9ef6-45bd-960f-0213880f662a
 tetmesh!(p3dgrid,g3[Coordinates],g3[CellNodes];
		markers=g3[CellRegions],
	faces=g3[BFaceNodes],
	facemarkers=g3[BFaceRegions],
	xplanes=[gxplane],yplanes=[gyplane],zplanes=[gzplane])

# ╔═╡ b33a9e6b-7c93-475c-96f4-7259b30c2c47
md"""
## tetcontour
"""

# ╔═╡ aded5964-8229-423c-b9f3-c80358b95fcc
f3=map(g3) do x,y,z
	sinpi(x/2)*cospi(y/2)*cospi(z/2)
end


# ╔═╡ 6af0b5d7-5324-43b5-8f99-6f5d35d5deba
TableOfContents()

# ╔═╡ 809ceb74-8201-4cc1-8cdc-656dc070e020
p3d=tetcontour(resolution=(300,300))

# ╔═╡ c222b16b-0ddc-4287-a029-779bdd77dd7b
md"""
f: $(@bind flevel Slider(0:0.01:1,show_value=true,default=0.45))

x: $(@bind xplane Slider(-2:0.01:2,show_value=true,default=-1.1))
y: $(@bind yplane Slider(-2:0.01:2,show_value=true,default=-1.1))
z: $(@bind zplane Slider(-2:0.01:2,show_value=true,default=-1.1))
"""

# ╔═╡ 36e48e9c-9452-4b07-bce4-c1cfe3c19409
tetcontour!(p3d,g3[Coordinates],g3[CellNodes],f3;levels=[flevel],
	xplanes=[xplane],yplanes=[yplane],zplanes=[zplane],levelalpha=0.7)

# ╔═╡ b074a389-bd07-4548-a75c-efa8c7663b15
html"""<hr>"""

# ╔═╡ Cell order:
# ╟─93ca4fd0-8f61-4174-b459-55f5395c0f56
# ╠═c102e87a-b570-4d86-b087-3506396fc065
# ╟─53f55db7-225f-4717-ab62-e024211e98a2
# ╟─b8a976e3-7fef-4527-ae6a-4da31c93a04f
# ╟─133d0c31-eea9-4200-88d2-4afdc61a16bd
# ╠═2e92c42c-2923-4f35-9d43-6e38eee3f8f6
# ╟─09cfb361-b897-40b1-8792-23b00151b995
# ╠═60dcfcf5-391e-418f-8e7c-3a0fe94f1e0d
# ╟─f44deb76-e715-477c-9e8a-dcf5cd68577f
# ╟─76d7a50d-40da-4367-a84f-3e2324e0c78d
# ╠═c3b719cd-5134-4395-8f36-4daab6ee3bf0
# ╠═cf9f4d1a-ebcd-4b59-bb0c-cc0d6b3239ca
# ╟─bdde2452-cf28-4d56-935c-693e6a1ca8a9
# ╟─d5240960-7759-48b8-94fd-3436f7b1573d
# ╠═b4afef75-450c-45a9-af8b-87224c3591e9
# ╠═0c8bc23a-cee1-4d6b-a63e-8f2391fc3f3c
# ╟─d0ea4e21-9d8c-416e-bf68-d7522e2ece20
# ╟─f15a91a4-a03b-4125-ba58-e44d9792a7e3
# ╠═ab232244-4fe2-4ab0-a0bf-d1d9510802d2
# ╠═d3ad0d4f-859d-44ac-a387-aac8d465cc6d
# ╟─83c7bffd-16c6-4cc7-8a68-87cbd739f3f4
# ╟─724495e1-d501-4a03-be88-16b644938afd
# ╟─da3bdabb-b81c-4c05-90cd-aee7b209e605
# ╠═83be4a71-4f01-4f70-9cbe-f4e9b9222428
# ╟─8186bd23-5727-4d87-805c-5e5c6a092535
# ╠═ee9a6fb2-3978-40f4-803b-7cb8d50b4fac
# ╠═c6d700ec-91a1-4ef7-a104-8574cc162b9a
# ╠═8b25e922-12db-4fae-8f28-65fe4faf40f3
# ╟─dce20465-d227-4273-82b7-c6a4621942b9
# ╠═20a88415-f2b4-4806-9ffc-6be979d12d0a
# ╠═39412087-3ee3-41fb-818f-23e5396abba3
# ╟─68cba79c-2577-4250-b045-08e954bde4e5
# ╠═d3055a1a-5b55-4c43-ac09-7704186e714a
# ╟─387bbdee-0175-4a25-9a97-49fdb8afb7fc
# ╟─06fb9e66-c7c0-4028-80d9-2a7e36a6626d
# ╟─732b8e6a-68e0-4229-a2f9-52abe3ee5a40
# ╠═2eadced9-9e4a-4fa3-aea4-5f163933cb02
# ╠═fe7fdb00-88a1-4d24-aedd-cedb6e50120b
# ╠═5745f449-abc7-4f9a-a439-645698b781ea
# ╠═595539f8-f14e-418f-90d6-b6040292a9b6
# ╟─d1e13f8c-7cb8-4cb5-9dda-1a9b5d6142b6
# ╟─a2bb8861-493d-4003-8a4e-e0ea051fbb72
# ╠═411d8975-f67a-4236-b827-c030675db91c
# ╠═b1f255ac-7347-4cf0-8ca1-491713fcb6b0
# ╠═0a363d31-5a48-49ad-aba2-bc0058ce1225
# ╟─da36cf26-8105-4569-9d09-6f16383000a0
# ╠═d009c4cb-9ef6-45bd-960f-0213880f662a
# ╠═b33a9e6b-7c93-475c-96f4-7259b30c2c47
# ╠═aded5964-8229-423c-b9f3-c80358b95fcc
# ╟─6af0b5d7-5324-43b5-8f99-6f5d35d5deba
# ╠═809ceb74-8201-4cc1-8cdc-656dc070e020
# ╟─c222b16b-0ddc-4287-a029-779bdd77dd7b
# ╠═36e48e9c-9452-4b07-bce4-c1cfe3c19409
# ╟─b074a389-bd07-4548-a75c-efa8c7663b15
# ╠═fdf728b9-ade9-46f3-8aaf-cf22aaaa55d2
