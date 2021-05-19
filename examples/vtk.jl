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
	Pkg.add("Revise")
	using Revise
	Pkg.add("PlutoUI")
	Pkg.add("Triangulate")
	Pkg.develop("PlutoVTKPlot")
	using PlutoUI
	using UUIDs
	using Printf
	using Triangulate
	using PlutoVTKPlot
end

# ╔═╡ 75fbe996-b746-11eb-3551-c3a5944c312c
loadvtk()

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
@bind resolution Slider(5:1000)

# ╔═╡ 890710fe-dac0-4256-b1ba-79776f1ea7e5
(pts,tris)=maketriangulation(1/resolution^2)

# ╔═╡ b8a976e3-7fef-4527-ae6a-4da31c93a04f
func=0.2*[sin(10*pts[1,i])*cos(10*pts[2,i]) for i=1:size(pts,2)]

# ╔═╡ 60dcfcf5-391e-418f-8e7c-3a0fe94f1e0d
let
	p=VTKPlot(resolution=(600,300))
	triplot!(p,pts,tris,func)
end

# ╔═╡ Cell order:
# ╠═d6c0fb79-4129-444a-978a-bd2222b53df6
# ╠═75fbe996-b746-11eb-3551-c3a5944c312c
# ╠═7c06fcf0-8c98-49f7-add8-435f57a9c9da
# ╠═890710fe-dac0-4256-b1ba-79776f1ea7e5
# ╠═b8a976e3-7fef-4527-ae6a-4da31c93a04f
# ╠═60dcfcf5-391e-418f-8e7c-3a0fe94f1e0d
# ╠═db2823d9-aa6d-4be3-af5c-873c072cfd2b
