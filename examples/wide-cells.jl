### A Pluto.jl notebook ###
# v0.17.1

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

# ╔═╡ ef41f6a0-60c0-4a86-9b6e-199b191309f1
md"""
begin

	using Pkg
	Pkg.add("Revise")
	using Revise
	Pkg.add(["HypertextLiteral","GridVisualize","PlutoUI"])
	Pkg.develop("PlutoVista")
end
""";	

# ╔═╡ 60941eaa-1aea-11eb-1277-97b991548781
begin 
    using PlutoUI
	using GridVisualize
	using PlutoVista
	using HypertextLiteral
	GridVisualize.default_plotter!(PlutoVista)
end;

# ╔═╡ 3ea2e28c-a323-4178-a0cf-b6b61d93672a
md"""
# Widening cells
Some js-bond-css magic from [Discourse](https://discourse.julialang.org/t/cell-width-in-pluto-notebook/49761/3)
"""

# ╔═╡ 04aa3674-60d9-40b0-9e88-5d2e14b42a0b
@bind screenWidth  ScreenWidthGrabber()

# ╔═╡ 80753ad4-3c10-41ce-ad70-6dad81266273
screenWidth

# ╔═╡ 8293eaf2-5664-4e66-bf62-f73689e3b747
PlutoCellWidener(0.9*screenWidth)

# ╔═╡ 49e13e08-3182-459c-9eb4-5d95b055a597
X0=0:0.25:10

# ╔═╡ a47d5ef4-d386-47db-8cac-965860d7ca32
scalarplot(X0,X0,X0, (x,y,z)->(sin(x)*sin(y)*sin(z)*sqrt(x*y*z)),resolution=(900,900),colormap=:rainbow)

# ╔═╡ 60a4d56f-9f53-4093-857b-62a05f2a3649
htl"""
<div style="display: inline-block;">
$(scalarplot(X0,X0,X0, (x,y,z)->(sin(0.1*x*y)*sin(z)),resolution=(200,200),colormap=:hot))
</div>
<div style="display: inline-block;">
$(scalarplot(X0,X0, (x,y)->sin(0.1*x*y),resolution=(200,200),colormap=:summer))
</div>
<div style="display: inline-block;">
$(scalarplot(X0,X0, (x,y)->sin(0.1*x*y),resolution=(200,200),colormap=:summer,backend=:plotly))
</div>
<div style="display: inline-block;">
$(scalarplot(X0, (x)->x*sin(2x),color=:red,resolution=(200,200),colormap=:summer))
</div>
"""

# ╔═╡ Cell order:
# ╠═60941eaa-1aea-11eb-1277-97b991548781
# ╟─3ea2e28c-a323-4178-a0cf-b6b61d93672a
# ╠═04aa3674-60d9-40b0-9e88-5d2e14b42a0b
# ╠═80753ad4-3c10-41ce-ad70-6dad81266273
# ╠═8293eaf2-5664-4e66-bf62-f73689e3b747
# ╟─49e13e08-3182-459c-9eb4-5d95b055a597
# ╠═a47d5ef4-d386-47db-8cac-965860d7ca32
# ╠═60a4d56f-9f53-4093-857b-62a05f2a3649
# ╠═ef41f6a0-60c0-4a86-9b6e-199b191309f1
