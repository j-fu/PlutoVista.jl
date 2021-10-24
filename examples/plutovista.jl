### A Pluto.jl notebook ###
# v0.16.3

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

# ╔═╡ c102e87a-b570-4d86-b087-3506396fc065
begin
	using PlutoUI
	import Triangulate
	import TetGen
	using SimplexGridFactory
	using ExtendableGrids
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

# ╔═╡ fdf728b9-ade9-46f3-8aaf-cf22aaaa55d2
md"""
    begin using Pkg
       Pkg.activate(mktempdir())
       Pkg.add("Revise"); using Revise
       Pkg.add(["PlutoUI","Triangulate","ExtendableGrids",
	          "SimplexGridFactory","TetGen"])
	   Pkg.develop("PlutoVista")
    end
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
ExtendableGrids = "cfc395e8-590f-11e8-1f13-43a2532b2fa8"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
PlutoVista = "646e1f28-b900-46d7-9d87-d554eb38a413"
Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"
SimplexGridFactory = "57bfcd06-606e-45d6-baf4-4ba06da0efd5"
TetGen = "c5d3f3f7-f850-59f6-8a2e-ffc6dc1317ea"
Triangulate = "f7e6ffb2-c36d-4f8f-a77e-16e897189344"

[compat]
ExtendableGrids = "~0.8.7"
PlutoUI = "~0.7.16"
PlutoVista = "~0.8.4"
SimplexGridFactory = "~0.5.9"
TetGen = "~1.3.0"
Triangulate = "~2.1.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.0-rc2"
manifest_format = "2.0"

[[deps.AbstractTrees]]
git-tree-sha1 = "03e0550477d86222521d254b741d470ba17ea0b5"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.3.4"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "a851fec56cb73cfdf43762999ec72eff5b86882a"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.15.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[deps.DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "a32185f5428d3986f47c2ab78b1f216d5e6cc96f"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.5"

[[deps.Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

[[deps.ElasticArrays]]
deps = ["Adapt"]
git-tree-sha1 = "a0fcc1bb3c9ceaf07e1d0529c9806ce94be6adf9"
uuid = "fdbdab4c-e67f-52f5-8c3f-e7b388dad3d4"
version = "1.2.9"

[[deps.ExtendableGrids]]
deps = ["AbstractTrees", "Dates", "DocStringExtensions", "ElasticArrays", "InteractiveUtils", "LinearAlgebra", "Printf", "Random", "SparseArrays", "Test"]
git-tree-sha1 = "1e8e50f054057f23e908fbd6935766dca6293cc2"
uuid = "cfc395e8-590f-11e8-1f13-43a2532b2fa8"
version = "0.8.7"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "58bcdf5ebc057b085e58d95c138725628dd7453c"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.1"

[[deps.GridVisualize]]
deps = ["ColorSchemes", "Colors", "DocStringExtensions", "ElasticArrays", "ExtendableGrids", "GeometryBasics", "LinearAlgebra", "Observables", "OrderedCollections", "PkgVersion", "Printf", "Requires", "StaticArrays"]
git-tree-sha1 = "925ba2f11df005d894b113292d32fca9afe3f8c8"
uuid = "5eed8a63-0fb0-45eb-886d-8d5a387d12b8"
version = "0.3.9"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
git-tree-sha1 = "5efcf53d798efede8fee5b2c8b09284be359bf24"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.2"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IterTools]]
git-tree-sha1 = "05110a2ab1fc5f932622ffea2a003221f4782c18"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.3.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.Observables]]
git-tree-sha1 = "fe29afdef3d0c4a8286128d4e45cc50621b1e43d"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.4.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "f19e978f81eca5fd7620650d7dbea58f825802ee"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.1.0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "a7a7e1a88853564e551e4eba8650f8c38df79b37"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.1.1"

[[deps.PlutoUI]]
deps = ["Base64", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "4c8a7d080daca18545c56f1cac28710c362478f3"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.16"

[[deps.PlutoVista]]
deps = ["ColorSchemes", "Colors", "DocStringExtensions", "GridVisualize", "UUIDs"]
git-tree-sha1 = "29894b1c2258ae59a2af698d3f16dcfe683baa71"
uuid = "646e1f28-b900-46d7-9d87-d554eb38a413"
version = "0.8.4"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

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

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SimplexGridFactory]]
deps = ["DocStringExtensions", "ElasticArrays", "ExtendableGrids", "GridVisualize", "LinearAlgebra", "Printf", "Test"]
git-tree-sha1 = "af52ec74a4b6cfcc5b6d60d259099fa0596de2c1"
uuid = "57bfcd06-606e-45d6-baf4-4ba06da0efd5"
version = "0.5.9"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "3c76dde64d03699e074ac02eb2e8ba8254d428da"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.13"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "2ce41e0d042c60ecd131e9fb7154a3bfadbf50d3"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.3"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "fed34d0e71b91734bf0a7e10eb1bb05296ddbcd0"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.6.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TetGen]]
deps = ["DocStringExtensions", "GeometryBasics", "LinearAlgebra", "Printf", "StaticArrays", "TetGen_jll"]
git-tree-sha1 = "2f1d87ccacd2a7faf9e0bade918946ec4d90bfdf"
uuid = "c5d3f3f7-f850-59f6-8a2e-ffc6dc1317ea"
version = "1.3.0"

[[deps.TetGen_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bc67a0d0b799fe248b1f199a5c893ccf316f0e60"
uuid = "b47fdcd6-d2c1-58e9-bbba-c1cee8d8c179"
version = "1.5.2+0"

[[deps.Triangle_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bfdd9ef1004eb9d407af935a6f36a4e0af711369"
uuid = "5639c1d2-226c-5e70-8d55-b3095415a16a"
version = "1.6.1+0"

[[deps.Triangulate]]
deps = ["DocStringExtensions", "Libdl", "Printf", "Test", "Triangle_jll"]
git-tree-sha1 = "2b4f716b192c0c615d96d541ee029e85666388cb"
uuid = "f7e6ffb2-c36d-4f8f-a77e-16e897189344"
version = "2.1.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
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
# ╠═b33a9e6b-7c93-475c-96f4-7259b30c2c47
# ╠═aded5964-8229-423c-b9f3-c80358b95fcc
# ╟─6af0b5d7-5324-43b5-8f99-6f5d35d5deba
# ╠═809ceb74-8201-4cc1-8cdc-656dc070e020
# ╟─c222b16b-0ddc-4287-a029-779bdd77dd7b
# ╠═36e48e9c-9452-4b07-bce4-c1cfe3c19409
# ╟─b074a389-bd07-4548-a75c-efa8c7663b15
# ╠═fdf728b9-ade9-46f3-8aaf-cf22aaaa55d2
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
