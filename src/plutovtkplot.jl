"""
Structure containig plot information. 
In particular it contains dict of data sent to javascript.
"""
mutable struct PlutoVTKPlot  <: PlutoVistaPlot
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
    result=" "
    if p.update
        result="""
        <script type="text/javascript" src="https://unpkg.com/vtk.js@18"></script>
        <script>
        $(plutovtkplot)
        const jsdict = $(Main.PlutoRunner.publish_to_js(p.jsdict))
        vtkupdate("$(p.uuid)",jsdict,invalidation)        
        </script>
        """
    else
        result="""
        <script type="text/javascript" src="https://unpkg.com/vtk.js@18"></script>
        <script>
        $(plutovtkplot)
        $(canvascolorbar)
        const jsdict = $(Main.PlutoRunner.publish_to_js(p.jsdict))
        plutovtkplot("$(p.uuid)",jsdict,invalidation)
        canvascolorbar("$(uuidcbar)",20,$(p.h),jsdict)        
        </script>
        <p>
        <div style="white-space:nowrap;">
        <div id="$(p.uuid)" style= "width: $(p.w)px; height: $(p.h)px; display: inline-block; "></div>
        <canvas id="$(uuidcbar)" width=60, height="$(p.h)"  style="display: inline-block; "></canvas>
        </div>
    </p>
        """
    end
    write(io,result)
end


"""
       vtkpolys(tris)
Set up  polygon data for vtk. 
Coding is   [3, i11, i12, i13,   3 , i21, i22 ,i23, ...]
Careful: js indexing counts from zero
"""
function vtkpolys(tris)
    ipoly=1
    ntri=size(tris,2)
    polys=Vector{Int32}(undef,4*ntri)
    for itri=1:ntri
        polys[ipoly] = 3
        polys[ipoly+1] = tris[1,itri]-1
        polys[ipoly+2] = tris[2,itri]-1
        polys[ipoly+3] = tris[3,itri]-1
        ipoly+=4
    end
    polys
end


"""
     tricontour!(p::PlutoVTKPlot,pts, tris,f; colormap, isolines)

Plot piecewise linear function on  triangular grid given as "heatmap" 
"""
function tricontour!(p::PlutoVTKPlot, pts, tris,f;colormap=:viridis, isolines=0, kwargs...)
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


contour!(p::PlutoVTKPlot,X,Y,f; kwargs...)=tricontour!(p,triang(X,Y)...,vec(f);kwargs...)
contour!(p::PlutoVTKPlot,X,Y,f)=tricontour!(p,triang(X,Y)...,vec(f))



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
    command!(p,"triplot")
    p.update=false
    # make 3D points from 2D points by adding function value as
    # z coordinate
    p.jsdict["cbar"]=0
    parameter!(p,"points",vec(vcat(pts,f')))
    parameter!(p,"polys",vtkpolys(tris))
    parameter!(p,"cam","3D")
end








function triupdate!(p::PlutoVTKPlot,pts,tris,f)
    command!(p,"triplot")
    # make 3D points from 2D points by adding function value as
    # z coordinate
    p.jsdict["xpoints"]=vec(vcat(pts,f'))
    p.update=true
    p
end
