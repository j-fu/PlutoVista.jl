### A Pluto.jl notebook ###
# v0.14.5

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
	# Pkg.add("Revise");	using Revise
	Pkg.add("PlutoUI")
	Pkg.add("Triangulate")
	Pkg.add(name="PlutoVTKPlot",version="0.0.2")
#	Pkg.develop("PlutoVTKPlot")
	using PlutoUI
	using UUIDs
	using Printf
	using Triangulate
	using PlutoVTKPlot
end

# ╔═╡ 93ca4fd0-8f61-4174-b459-55f5395c0f56
md"""
Test Notebook for [PlutoVTKPlot](https://github.com/j-fu/PlutoVTKPlot.jl)

So far, this package is in an early state. The current version  of the code is available via the registry `https://github.com/j-fu/PackageNursery.git` .

So, in order to run this notebook, you need to add this registry to you Julia environment.

```
pkg> registry add https://github.com/j-fu/PackageNursery.jl.git
```

This step can be safely undone by removing `.julia/registries/PackageNursery` in your
Julia folder.



"""

# ╔═╡ 7c06fcf0-8c98-49f7-add8-435f57a9c9da
function maketriangulation(maxarea)
	
    triin=Triangulate.TriangulateIO()
    triin.pointlist=Matrix{Cdouble}([-1.0 -1.0 ; 1.0 -1.0 ; 1.0  1.0 ; -1.0 1.0]')
    triin.segmentlist=Matrix{Cint}([1 2 ; 2 3 ; 3 4 ; 4 1 ]')
    triin.segmentmarkerlist=Vector{Int32}([1, 2, 3, 4])
    area=@sprintf("%.15f",maxarea)
    (triout, vorout)=triangulate("pa$(area)DQ", triin)
    triout.pointlist, triout.trianglelist
end

# ╔═╡ db2823d9-aa6d-4be3-af5c-873c072cfd2b
@bind resolution Slider(5:200)

# ╔═╡ 890710fe-dac0-4256-b1ba-79776f1ea7e5
(pts,tris)=maketriangulation(1/resolution^2)

# ╔═╡ b8a976e3-7fef-4527-ae6a-4da31c93a04f
func=0.5*[sin(10*pts[1,i])*cos(10*pts[2,i]) for i=1:size(pts,2)]

# ╔═╡ 60dcfcf5-391e-418f-8e7c-3a0fe94f1e0d
let
	p=VTKPlot(resolution=(600,400))
	triplot!(p,pts,tris,func)
	axis3d!(p; xtics=-1:1,ytics=-1:1,ztics=extrema(func))
end

# ╔═╡ bce0cfe7-4112-4bb8-aac6-43885f3746a9
size(pts,2)

# ╔═╡ 81046dcd-3cfb-4133-943f-61b9b3cdb183
let
	p=VTKPlot(resolution=(400,400))
	tricolor!(p,pts,tris,func;cmap=:spring)
	axis2d!(p; xtics=-1:1,ytics=-1:1)
end

# ╔═╡ Cell order:
# ╟─93ca4fd0-8f61-4174-b459-55f5395c0f56
# ╠═d6c0fb79-4129-444a-978a-bd2222b53df6
# ╠═7c06fcf0-8c98-49f7-add8-435f57a9c9da
# ╠═890710fe-dac0-4256-b1ba-79776f1ea7e5
# ╠═b8a976e3-7fef-4527-ae6a-4da31c93a04f
# ╠═60dcfcf5-391e-418f-8e7c-3a0fe94f1e0d
# ╠═db2823d9-aa6d-4be3-af5c-873c072cfd2b
# ╠═bce0cfe7-4112-4bb8-aac6-43885f3746a9
# ╠═81046dcd-3cfb-4133-943f-61b9b3cdb183
