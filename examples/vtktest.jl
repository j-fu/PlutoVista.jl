### A Pluto.jl notebook ###
# v0.16.0

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

# ╔═╡ 93ca4fd0-8f61-4174-b459-55f5395c0f56
md"""
# Test Notebook for [PlutoVista](https://github.com/j-fu/PlutoVista.jl)
"""

# ╔═╡ 2acd1978-03b1-4e8f-ba9f-2b3d58123613
develop=true

# ╔═╡ d6c0fb79-4129-444a-978a-bd2222b53df6
begin
    using Pkg
    Pkg.activate(mktempdir())
    Pkg.add(["PlutoUI","Triangulate"])
	Pkg.add("Revise");using Revise
    if develop	
	    Pkg.develop("PlutoVista")
    else
	    Pkg.add("PlutoVista")
    end	
    using PlutoUI
    using PlutoVista
    using Printf
    using Triangulate
end

# ╔═╡ 7c06fcf0-8c98-49f7-add8-435f57a9c9da
function maketriangulation(maxarea)
    triin=Triangulate.TriangulateIO()
    triin.pointlist=Matrix{Cdouble}([-1.0 -1.0 ; 1.0 -1.0 ; 1.0 2 ; -1.0 1.0]')
    triin.segmentlist=Matrix{Cint}([1 2 ; 2 3 ; 3 4 ; 4 1; 4 2 ]')
    triin.segmentmarkerlist=Vector{Int32}([1, 2, 3, 4, 6])
    triin.regionlist=Matrix{Cdouble}([-0.9 0.9; -0.9 0.9; 1 2 ; 2.0*maxarea maxarea])
    (triout, vorout)=triangulate("paADQ", triin)
    triout.pointlist, triout.trianglelist,Int.(vec(triout.triangleattributelist)),triout.segmentlist,triout.segmentmarkerlist
end

# ╔═╡ 60dcfcf5-391e-418f-8e7c-3a0fe94f1e0d
p=PlutoVTKPlot(resolution=(300,300))

# ╔═╡ db2823d9-aa6d-4be3-af5c-873c072cfd2b
md"""
Change grid resolution: $(@bind resolution Slider(5:200))
"""

# ╔═╡ 890710fe-dac0-4256-b1ba-79776f1ea7e5
(pts,tris,markers,edges,edgemarkers)=maketriangulation(1/resolution^2)

# ╔═╡ b8a976e3-7fef-4527-ae6a-4da31c93a04f
func=0.5*[sin(10*pts[1,i])*cos(10*pts[2,i]) for i=1:size(pts,2)]

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
	p=PlutoVTKPlot(resolution=(300,300))
	tricontour!(p,pts,tris,func;cmap=:spring,isolines=-0.5:0.1:0.5)
end

# ╔═╡ 7019ce3f-f2db-4581-8bd9-64f76231a62a
let
	p=PlutoVTKPlot(resolution=(300,300))
	trimesh!(p,pts,tris;markers=markers,edges=edges,edgemarkers=edgemarkers)
end

# ╔═╡ 1d19e6a0-118f-4b94-b9fb-3b16f98e31fc
markers

# ╔═╡ Cell order:
# ╟─93ca4fd0-8f61-4174-b459-55f5395c0f56
# ╠═2acd1978-03b1-4e8f-ba9f-2b3d58123613
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
# ╠═1d19e6a0-118f-4b94-b9fb-3b16f98e31fc
