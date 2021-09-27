mutable struct PlutoVistaPlot
    backend::Union{PlutoPlotlyPlot,PlutoCanvasPlot,PlutoVTKPlot,Nothing}
    resolution
    args
    PlutoVistaPlot(::Nothing)=new(nothing, (0,0), nothing)
end

function PlutoVistaPlot(;resolution=(300,300),kwargs...)
    p=PlutoVistaPlot(nothing)
    p.resolution=resolution
    p.args=kwargs
    p
end

"""
    backend!(p::PlutoVistaPlot; datadim=1, backend=:default, clear=false)

Overwrite backend if clear is true.
"""
function backend!(p::PlutoVistaPlot; datadim=1, backend=:default, clear=false, kwargs...)
    if backend==:default
        if datadim == 1
            backend=:plotly
        else
            backend=:vtk
        end
    end
    
    if backend == :plotly
        if isnothing(p.backend)  || typeof(p.backend)!=PlutoPlotlyPlot || clear
            p.backend=PlutoPlotlyPlot(;resolution=p.resolution, merge(p.args,kwargs)...)
        end
    elseif backend == :vtk 
        if isnothing(p.backend)  || typeof(p.backend)!=PlutoVTKPlot || clear
            p.backend=PlutoVTKPlot(;resolution=p.resolution,merge(p.args,kwargs)...)
        end
    else
        error("No valid backend: $(backend). Valid backends: :default, :vtk, :plotly")
    end
    p.backend
end


Base.show(io::IO, mime::MIME"text/html", p::Nothing)=nothing
Base.show(io::IO, mime::MIME"text/html", p::PlutoVistaPlot)=Base.show(io,mime,p.backend)

plot(x,y; kwargs...)=plot!(PlutoVistaPlot(;kwargs...),x,y;kwargs...)
plot!(p::PlutoVistaPlot,x,y; backend=:plotly, clear=false, kwargs...) = plot!(backend!(p; datadim=1,backend=backend,clear=false, kwargs...),
                                                                              x,y;
                                                                              clear=clear,kwargs...)


function plot(;datadim=1,backend=:default,kwargs...)
    p=PlutoVistaPlot(;kwargs...)
    backend!(p;datadim=datadim,backend=backend, kwargs...)
end



tricontour(pts,tris,f; kwargs...)=tricontour!(PlutoVistaPlot(;kwargs...),pts,tris,f; kwargs...)
tricontour!(p::PlutoVistaPlot,pts,tris,f;backend=:vtk, kwargs...)=tricontour!(backend!(p; datadim=2,backend=backend, kwargs...),
                                                                              pts,tris,f; kwargs...)

function tricontour(;kwargs...)
    p=PlutoVistaPlot(;kwargs...)
    backend!(p;datadim=2,kwargs...)
end



tetcontour(pts,tets,f; kwargs...)=tetcontour!(PlutoVistaPlot(;kwargs...),pts,tets,f; kwargs...)
tetcontour!(p::PlutoVistaPlot,pts,tets,f;backend=:vtk, kwargs...)=tetcontour!(backend!(p; datadim=2,backend=backend, kwargs...),
                                                                              pts,tets,f; kwargs...)
function tetcontour(;kwargs...)
    p=PlutoVistaPlot(;kwargs...)
    backend!(p;datadim=3,kwargs...)
end



trimesh(pts,tris; kwargs...)=trimesh!(PlutoVistaPlot(;kwargs...),pts,tris; kwargs...)
trimesh!(p::PlutoVistaPlot,pts,tris; backend=:vtk, kwargs...)=trimesh!(backend!(p;datadim=2,backend=backend, kwargs...),
                                                                        pts,tris; kwargs...)

function trimesh(;kwargs...)
    p=PlutoVistaPlot(;kwargs...)
    backend!(p;datadim=2,kwargs...)
end



tetmesh(pts,tets; kwargs...)=tetmesh!(PlutoVistaPlot(;kwargs...),pts,tets; kwargs...)
tetmesh!(p::PlutoVistaPlot,pts,tets; backend=:vtk, kwargs...)=tetmesh!(backend!(p;datadim=3,backend=backend, kwargs...),
                                                                        pts,tets; kwargs...)

function tetmesh(;kwargs...)
    p=PlutoVistaPlot(;kwargs...)
    backend!(p;datadim=2,kwargs...)
end





contour(X,Y,f; kwargs...)=contour!(PlutoVistaPlot(;kwargs...),X,Y,f; kwargs...)
contour!(p::PlutoVistaPlot,X,Y,f; backend=:vtk, kwargs...)=contour!(backend!(p;datadim=2,backend=backend, kwargs...),
                                                                    X,Y,f; kwargs...)
function contour(;kwargs...)
    p=PlutoVistaPlot(;kwargs...)
    backend!(p;datadim=2,kwargs...)
end


"""
    command!(p<: AbstractPlutoVistaBackend,cmd)

Enter new command named `cmd`.

The idea is to pass one single Dict with all plot data to javascript
using `publish_to_js`.

For this purpose we need a some "language" hidden in 
behind the dict.

Plot   elements  are   described  by   commands  executed   one  after
another. For  this purpose,  we use integers  converted to  strings as
dict keys and pass the command name as the corresponding entry.

The entry `cmdcount` keeps track of  the number of commands. So we can
parse all  commands from 1  to jsdict[:cmdcount] in javascript  in the
same sequence as they have been entered.

Parameters are named and entered into the dictionary with the 
command number as prefix.

E.g. for a polyline as command number 5, we create the entries

```
"5" => "polyline"
"5x" => Vector of x coordinates in canvas coordinate system
"5y" => Vector of y coordinates in canvas coordinate system
"""
function command!(p::T,cmd) where {T <: AbstractPlutoVistaBackend}
    p.jsdict["cmdcount"]=p.jsdict["cmdcount"]+1
    pfx=string(p.jsdict["cmdcount"])
    p.jsdict[pfx]=cmd
    p
end


"""
    parameter!(p<: AbstractPlutoVistaBackend,name, value)

After [`command!`](@ref), create a parameter entry
"""
function parameter!(p::T,name,value) where {T <: AbstractPlutoVistaBackend}
    pfx=string(p.jsdict["cmdcount"])
    p.jsdict[pfx*name]=value
    p
end



function triang(X,Y)
    nx=length(X)
    ny=length(Y)
    num_pts=nx*ny
    num_tris=2*(nx-1)*(ny-1)
    pts=zeros(Float32,2,num_pts)
    tris=zeros(Int32,3,num_tris)

    ipoint=0
    for iy=1:ny
        for ix=1:nx
            ipoint=ipoint+1
            pts[1,ipoint]=X[ix]
            pts[2,ipoint]=Y[iy]
        end
    end

    @assert(ipoint==num_pts)
    
    itri=0
    for iy=1:ny-1
        for ix=1:nx-1
	    ip=ix+(iy-1)*nx
	    p00 = ip
	    p10 = ip+1
	    p01 = ip  +nx
	    p11 = ip+1+nx
            
            itri=itri+1
            tris[1,itri]=p00
            tris[2,itri]=p10
            tris[3,itri]=p11

            itri=itri+1
            tris[1,itri]=p11
            tris[2,itri]=p01
            tris[3,itri]=p00
        end
    end
    @assert(itri==num_tris)
    pts, tris
end

