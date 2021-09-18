"""
Structure containig plot information. 
In particular it contains dict of data sent to javascript.
"""
mutable struct PlutoVTKPlot  <: AbstractPlutoVistaBackend
    # command list passed to javascript
    jsdict::Dict{String,Any}

    # size in canvas coordinates
    w::Float64
    h::Float64

    update::Bool
    # uuid for identifying html element
    uuid::UUID
    PlutoVTKPlot(::Nothing)=new()
end

"""
````
    PlutoVTKPlot(;resolution=(300,300))
````

Create a canvas plot with given resolution in the notebook
and given "world coordinate" range.
"""
function PlutoVTKPlot(;resolution=(300,300), kwargs...)
    p=PlutoVTKPlot(nothing)
    p.uuid=uuid1()
    p.jsdict=Dict{String,Any}("cmdcount" => 0,"cbar" => 0)
    p.w=resolution[1]
    p.h=resolution[2]
    p.update=false
    p
end

"""
    axis3d!(vtkplot)
Add 3D coordinate system axes to the plot.
Sets camera handling to 3D mode.
"""
function axis3d!(p::PlutoVTKPlot)
    command!(p,"axis")
    parameter!(p,"cam","3D")
end

"""
    axis2d!(vtkplot)
Add 2D coordinate system axes to the plot.
Sets camera handling to 2D mode.
"""
function axis2d!(p::PlutoVTKPlot)
    command!(p,"axis")
    parameter!(p,"cam","2D")
end


function Base.show(io::IO, ::MIME"text/html", p::PlutoVTKPlot)
    plutovtkplot = read(joinpath(@__DIR__, "..", "assets", "plutovtkplot.js"), String)
    canvascolorbar = read(joinpath(@__DIR__, "..", "assets", "canvascolorbar.js"), String)
    uuidcbar="$(p.uuid)"*"cbar"
    div=""

    if !p.update
    div="""
        <p>
        <div style="white-space:nowrap;">
        <div id="$(p.uuid)" style= "width: $(p.w)px; height: $(p.h)px; display: inline-block; "></div>
        <canvas id="$(uuidcbar)" width=60, height="$(p.h)"  style="display: inline-block; "></canvas>
        </div>
        </p>
    """
    end
    result="""
        <script type="text/javascript" src="https://unpkg.com/vtk.js@19"></script>
        <script>
        $(plutovtkplot)
        $(canvascolorbar)
        const jsdict = $(Main.PlutoRunner.publish_to_js(p.jsdict))
        plutovtkplot("$(p.uuid)",jsdict,invalidation)
        canvascolorbar("$(uuidcbar)",20,$(p.h),jsdict)        
        </script>
        $(div)
        """
     p.update=true
     write(io,result)
end


"""
       vtkpolys(tris; offset=0)
Set up  polygon data for vtk. 
Coding is   [3, i11, i12, i13,   3 , i21, i22 ,i23, ...]
Careful: js indexing counts from zero
"""
function vtkpolys(tris; offset=0)
    ipoly=1
    ntri=size(tris,2)
    off=offset-1
    polys=Vector{Int32}(undef,4*ntri)
    for itri=1:ntri
        polys[ipoly] = 3
        polys[ipoly+1] = tris[1,itri]+off
        polys[ipoly+2] = tris[2,itri]+off
        polys[ipoly+3] = tris[3,itri]+off
        ipoly+=4
    end
    polys
end


"""
     tricontour!(p::PlutoVTKPlot,pts, tris,f; colormap, isolines)

Plot piecewise linear function on  triangular grid given as "heatmap" 
"""
function tricontour!(p::PlutoVTKPlot, pts, tris,f;colormap=:viridis, isolines=0, kwargs...)

    p.jsdict=Dict{String,Any}("cmdcount" => 0)


    command!(p,"tricontour")


    if isa(isolines,Number)
        (fmin,fmax)=extrema(f)
    else
        (fmin,fmax)=extrema(isolines)
    end        

    parameter!(p,"points",vec(vcat(pts,zeros(eltype(pts),length(f))')))
    parameter!(p,"polys",vtkpolys(tris))

    rgb=reinterpret(Float64,get(colorschemes[colormap],f,(fmin,fmax)))
    parameter!(p,"colors",UInt8.(floor.(rgb*255)))

    xisolines=[fmin,fmax]
    
    if isolines==0
        parameter!(p,"isopoints","none")
        parameter!(p,"isolines","none")
    else
        if isa(isolines,Number)
            xisolines=range(fmin,fmax,length=isolines)
        else
            xisolines=isolines
        end
        iso_pts=GridVisualize.marching_triangles(pts,tris,f,xisolines)
        niso_pts=length(iso_pts)
        iso_pts=vcat(reshape(reinterpret(Float32,iso_pts),(2,niso_pts)),zeros(niso_pts)')
        iso_lines=Vector{UInt32}(undef,niso_pts+Int32(niso_pts//2))
        
        iline=0
        ipt=0
        for i=1:niso_pts//2
            iso_lines[iline+1]=2
            iso_lines[iline+2]=ipt
            iso_lines[iline+3]=ipt+1
            iline=iline+3
            ipt=ipt+2
        end
        parameter!(p,"isopoints",vec(iso_pts))
        parameter!(p,"isolines",iso_lines)
    end

    # It seems a colorbar is best drawn via canvas...
    # https://github.com/Kitware/vtk-js/issues/1621
    bar_stops=collect(0:0.01:1)
    bar_rgb=reinterpret(Float64,get(colorschemes[colormap],bar_stops,(0,1)))
    bar_rgb=UInt8.(floor.(bar_rgb*255))
    p.jsdict["cbar"]=1
    p.jsdict["cstops"]=bar_stops
    p.jsdict["colors"]=bar_rgb
    p.jsdict["levels"]=collect(xisolines)

    axis2d!(p)
    p
end



"""
     tetcontour!(p::PlutoVTKPlot,pts, tets,f; colormap, isolevels, xplane, yplane, zplane)

Plot piecewise linear function on  tetrahedral mesh.
"""
function tetcontour!(p::PlutoVTKPlot, pts, tets,func;colormap=:viridis,
                     flevel=prevfloat(Inf), flimits=(1.0,-1.0),
                     xplane=prevfloat(Inf), yplane=prevfloat(Inf), zplane=prevfloat(Inf))

    p.jsdict=Dict{String,Any}("cmdcount" => 0)
    command!(p,"tetcontour")

    xyzmin=zeros(3)
    xyzmax=ones(3)

    @views for idim=1:3
        xyzmin[idim]=minimum(pts[idim,:])
        xyzmax[idim]=maximum(pts[idim,:])
    end
    xyzcut=[xplane,yplane,zplane]
    fminmax=extrema(func)
    if flimits[1]<flimits[2]
        fminmax[1]=flimits[1]
        fminmax[2]=flimits[2]
    end

    
    xplane=max(xyzmin[1],min(xyzmax[1],xplane ))
    yplane=max(xyzmin[2],min(xyzmax[2],yplane ))
    zplane=max(xyzmin[3],min(xyzmax[3],zplane ))
    flevel=max(fminmax[1],min(fminmax[2],flevel))

    cpts0,faces0,values=GridVisualize.marching_tetrahedra(pts,tets,func,
                                                          primepoints=hcat(xyzmin,xyzmax),
                                                          primevalues=fminmax,
                                                          GridVisualize.makeplanes(xyzmin,xyzmax,xplane,yplane,zplane),
                                                          [flevel])

    faces=reshape(reinterpret(Int32,faces0),(3,length(faces0)))
    cpts=copy(reinterpret(Float32,cpts0))
    parameter!(p,"points",cpts)
    parameter!(p,"polys",vtkpolys(faces))
    rgb=reinterpret(Float64,get(colorschemes[colormap],values,fminmax))
    parameter!(p,"colors",UInt8.(floor.(rgb*255)))
    axis3d!(p)
    p
end




contour!(p::PlutoVTKPlot,X,Y,f; kwargs...)=tricontour!(p,triang(X,Y)...,vec(f);kwargs...)
#contour!(p::PlutoVTKPlot,X,Y,f)=tricontour!(p,triang(X,Y)...,vec(f))




"""
     trimesh!(p::PlutoVTKPlot,pts, tris;markers, colormap, edges, edgemarkers, edgecolormap)

Plot piecewise linear function on  triangular grid given as "heatmap" 
"""
function trimesh!(p::PlutoVTKPlot,pts, tris;
                  markers=nothing,  colormap=nothing,
                  edges=nothing, edgemarkers=nothing, edgecolormap=nothing)


    ntri=size(tris,2)
    command!(p,"trimesh")
    zcoord=zeros(size(pts,2))
    parameter!(p,"points",vec(vcat(pts,zcoord')))
    parameter!(p,"polys",vtkpolys(tris))



    
    if markers!=nothing
        (fmin,fmax)=extrema(markers)
        if colormap==nothing
            colormap=GridVisualize.region_cmap(fmax)
        end
        if typeof(colormap)==Symbol
            cmap=colorschemes[colormap]
        else
            cmap=ColorScheme(colormap)
        end
        rgb=reinterpret(Float64,get(cmap,markers,(1,fmax+1)))
        parameter!(p,"colors",UInt8.(floor.(rgb*255)))
    else
        parameter!(p,"colors","none")
    end

    if edges!=nothing
        nedges=size(edges,2)
        lines=Vector{UInt32}(undef,3*nedges)
        iline=0
        for i=1:nedges
            lines[iline+1]=2
            lines[iline+2]=edges[1,i]-1  #  0-1 discrepancy between jl and js...
            lines[iline+3]=edges[2,i]-1
            iline=iline+3
        end
        parameter!(p,"lines",lines)

        if edgemarkers!=nothing
            (fmin,fmax)=Int64.(extrema(edgemarkers))
            if edgecolormap==nothing
                edgecolormap=GridVisualize.bregion_cmap(fmax)
            end
            if typeof(edgecolormap)==Symbol
                ecmap=colorschemes[edgecolormap]
            else
                ecmap=ColorScheme(edgecolormap)
            end
            edgergb=reinterpret(Float64,get(ecmap,edgemarkers,(1,fmax+1)))
            parameter!(p,"linecolors",UInt8.(floor.(edgergb*255)))
        else
            parameter!(p,"linecolors","none")
        end
    else
        parameter!(p,"lines","none")
        parameter!(p,"linecolors","none")
    end
    axis2d!(p)
    p
end



"""
     tetmesh!(p::PlutoVTKPlot,pts, tris;markers, colormap, faces, facemarkers, facecolormap)

Plot piecewise linear function on  triangular grid given as "heatmap" 
"""
function tetmesh!(p::PlutoVTKPlot, pts, tets;
                  markers=nothing,  colormap=nothing,
                  faces=nothing, facemarkers=nothing, facecolormap=nothing,
                  xplane=prevfloat(Inf), yplane=prevfloat(Inf), zplane=prevfloat(Inf))
    

    ntet=size(tets,2)
    command!(p,"tetmesh")
    nregions=  markers==nothing  ? 0 : maximum(markers)
    nbregions= facemarkers==nothing ? 0 :  maximum(facemarkers)

        
    if nregions==0
        nregions=1
        markers=fill(Int32(1),ntet)
    end

    if faces!=nothing && nbregions==0
        nbregions=1
        facemarkers=fill(Int32(1),size(faces,2))
    end


    if colormap==nothing
        colormap=GridVisualize.region_cmap(nregions)
    end

    if facecolormap==nothing
        facecolormap=GridVisualize.bregion_cmap(nbregions)
    end


    
    xyzmin=zeros(3)
    xyzmax=ones(3)

    @views for idim=1:3
        xyzmin[idim]=minimum(pts[idim,:])
        xyzmax[idim]=maximum(pts[idim,:])
    end

    
    xyzcut=[xplane,yplane,zplane]
    regpoints0,regfacets0=GridVisualize.extract_visible_cells3D(pts,tets,markers,nregions,
                                                                xyzcut,
                                                                primepoints=hcat(xyzmin,xyzmax)
                                                                )
    
    points=hcat([reshape(reinterpret(Float32,regpoints0[i] ),(3,length(regpoints0[i] ))) for i=1:nregions]...)
    facets=vcat([vtkpolys(reshape(reinterpret(Int32,regfacets0[i]),(3,length(regfacets0[i])))) for i=1:nregions]...)

    
    
    regmarkers=vcat([fill(i,length(regfacets0[i])) for i=1:nregions]...)

    if typeof(colormap)==Symbol
        cmap=colorschemes[colormap]
    else
        cmap=ColorScheme(colormap)
    end
    rgb=reinterpret(Float64,get(cmap,regmarkers,(1,nregions+1)))
    
    
    if faces!=nothing
        bregpoints0,bregfacets0=GridVisualize.extract_visible_bfaces3D(pts,faces,facemarkers,nbregions,
                                                                       xyzcut,
                                                                       primepoints=hcat(xyzmin,xyzmax)
                                                                       )
        bregpoints=hcat([reshape(reinterpret(Float32,bregpoints0[i]),(3,length(bregpoints0[i]))) for i=1:nbregions]...)
        bregfacets=vcat([vtkpolys(reshape(reinterpret(Int32,bregfacets0[i]),(3,length(bregfacets0[i]))),
                                  offset= size(points,2) + ( i==1 ? 0 : sum(k->length(bregpoints0[k]),1:i-1) ) )
                                  for i=1:nbregions]...)
        bfacemarkers=vcat([fill(i,length(bregfacets0[i])) for i=1:nbregions]...)

        if typeof(facecolormap)==Symbol
            facecmap=colorschemes[facecolormap]
        else
            facecmap=ColorScheme(facecolormap)
        end
        facergb=reinterpret(Float64,get(facecmap,bfacemarkers,(1,nbregions+1)))
        facets=vcat(facets,bregfacets)
        points=hcat(points,bregpoints)
        rgb=vcat(rgb,facergb)
    end
        
    parameter!(p,"polys",facets)
    parameter!(p,"points",vec(points))
    parameter!(p,"colors",UInt8.(floor.(rgb*255)))

    axis3d!(p)
    p
end


function plot!(p::PlutoVTKPlot,x,y; kwargs...)
    command!(p,"plot")
    n=length(x)
    points=vec(vcat(x',y',zeros(n)'))
    lines=collect(UInt16,0:n)
    lines[1]=n
    parameter!(p,"points",points)
    parameter!(p,"lines",lines)
    parameter!(p,"cam","2D")
    p
end





#####################################
# Experimental part
"""
     triplot!(p::PlutoVTKPlot,pts, tris,f)

Plot piecewise linear function on  triangular grid given by points and triangles
as matrices
"""
function triplot!(p::PlutoVTKPlot,pts, tris,f)
    p.jsdict=Dict{String,Any}("cmdcount" => 0)
    command!(p,"triplot")
    # make 3D points from 2D points by adding function value as
    # z coordinate
    p.jsdict["cbar"]=0
    parameter!(p,"points",vec(vcat(pts,f')))
    parameter!(p,"polys",vtkpolys(tris))
    axis3d!(p)
    p
end

