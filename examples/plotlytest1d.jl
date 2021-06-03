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
    Pkg.add(["PlutoUI","Colors"])
    if develop	
	    Pkg.develop("PlutoVista")
    else
	    Pkg.add(name="PlutoVista",url="https://github.com/j-fu/PlutoVista.jl")
    end	
    using PlutoUI,Colors
    using PlutoVista
    using Printf
end

# ╔═╡ b8a976e3-7fef-4527-ae6a-4da31c93a04f
X=0:0.001:10

# ╔═╡ f44deb76-e715-477c-9e8a-dcf5cd68577f
@bind t Slider(1:0.1:10)

# ╔═╡ 60dcfcf5-391e-418f-8e7c-3a0fe94f1e0d
let
	p=PlotlyPlot(resolution=(400,300))
	plot!(p,X,sin.(X*t);label="sin",color=:red,linestyle=:dashdot)
	plot!(p,X,cos.(X*t);label="cos",color=:green,linewidth=1,markertype=:star5)
	plot!(p,X,X./X[end];color=:blue,linestyle=:dash)
end

# ╔═╡ Cell order:
# ╟─93ca4fd0-8f61-4174-b459-55f5395c0f56
# ╠═2acd1978-03b1-4e8f-ba9f-2b3d58123613
# ╠═d6c0fb79-4129-444a-978a-bd2222b53df6
# ╠═b8a976e3-7fef-4527-ae6a-4da31c93a04f
# ╠═60dcfcf5-391e-418f-8e7c-3a0fe94f1e0d
# ╠═f44deb76-e715-477c-9e8a-dcf5cd68577f
