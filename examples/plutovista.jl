### A Pluto.jl notebook ###
# v0.19.20

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

# ╔═╡ f44deb76-e715-477c-9e8a-dcf5cd68577f
md"""
xscale $(@bind xscale Slider(1:0.1:10,show_value=true))

yscale: $(@bind yscale Slider(1:0.1:10,show_value=true)), 
"""

# ╔═╡ 60dcfcf5-391e-418f-8e7c-3a0fe94f1e0d
let
    p=PlutoVistaPlot(resolution=(500,300),titlefontsize=20)
	plot!(p,X,yscale*sin.(X*xscale);label="sin",color=:red,linestyle=:dashdot)
	plot!(p,X,cos.(X*xscale);label="cos",color=:green,linewidth=1,markertype=:star5)
	plot!(p,X,X./X[end];color=:blue,linestyle=:dash,title="test",legend=:rt,xlabel="x")
end

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
p3dgrid=tetmesh(resolution=(500,500))

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
### tetcontour
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

# ╔═╡ fdf728b9-ade9-46f3-8aaf-cf22aaaa55d2
md"""
# Un-Markdown this cell for debugging
begin
     using Pkg
     Pkg.activate(@__DIR__)
     using Revise
end;
""";

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
ExtendableGrids = "cfc395e8-590f-11e8-1f13-43a2532b2fa8"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
PlutoVista = "646e1f28-b900-46d7-9d87-d554eb38a413"
SimplexGridFactory = "57bfcd06-606e-45d6-baf4-4ba06da0efd5"
TetGen = "c5d3f3f7-f850-59f6-8a2e-ffc6dc1317ea"
Triangulate = "f7e6ffb2-c36d-4f8f-a77e-16e897189344"

[compat]
ExtendableGrids = "~0.9.16"
PlutoUI = "~0.7.49"
PlutoVista = "~0.8.16"
SimplexGridFactory = "~0.5.18"
TetGen = "~1.4.0"
Triangulate = "~2.2.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.5"
manifest_format = "2.0"
project_hash = "f8beeab34b190b6197d3011ecb1313d4d086b8e9"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.AbstractTrees]]
git-tree-sha1 = "faa260e4cb5aba097a73fab382dd4b5819d8ec8c"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.4"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "0310e08cb19f5da31d08341c6120c047598f5b9c"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.5.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "43b1a4a8f797c1cddadf60499a8a077d4af2cd2d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.7"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "c6d890a52d2c4d55d326439580c3b8d0875a77d9"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.7"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "38f7a08f19d8810338d4f5085211c7dfa5d5bdd8"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.4"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "9c209fb7536406834aa938fb149964b985de6c83"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.1"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Random", "SnoopPrecompile"]
git-tree-sha1 = "aa3edc8f8dea6cbfa176ee12f7c2fc82f0608ed3"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.20.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "600cc5508d66b78aae350f7accdb58763ac18589"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.10"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "fc08e5930ee9a4e03f84bfb5211cb54e7769758a"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.10"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "00a2cccc7f098ff3b66806862d275ca3db9e6e5a"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.5.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.1+0"

[[deps.Configurations]]
deps = ["ExproniconLite", "OrderedCollections", "TOML"]
git-tree-sha1 = "62a7c76dbad02fdfdaa53608104edf760938c4ca"
uuid = "5218b696-f38b-4ac9-8b61-a12ec717816d"
version = "0.17.4"

[[deps.DataAPI]]
git-tree-sha1 = "e8119c1a33d267e16108be441a287a6981ba1630"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.14.0"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e3290f2d49e661fbd94046d7e3726ffcb2d41053"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.4+0"

[[deps.ElasticArrays]]
deps = ["Adapt"]
git-tree-sha1 = "e1c40d78de68e9a2be565f0202693a158ec9ad85"
uuid = "fdbdab4c-e67f-52f5-8c3f-e7b388dad3d4"
version = "1.2.11"

[[deps.ExproniconLite]]
deps = ["Pkg", "TOML"]
git-tree-sha1 = "c2eb763acf6e13e75595e0737a07a0bec0ce2147"
uuid = "55351af7-c7e9-48d6-89ff-24e801d99491"
version = "0.7.11"

[[deps.ExtendableGrids]]
deps = ["AbstractTrees", "Dates", "DocStringExtensions", "ElasticArrays", "InteractiveUtils", "LinearAlgebra", "Printf", "Random", "SparseArrays", "StaticArrays", "Test", "WriteVTK"]
git-tree-sha1 = "310b903a560b7b18f63486ff93da1ded9cae1f15"
uuid = "cfc395e8-590f-11e8-1f13-43a2532b2fa8"
version = "0.9.16"

[[deps.Extents]]
git-tree-sha1 = "5e1e4c53fa39afe63a7d356e30452249365fba99"
uuid = "411431e0-e8b7-467b-b5e0-f676ba4f2910"
version = "0.1.1"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "7be5f99f7d15578798f338f5433b6c432ea8037b"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.16.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "9a0472ec2f5409db243160a8b030f94c380167a3"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.13.6"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.FuzzyCompletions]]
deps = ["REPL"]
git-tree-sha1 = "e16dd964b4dfaebcded16b2af32f05e235b354be"
uuid = "fb4132e2-a121-4a70-b8a1-d5b831dcdcc2"
version = "0.5.1"

[[deps.GPUArraysCore]]
deps = ["Adapt"]
git-tree-sha1 = "57f7cde02d7a53c9d1d28443b9f11ac5fbe7ebc9"
uuid = "46192b85-c4d5-4398-a991-12ede77f4527"
version = "0.1.3"

[[deps.GeoInterface]]
deps = ["Extents"]
git-tree-sha1 = "e07a1b98ed72e3cdd02c6ceaab94b8a606faca40"
uuid = "cf35fbd7-0cd7-5166-be24-54bfbe79505f"
version = "1.2.1"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "GeoInterface", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "fe9aea4ed3ec6afdfbeb5a4f39a2208909b162a6"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.5"

[[deps.GridVisualize]]
deps = ["ColorSchemes", "Colors", "DocStringExtensions", "ElasticArrays", "ExtendableGrids", "GeometryBasics", "GridVisualizeTools", "HypertextLiteral", "LinearAlgebra", "Observables", "OrderedCollections", "PkgVersion", "Printf", "StaticArrays"]
git-tree-sha1 = "15c3d40efa9c581f16fd534b42171ac2f93f2cd0"
uuid = "5eed8a63-0fb0-45eb-886d-8d5a387d12b8"
version = "0.6.3"

[[deps.GridVisualizeTools]]
deps = ["ColorSchemes", "Colors", "DocStringExtensions", "StaticArraysCore"]
git-tree-sha1 = "5964fd3e4080af45bfdbdaff75567759fd0367bd"
uuid = "5573ae12-3b76-41d9-b48c-81d0b6e61cc5"
version = "0.2.1"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "Dates", "IniFile", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "eb5aa5e3b500e191763d35198f859e4b40fff4a6"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.7.3"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.LazilyInitializedFields]]
git-tree-sha1 = "410fe4739a4b092f2ffe36fcb0dcc3ab12648ce1"
uuid = "0e77f7df-68c5-4e49-93ce-4cd80f5598bf"
version = "1.2.1"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c7cb1f5d892775ba13767a87c7ada0b980ea0a71"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+2"

[[deps.LightXML]]
deps = ["Libdl", "XML2_jll"]
git-tree-sha1 = "e129d9391168c677cd4800f5c0abb1ed8cb3794f"
uuid = "9c8b4983-aa76-5018-a973-4c85ecc9e179"
version = "0.9.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "946607f84feb96220f480e0422d3484c49c00239"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.19"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "cedb76b37bc5a6c702ade66be44f831fa23c681e"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.0"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "03a9b9718f5682ecb107ac9f7308991db4ce395b"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.7"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.MeshIO]]
deps = ["ColorTypes", "FileIO", "GeometryBasics", "Printf"]
git-tree-sha1 = "8be09d84a2d597c7c0c34d7d604c039c9763e48c"
uuid = "7269a6da-0436-5bbc-96c2-40638cbb6118"
version = "0.4.10"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.MsgPack]]
deps = ["Serialization"]
git-tree-sha1 = "a8cbf066b54d793b9a48c5daa5d586cf2b5bd43d"
uuid = "99f44e22-a591-53d1-9472-aa23ef4bd671"
version = "1.1.0"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Observables]]
git-tree-sha1 = "6862738f9796b3edc1c09d0890afce4eca9e7e93"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.5.4"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "6503b77492fd7fcb9379bf73cd31035670e3c509"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.3.3"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6e9dba33f9f2c44e08a020b0caf6903be540004"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.19+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "8175fc2b118a3755113c8e68084dc1a9e63c61ee"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.3"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "f6cf8e7944e50901594838951729a1861e668cb8"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.3.2"

[[deps.Pluto]]
deps = ["Base64", "Configurations", "Dates", "Distributed", "FileWatching", "FuzzyCompletions", "HTTP", "HypertextLiteral", "InteractiveUtils", "Logging", "MIMEs", "Markdown", "MsgPack", "Pkg", "PrecompileSignatures", "REPL", "RegistryInstances", "RelocatableFolders", "SnoopPrecompile", "Sockets", "TOML", "Tables", "URIs", "UUIDs"]
git-tree-sha1 = "772419a6e1d14ad9cc0fbaf57f2c2aa53c6eee90"
uuid = "c3e4b0f8-55cb-11ea-2926-15256bba5781"
version = "0.19.20"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "eadad7b14cf046de6eb41f13c9275e5aa2711ab6"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.49"

[[deps.PlutoVista]]
deps = ["ColorSchemes", "Colors", "DocStringExtensions", "GridVisualizeTools", "HypertextLiteral", "Pluto", "UUIDs"]
git-tree-sha1 = "5af654ba1660641b3b80614a7be7eacae4c49875"
uuid = "646e1f28-b900-46d7-9d87-d554eb38a413"
version = "0.8.16"

[[deps.PrecompileSignatures]]
git-tree-sha1 = "18ef344185f25ee9d51d80e179f8dad33dc48eb1"
uuid = "91cefc8d-f054-46dc-8f8c-26e11d7c5411"
version = "3.0.3"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RegistryInstances]]
deps = ["LazilyInitializedFields", "Pkg", "TOML", "Tar"]
git-tree-sha1 = "ffd19052caf598b8653b99404058fce14828be51"
uuid = "2792f1a3-b283-48e8-9a74-f99dce5104f3"
version = "0.1.0"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "90bc7a7c96410424509e4263e277e43250c05691"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.0"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "f94f779c94e58bf9ea243e77a37e16d9de9126bd"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.SimplexGridFactory]]
deps = ["DocStringExtensions", "ElasticArrays", "ExtendableGrids", "FileIO", "GridVisualize", "LinearAlgebra", "MeshIO", "Printf", "Test"]
git-tree-sha1 = "4566d826852b7815d34c7a8829679c6f15f4b2e7"
uuid = "57bfcd06-606e-45d6-baf4-4ba06da0efd5"
version = "0.5.18"

[[deps.SnoopPrecompile]]
deps = ["Preferences"]
git-tree-sha1 = "e760a70afdcd461cf01a575947738d359234665c"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.3"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "d75bda01f8c31ebb72df80a46c88b25d1c79c56d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.7"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "6954a456979f23d05085727adb17c4551c19ecd1"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.12"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6b7ba252635a5eff6a0b0664a41ee140a1c9e72a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "GPUArraysCore", "StaticArraysCore", "Tables"]
git-tree-sha1 = "b03a3b745aa49b566f128977a7dd1be8711c5e71"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.14"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "c79322d36826aa2f4fd8ecfa96ddb47b174ac78d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TetGen]]
deps = ["DocStringExtensions", "GeometryBasics", "LinearAlgebra", "Printf", "StaticArrays", "TetGen_jll"]
git-tree-sha1 = "d99fe468112a24feb36bcdac8c168f423de7e93c"
uuid = "c5d3f3f7-f850-59f6-8a2e-ffc6dc1317ea"
version = "1.4.0"

[[deps.TetGen_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9ceedd691bce040e24126a56354f20d71554a495"
uuid = "b47fdcd6-d2c1-58e9-bbba-c1cee8d8c179"
version = "1.5.3+0"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "94f38103c984f89cf77c402f2a68dbd870f8165f"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.11"

[[deps.Triangle_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "fe28e9a4684f6f54e868b9136afb8fd11f1734a7"
uuid = "5639c1d2-226c-5e70-8d55-b3095415a16a"
version = "1.6.2+0"

[[deps.Triangulate]]
deps = ["DocStringExtensions", "Libdl", "Printf", "Test", "Triangle_jll"]
git-tree-sha1 = "bbca6ec35426334d615f58859ad40c96d3a4a1f9"
uuid = "f7e6ffb2-c36d-4f8f-a77e-16e897189344"
version = "2.2.0"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.URIs]]
git-tree-sha1 = "ac00576f90d8a259f2c9d823e91d1de3fd44d348"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.WriteVTK]]
deps = ["Base64", "CodecZlib", "FillArrays", "LightXML", "TranscodingStreams"]
git-tree-sha1 = "f50c47d715199601a54afdd5267f24c8174842ae"
uuid = "64499a7a-5c06-52f2-abe2-ccb03c286192"
version = "1.16.0"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "93c41695bc1c08c46c5899f4fe06d6ead504bb73"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.10.3+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

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
# ╟─b33a9e6b-7c93-475c-96f4-7259b30c2c47
# ╠═aded5964-8229-423c-b9f3-c80358b95fcc
# ╟─6af0b5d7-5324-43b5-8f99-6f5d35d5deba
# ╠═809ceb74-8201-4cc1-8cdc-656dc070e020
# ╟─c222b16b-0ddc-4287-a029-779bdd77dd7b
# ╠═36e48e9c-9452-4b07-bce4-c1cfe3c19409
# ╟─b074a389-bd07-4548-a75c-efa8c7663b15
# ╠═fdf728b9-ade9-46f3-8aaf-cf22aaaa55d2
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
