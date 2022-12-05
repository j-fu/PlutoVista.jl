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

# ╔═╡ dc111222-038e-479b-993e-5ed58755df27
begin
    using Pkg
    Pkg.activate(@__DIR__)
    using Revise
end

# ╔═╡ d6c0fb79-4129-444a-978a-bd2222b53df6
begin
    using PlutoUI
    using PlutoVista
    using Printf
	using LaTeXStrings
    import Triangulate
end

# ╔═╡ 93ca4fd0-8f61-4174-b459-55f5395c0f56
md"""
# Test Notebook for [PlutoVista](https://github.com/j-fu/PlutoVista.jl) and plotly.js
"""

# ╔═╡ 9072dcea-e634-493e-ba1a-890220737683
let X=collect(0:0.1:10); plot(X,sin.(X)) end

# ╔═╡ 763bdefc-200e-4afb-a6c9-71fb5ee16f58
let X=collect(0:0.1:10); plot(X,X.^2,xscale=:log,label="x", legend=:lt,legendfontsize=20) end

# ╔═╡ 4cd2182a-ea7c-49f6-a3f8-029b8727430f
let X=collect(0:0.1:100); plot(X,X.^2,yscale=:log,label="x",legend=:rb,tickfontsize=20) end

# ╔═╡ b9e1184b-62db-41c9-9340-b9db0aff5b78
 let X=collect(0:0.1:100); 
	p=PlutoVistaPlot(xscale=:log,yscale=:log,ylabel="x",xlabel="ψ",title="title",legend=:lt,axisfontsize=20)
	plot!(p,X,X.^2;color=:red,label="2") 
	plot!(p,X,X.^3,label="3")
	plot!(p,X,X.^4,label="4")  
end

# ╔═╡ ad1da8b8-723f-4b18-ba50-fb5a6d5d1176
 let X=collect(0:0.1:1000); 
	p=PlutoVistaPlot(dim=1,resolution=(600,300),title="title",titlefontsize=20,legend=:lt,xscale=:log,yscale=:log)
	plot!(p,X,X.^20,color=:red,label="2") 
	plot!(p,X,X.^30,label="3") 
plot!(p,X,X.^40,ylabel="y",xlabel="xxx",label="4") 
end

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
Change grid resolution: $(@bind resolution Slider(20:200))
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
	p=PlutoPlotlyPlot(resolution=(700,300))
	tricontour!(p,pts,tris,func,levels=11,colormap=:summer)
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
	contour!(p,collect(X1),collect(Y1),ff,colormap=:hot)
end

# ╔═╡ 5c23809b-9d92-43da-a85d-6c8531c3b547
let X=collect(0:0.1:10); plot(X,sin.(X)) end

# ╔═╡ edfe1dd2-94a5-403f-b589-53bfca839057
"\$x^k\$"

# ╔═╡ 9709e98a-50f3-4ee5-912c-e370c8c93193
 function fpdens(x::AbstractFloat;sample_size=1000) 
    xleft=x
    xright=x
    for i=1:sample_size
        xleft=prevfloat(xleft)
        xright=nextfloat(xright)
    end
    return prevfloat(2.0*sample_size/(xright-xleft))
end;


# ╔═╡ f8684eae-00c8-4e19-b638-5be32c045cfc
X=10.0.^collect(-40:0.1:40);

# ╔═╡ 7f5612f3-a0cb-4319-b4bf-4eefe5dc2a18
let
    p=plot(resolution=(600,300),
		title="Number of numbers per unit interval",
		xscale=:log,yscale=:log,xlabel="x",ylabel="n",legend=:rt)
    plot!(p,X,map(x->1.0e20/x,X), label="O(1/x)",linewidth=0.5,color=:black,linestyle=:dot)
    plot!(p,X,fpdens.(Float16.(X)),label="Float16")
    plot!(p,X,fpdens.(Float32.(X)),label="Float32")
    plot!(p,X,fpdens.(Float64.(X)),label="Float64")
    plot!(p,X,map(x-> x<typemax(Int8) ? 1  : 0,X),
		linestyle=:dash,label="Int8")
    plot!(p,X,map(x-> x<typemax(Int32) ,X),
		linestyle=:dash,label="Int32")
    plot!(p,X,map(x-> x<typemax(Int64) ? 1 : 0,X),
		linestyle=:dash,label="Int64")
    plot!(p,X,map(x-> x<typemax(Int16) ? 1 : 0,X),
		linestyle=:dash,color=:black,label="Int16")
end

# ╔═╡ 88fd8e90-e054-4dd4-858d-7367b590b89d
html"""<hr>"""

# ╔═╡ Cell order:
# ╟─93ca4fd0-8f61-4174-b459-55f5395c0f56
# ╠═d6c0fb79-4129-444a-978a-bd2222b53df6
# ╠═9072dcea-e634-493e-ba1a-890220737683
# ╠═763bdefc-200e-4afb-a6c9-71fb5ee16f58
# ╠═4cd2182a-ea7c-49f6-a3f8-029b8727430f
# ╠═b9e1184b-62db-41c9-9340-b9db0aff5b78
# ╠═ad1da8b8-723f-4b18-ba50-fb5a6d5d1176
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
# ╠═5c23809b-9d92-43da-a85d-6c8531c3b547
# ╠═edfe1dd2-94a5-403f-b589-53bfca839057
# ╠═9709e98a-50f3-4ee5-912c-e370c8c93193
# ╠═f8684eae-00c8-4e19-b638-5be32c045cfc
# ╠═7f5612f3-a0cb-4319-b4bf-4eefe5dc2a18
# ╟─88fd8e90-e054-4dd4-858d-7367b590b89d
# ╠═dc111222-038e-479b-993e-5ed58755df27
