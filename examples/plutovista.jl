### A Pluto.jl notebook ###
# v0.14.7

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

# ╔═╡ d6c0fb79-4129-444a-978a-bd2222b53df6
begin
	using Pkg
    Pkg.activate(mktempdir())
	Pkg.add("Revise"); using Revise
    Pkg.add(["PlutoUI","Triangulate"])
    if haskey(ENV,"PLUTO_DEVEL")	
	    Pkg.develop("PlutoVista")
    else
	    Pkg.add(name="PlutoVista",url="https://github.com/j-fu/PlutoVista.jl")
    end	
end

# ╔═╡ c102e87a-b570-4d86-b087-3506396fc065
begin
	using PlutoUI
	import Triangulate
    using PlutoVista
    using Printf
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

# ╔═╡ f44deb76-e715-477c-9e8a-dcf5cd68577f
md"""
Modify xscale $(@bind xscale Slider(1:0.1:10,show_value=true)), yscale: $(@bind yscale Slider(1:0.1:10,show_value=true)), 
"""

# ╔═╡ 60dcfcf5-391e-418f-8e7c-3a0fe94f1e0d
let
	p=PlotlyPlot(resolution=(500,300))
	plot!(p,X,yscale*sin.(X*xscale);label="sin",color=:red,linestyle=:dashdot)
	plot!(p,X,cos.(X*xscale);label="cos",color=:green,linewidth=1,markertype=:star5)
	plot!(p,X,X./X[end];color=:blue,linestyle=:dash)
end

# ╔═╡ d0ea4e21-9d8c-416e-bf68-d7522e2ece20
md"""
## 2D Data

For 2D data, the package uses  [vtk.js](https://kitware.github.io/vtk-js/index.html)
as a backend and ths us uses GPU acceleration via the WebGL interface.
"""

# ╔═╡ f15a91a4-a03b-4125-ba58-e44d9792a7e3
md"""
### tricontour
Let us make a triangulation using the Triangulate.jl package, define a piecewise linear function on it and plot this function
"""

# ╔═╡ ab232244-4fe2-4ab0-a0bf-d1d9510802d2
function maketriangulation(maxarea)
    triin=Triangulate.TriangulateIO()
    triin.pointlist=Matrix{Cdouble}([-1.0 -1.0 ; 1.0 -1.0 ; 1.0 2 ; -1.0 1.0]')
    triin.segmentlist=Matrix{Cint}([1 2 ; 2 3 ; 3 4 ; 4 1 ]')
    triin.segmentmarkerlist=Vector{Int32}([1, 2, 3, 4])
    area=@sprintf("%.15f",maxarea)
    (triout, vorout)=Triangulate.triangulate("pa$(area)DQ", triin)
    triout.pointlist, triout.trianglelist
end

# ╔═╡ 724495e1-d501-4a03-be88-16b644938afd
md"""
Change grid resolution: $(@bind resolution Slider(10:200))
"""

# ╔═╡ d3ad0d4f-859d-44ac-a387-aac8d465cc6d
(pts,tris)=maketriangulation(1/resolution^2)

# ╔═╡ 83c7bffd-16c6-4cc7-8a68-87cbd739f3f4
md"""
The grid has $(size(pts,2)) points and $(size(tris,2))  triangles.
"""

# ╔═╡ ee9a6fb2-3978-40f4-803b-7cb8d50b4fac
func=0.5*[sin(10*pts[1,i])*cos(10*pts[2,i]) for i=1:size(pts,2)];

# ╔═╡ c6d700ec-91a1-4ef7-a104-8574cc162b9a
tricontour(pts,tris,func;colormap=:viridis),
tricontour(pts,tris,func;colormap=:summer,isolines=3)

# ╔═╡ 8b25e922-12db-4fae-8f28-65fe4faf40f3
tricontour(pts,tris,func;colormap=:hot,isolines=-0.5:0.2:0.5)

# ╔═╡ dce20465-d227-4273-82b7-c6a4621942b9
md"""
Above, we have shown  three ways to specify isolines: 
- to have no isolines (default)
- a fixed number of automaticaly generated isolines
- a fixed range of isolines
Colormaps can be chosen from [ColorSchemes.jl](https://juliagraphics.github.io/ColorSchemes.jl/stable/basics/#Pre-defined-schemes)
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
contour(X1,Y1,[f(x,y) for x∈X1, y∈Y1],resolution=(600,300),isolines=-20:5:20 )

# ╔═╡ d1e13f8c-7cb8-4cb5-9dda-1a9b5d6142b6
md"""
## 3D Data

Work in progress, based on vtk.js.
"""

# ╔═╡ dcda0fee-0614-4e9d-9be8-5ad04e4f22d8
html"""<hr size="5" noshade>"""

# ╔═╡ 6af0b5d7-5324-43b5-8f99-6f5d35d5deba
TableOfContents()

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
# ╟─d0ea4e21-9d8c-416e-bf68-d7522e2ece20
# ╟─f15a91a4-a03b-4125-ba58-e44d9792a7e3
# ╠═ab232244-4fe2-4ab0-a0bf-d1d9510802d2
# ╠═d3ad0d4f-859d-44ac-a387-aac8d465cc6d
# ╟─83c7bffd-16c6-4cc7-8a68-87cbd739f3f4
# ╠═ee9a6fb2-3978-40f4-803b-7cb8d50b4fac
# ╟─724495e1-d501-4a03-be88-16b644938afd
# ╠═c6d700ec-91a1-4ef7-a104-8574cc162b9a
# ╠═8b25e922-12db-4fae-8f28-65fe4faf40f3
# ╟─dce20465-d227-4273-82b7-c6a4621942b9
# ╟─06fb9e66-c7c0-4028-80d9-2a7e36a6626d
# ╟─732b8e6a-68e0-4229-a2f9-52abe3ee5a40
# ╠═2eadced9-9e4a-4fa3-aea4-5f163933cb02
# ╠═fe7fdb00-88a1-4d24-aedd-cedb6e50120b
# ╠═5745f449-abc7-4f9a-a439-645698b781ea
# ╠═595539f8-f14e-418f-90d6-b6040292a9b6
# ╟─d1e13f8c-7cb8-4cb5-9dda-1a9b5d6142b6
# ╟─dcda0fee-0614-4e9d-9be8-5ad04e4f22d8
# ╠═d6c0fb79-4129-444a-978a-bd2222b53df6
# ╟─6af0b5d7-5324-43b5-8f99-6f5d35d5deba