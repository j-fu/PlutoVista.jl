### A Pluto.jl notebook ###
# v0.19.0

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

# ╔═╡ d6c0fb79-4129-444a-978a-bd2222b53df6
begin
    using PlutoUI
    using PlutoVista
    using GridVisualize
    using Printf
    using Triangulate
	using ExtendableGrids
end

# ╔═╡ 93ca4fd0-8f61-4174-b459-55f5395c0f56
md"""
# Test Notebook for [PlutoVista](https://github.com/j-fu/PlutoVista.jl) and [vtk.js](https://kitware.github.io/vtk-js/index.html)
"""

# ╔═╡ 7c06fcf0-8c98-49f7-add8-435f57a9c9da
function maketriangulation(maxarea)
    triin=Triangulate.TriangulateIO()
    triin.pointlist=Matrix{Cdouble}([-1.0 -1.0 ; 1.0 -1.0 ; 1.0 2 ; -1.0 1.0]')
    triin.segmentlist=Matrix{Cint}([1 2 ; 2 3 ; 3 4 ; 4 1; 4 2 ]')
    triin.segmentmarkerlist=Vector{Int32}([1, 2, 3, 4, 5])
    triin.regionlist=Matrix{Cdouble}([-0.9 0.9; -0.9 0.9; 1 2 ; 2.0*maxarea maxarea])
    (triout, vorout)=triangulate("paADQ", triin)
    triout.pointlist, triout.trianglelist,Int.(vec(triout.triangleattributelist)),triout.segmentlist,triout.segmentmarkerlist
end

# ╔═╡ 60dcfcf5-391e-418f-8e7c-3a0fe94f1e0d
p=PlutoVTKPlot(resolution=(300,300),tickfontsize=10)

# ╔═╡ db2823d9-aa6d-4be3-af5c-873c072cfd2b
md"""
Change grid resolution: $(@bind resolution Slider(5:200))
"""

# ╔═╡ 890710fe-dac0-4256-b1ba-79776f1ea7e5
(pts,tris,markers,edges,edgemarkers)=maketriangulation(1/resolution^2)

# ╔═╡ b8a976e3-7fef-4527-ae6a-4da31c93a04f
func=0.5.+0.5*[sin(10*pts[1,i])*cos(10*pts[2,i]) for i=1:size(pts,2)]

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
	p=PlutoVTKPlot(resolution=(300,300),axisfontsize=20)
	tricontour!(p,pts,tris,func;cmap=:spring,levels=(0.1:0.2:1),limits=(0,1),xlabel="a",aspect=1.5)
end

# ╔═╡ 7019ce3f-f2db-4581-8bd9-64f76231a62a
let
	p=PlutoVTKPlot(resolution=(300,300),legendfontsize=15)
	trimesh!(p,pts,tris;
		markers=markers,
		edges=edges,edgemarkers=edgemarkers
	)
end

# ╔═╡ 2e3546f6-eb47-4693-aa00-902570fab7b5
function grid3d(;n=15)
    X=collect(0:1/n:1)
    g=simplexgrid(X,X,X)
end

# ╔═╡ bd0a59a2-564d-42bd-ab6f-a50b26f9241f
function func3d(;n=15)
    g=grid3d(n=n)
    g, map((x,y,z)->sinpi(2*x)*sinpi(3.5*y)*sinpi(1.5*z),g)
end

# ╔═╡ 368b8cf5-fabd-4b84-b33c-b15c4452393b
	g,f=func3d(;n=20)

# ╔═╡ f64729e4-d2b4-40d3-acbb-1395dbe0337d
p3d=PlutoVTKPlot(resolution=(300,300))

# ╔═╡ 7be35f33-5f7a-4765-8bb6-1487e209efc8
md"""
f: $(@bind flevel Slider(0:0.01:1,show_value=true,default=0.45))

x: $(@bind xplane Slider(0:0.01:1,show_value=true,default=0.45))
y: $(@bind yplane Slider(0:0.01:1,show_value=true,default=0.45))
z: $(@bind zplane Slider(0:0.01:1,show_value=true,default=0.45))
"""

# ╔═╡ 3681ef5b-c794-44da-9fe7-cedcd68b426c
tetcontour!(p3d,g[Coordinates],g[CellNodes],f;levels=[flevel],
	faces=g[BFaceNodes],
	facemarkers=g[BFaceRegions],
	xplanes=[xplane],yplanes=[yplane],zplanes=[zplane],outlinealpha=0.1, levelalpha=0.25)

# ╔═╡ 0f440c27-7ff1-4db5-b4eb-8ce1e9018ef1
g[BFaceNodes]

# ╔═╡ 606f6837-f3b7-4a52-b9c3-034799c7bf93
g3x=let
	n=10
X=collect(0:1/n:1)
simplexgrid(X,X,X)
end

# ╔═╡ ecb3bb5e-6ae5-4d6e-9834-d52ce977b3fc
p3dx=PlutoVTKPlot(resolution=(300,300))

# ╔═╡ 90ff6ffc-84dc-45fd-8d09-9eb916397630
 md"""
x: $(@bind gxplane Slider(0:0.01:1,show_value=true,default=0.45))
y: $(@bind gyplane Slider(0:0.01:1,show_value=true,default=0.45))
z: $(@bind gzplane Slider(0:0.01:1,show_value=true,default=0.45))
"""

# ╔═╡ ae5707d9-41b7-4937-924a-fb54b83c31db
alpha=0.15

# ╔═╡ 519d106f-3f6f-4db1-b4e4-c5e7ef176857
tetmesh!(p3dx,g3x[Coordinates],g3x[CellNodes];
		markers=g3x[CellRegions],
	faces=g3x[BFaceNodes],
	facemarkers=g3x[BFaceRegions],
	xplanes=gxplane,yplanes=gyplane,zplanes=gzplane,outlinealpha=0)

# ╔═╡ 4263e897-d878-4fab-acae-a6c4dae37c5e
qp=PlutoVTKPlot(resolution=(500,500))

# ╔═╡ 5dfb1dde-06ed-483a-bac3-6a21a7f98856
@bind x0 Slider(1:0.01:9)

# ╔═╡ 6d7547c6-5667-463f-99dc-2f3fbaeb4c4d
let
	n=50
	X=0:10/n:10
	g=simplexgrid(X,X)
	pts=g[Coordinates]
    f(x,y)=sin(x-x0)*cos(y)+0.05*(x-x0)*y
    fx(x,y)=-cos(x-x0)*cos(y)-0.05*y
    fy(x,y)=sin(x-x0)*sin(y)-0.05*(x-x0)
    v=map(f,g)
    ∇v=0.5*vcat(map(fx,g)',map(fy,g)')
	
	tricontour!(qp,pts,g[CellNodes],v,colormap=:summer,levels=5)
	quiver2d!(qp,pts,∇v)
end

# ╔═╡ 23c75823-e69f-4ca0-a3ca-783612ba9c3c
html"""<hr>"""

# ╔═╡ 08980845-f030-4a64-a4b2-ab027b3a2721
md"""
begin  
     using Pkg
     Pkg.activate(@__DIR__)
     using Revise
end	
""";

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
ExtendableGrids = "cfc395e8-590f-11e8-1f13-43a2532b2fa8"
GridVisualize = "5eed8a63-0fb0-45eb-886d-8d5a387d12b8"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
PlutoVista = "646e1f28-b900-46d7-9d87-d554eb38a413"
Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"
Triangulate = "f7e6ffb2-c36d-4f8f-a77e-16e897189344"

[compat]
ExtendableGrids = "~0.9.5"
GridVisualize = "~0.5.1"
PlutoUI = "~0.7.38"
PlutoVista = "~0.8.12"
Triangulate = "~2.1.2"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.0-beta3"
manifest_format = "2.0"
project_hash = "8ebdeb5ccee73337f5297866af2989bf2aeb84c1"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.AbstractTrees]]
git-tree-sha1 = "03e0550477d86222521d254b741d470ba17ea0b5"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.3.4"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "af92965fb30777147966f58acb05da51c5616b5f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.3"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "12fc73e5e0af68ad3137b886e3f7c1eacfca2640"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.17.1"

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
version = "0.5.2+0"

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
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

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
deps = ["AbstractTrees", "Dates", "DocStringExtensions", "ElasticArrays", "InteractiveUtils", "LinearAlgebra", "Printf", "Random", "SparseArrays", "StaticArrays", "Test", "WriteVTK"]
git-tree-sha1 = "cec19e62fc126df338de88585f45a763f7601bd3"
uuid = "cfc395e8-590f-11e8-1f13-43a2532b2fa8"
version = "0.9.5"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "246621d23d1f43e3b9c368bf3b72b2331a27c286"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.13.2"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "83ea630384a13fc4f002b77690bc0afeb4255ac9"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.2"

[[deps.GridVisualize]]
deps = ["ColorSchemes", "Colors", "DocStringExtensions", "ElasticArrays", "ExtendableGrids", "GeometryBasics", "HypertextLiteral", "LinearAlgebra", "Observables", "OrderedCollections", "PkgVersion", "Printf", "StaticArrays"]
git-tree-sha1 = "5d845bccf5d690879f4f5f01c7112e428b1fa543"
uuid = "5eed8a63-0fb0-45eb-886d-8d5a387d12b8"
version = "0.5.1"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

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

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.81.0+0"

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
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[deps.LightXML]]
deps = ["Libdl", "XML2_jll"]
git-tree-sha1 = "e129d9391168c677cd4800f5c0abb1ed8cb3794f"
uuid = "9c8b4983-aa76-5018-a973-4c85ecc9e179"
version = "0.9.0"

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
version = "2.28.0+0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Observables]]
git-tree-sha1 = "fe29afdef3d0c4a8286128d4e45cc50621b1e43d"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.4.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "621f4f3b4977325b9128d5fae7a8b4829a0c2222"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.2.4"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "a7a7e1a88853564e551e4eba8650f8c38df79b37"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.1.1"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "670e559e5c8e191ded66fa9ea89c97f10376bb4c"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.38"

[[deps.PlutoVista]]
deps = ["ColorSchemes", "Colors", "DocStringExtensions", "GridVisualize", "HypertextLiteral", "UUIDs"]
git-tree-sha1 = "2435d1d3e02db324414f268f30999b5c06a0d10f"
uuid = "646e1f28-b900-46d7-9d87-d554eb38a413"
version = "0.8.12"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "d3538e7f8a790dc8903519090857ef8e1283eecd"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.5"

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

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "4f6ec5d99a28e1a749559ef7dd518663c5eca3d5"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.4.3"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "57617b34fa34f91d536eb265df67c2d4519b8b98"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.5"

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
git-tree-sha1 = "5ce79ce186cc678bbb5c5681ca3379d1ddae11a1"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.7.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[deps.Triangle_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bfdd9ef1004eb9d407af935a6f36a4e0af711369"
uuid = "5639c1d2-226c-5e70-8d55-b3095415a16a"
version = "1.6.1+0"

[[deps.Triangulate]]
deps = ["DocStringExtensions", "Libdl", "Printf", "Test", "Triangle_jll"]
git-tree-sha1 = "ffa6491b39ad78fd977e3b09fc6a21f28d82a4ae"
uuid = "f7e6ffb2-c36d-4f8f-a77e-16e897189344"
version = "2.1.2"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.WriteVTK]]
deps = ["Base64", "CodecZlib", "FillArrays", "LightXML", "TranscodingStreams"]
git-tree-sha1 = "bff2f6b5ff1e60d89ae2deba51500ce80014f8f6"
uuid = "64499a7a-5c06-52f2-abe2-ccb03c286192"
version = "1.14.2"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "1acf5bdf07aa0907e0a37d3718bb88d4b687b74a"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.12+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.41.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "16.2.1+1"
"""

# ╔═╡ Cell order:
# ╟─93ca4fd0-8f61-4174-b459-55f5395c0f56
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
# ╠═2e3546f6-eb47-4693-aa00-902570fab7b5
# ╠═bd0a59a2-564d-42bd-ab6f-a50b26f9241f
# ╠═368b8cf5-fabd-4b84-b33c-b15c4452393b
# ╠═f64729e4-d2b4-40d3-acbb-1395dbe0337d
# ╟─7be35f33-5f7a-4765-8bb6-1487e209efc8
# ╠═3681ef5b-c794-44da-9fe7-cedcd68b426c
# ╠═0f440c27-7ff1-4db5-b4eb-8ce1e9018ef1
# ╠═606f6837-f3b7-4a52-b9c3-034799c7bf93
# ╠═ecb3bb5e-6ae5-4d6e-9834-d52ce977b3fc
# ╠═90ff6ffc-84dc-45fd-8d09-9eb916397630
# ╠═ae5707d9-41b7-4937-924a-fb54b83c31db
# ╠═519d106f-3f6f-4db1-b4e4-c5e7ef176857
# ╠═4263e897-d878-4fab-acae-a6c4dae37c5e
# ╠═5dfb1dde-06ed-483a-bac3-6a21a7f98856
# ╠═6d7547c6-5667-463f-99dc-2f3fbaeb4c4d
# ╟─23c75823-e69f-4ca0-a3ca-783612ba9c3c
# ╠═08980845-f030-4a64-a4b2-ab027b3a2721
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
