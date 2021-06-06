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
	Pkg.add("Revise"); using Revise
    Pkg.add(["PlutoUI","Triangulate"])
    if develop	
	    Pkg.develop("PlutoVista")
    else
	    Pkg.add(name="PlutoVista",url="https://github.com/j-fu/PlutoVista.jl")
    end	
    using PlutoUI
    using PlutoVista
    using Printf
    import Triangulate
end

# ╔═╡ 9072dcea-e634-493e-ba1a-890220737683
plot([1,2],[1,2])

# ╔═╡ 7c06fcf0-8c98-49f7-add8-435f57a9c9da
function maketriangulation(maxarea)
	
    triin=Triangulate.TriangulateIO()
    triin.pointlist=Matrix{Cdouble}([-1.0 -1.0 ; 1.0 -1.0 ; 1.5  1.5 ; -1.0 1.0]')
    triin.segmentlist=Matrix{Cint}([1 2 ; 2 3 ; 3 4 ; 4 1 ]')
    triin.segmentmarkerlist=Vector{Int32}([1, 2, 3, 4])
    area=@sprintf("%.15f",maxarea)
    (triout, vorout)=Triangulate.triangulate("pa$(area)DQ", triin)
    triout.pointlist, triout.trianglelist
end

# ╔═╡ db2823d9-aa6d-4be3-af5c-873c072cfd2b
md"""
Change grid resolution: $(@bind resolution Slider(5:200))
"""

# ╔═╡ 890710fe-dac0-4256-b1ba-79776f1ea7e5
(pts,tris)=maketriangulation(1/resolution^2)

# ╔═╡ b8a976e3-7fef-4527-ae6a-4da31c93a04f
func=0.5*[sin(10*pts[1,i])*cos(10*pts[2,i])*10*pts[1,i] for i=1:size(pts,2)]

# ╔═╡ 60dcfcf5-391e-418f-8e7c-3a0fe94f1e0d
p=let
	p=PlutoPlotlyPlot(resolution=(500,300))
	triplot!(p,pts,tris,func)
end

# ╔═╡ 401b36bd-fa8f-4a9c-9556-bbc82c3ddbca
md"""
Change time: $(@bind time Slider(0:0.1:10,show_value=true))
"""

# ╔═╡ e76f8a6a-ab91-454a-b200-cfc8b57eb331
triupdate!(p,pts,tris,0.5*[sin(10*pts[1,i]-time)*cos(10*pts[2,i]-time) for i=1:size(pts,2)])

# ╔═╡ bce0cfe7-4112-4bb8-aac6-43885f3746a9
md"""Number of gridpoints: $(size(pts,2)) """

# ╔═╡ 81046dcd-3cfb-4133-943f-61b9b3cdb183
let
	p=PlutoPlotlyPlot(resolution=(500,300))
	tricontour!(p,pts,tris,func,isolines=10,colormap=:rainbow)
end

# ╔═╡ e900801e-2020-4aff-bfec-017ad6fcfdcf
md"""
shift: $(@bind shift Slider(-1:0.01:1,show_value=true))
"""


# ╔═╡ 5cb73674-c144-4fd9-8ff6-ac767548822e
f(x,y)=sin(3(x-shift))*cos(3(y-shift))*10

# ╔═╡ 34072263-1180-4bc0-a004-2f112ea4cbed
let
	X1=-2:0.1:2
	Y1=-1:0.1:1
	ff=[f(x,y) for x∈ X1, y∈ Y1]
	p=PlutoPlotlyPlot(resolution=(500,300))
	contour!(p,collect(X1),collect(Y1),ff; colormap=:hot,isolines=-10:2:10)
end

# ╔═╡ Cell order:
# ╟─93ca4fd0-8f61-4174-b459-55f5395c0f56
# ╠═2acd1978-03b1-4e8f-ba9f-2b3d58123613
# ╠═d6c0fb79-4129-444a-978a-bd2222b53df6
# ╠═9072dcea-e634-493e-ba1a-890220737683
# ╠═7c06fcf0-8c98-49f7-add8-435f57a9c9da
# ╠═890710fe-dac0-4256-b1ba-79776f1ea7e5
# ╠═b8a976e3-7fef-4527-ae6a-4da31c93a04f
# ╠═60dcfcf5-391e-418f-8e7c-3a0fe94f1e0d
# ╟─db2823d9-aa6d-4be3-af5c-873c072cfd2b
# ╟─401b36bd-fa8f-4a9c-9556-bbc82c3ddbca
# ╠═e76f8a6a-ab91-454a-b200-cfc8b57eb331
# ╟─bce0cfe7-4112-4bb8-aac6-43885f3746a9
# ╠═81046dcd-3cfb-4133-943f-61b9b3cdb183
# ╟─e900801e-2020-4aff-bfec-017ad6fcfdcf
# ╠═5cb73674-c144-4fd9-8ff6-ac767548822e
# ╠═34072263-1180-4bc0-a004-2f112ea4cbed
