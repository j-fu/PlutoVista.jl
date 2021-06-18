abstract type PlutoVistaPlot end


function PlutoVistaPlot(;resolution=(300,300), datadim=1,backend=:default, kwargs...)
    if backend==:default
        if datadim==1
            backend=:plotly
        else
            backend=:vtk
        end
    end
    
    if backend == :plotly
        return PlutoPlotlyPlot(;resolution=resolution)
    elseif backend == :vtk
        return  PlutoVTKPlot(;resolution=resolution)
    else
        error("No valid backend: $(backend). Valid backends: :default, :vtk, :plotly")
    end
end


function plot(x,y; kwargs...)
    p=PlutoVistaPlot(;datadim=1, kwargs...)
    plot!(p,x,y;kwargs...)
end

function contour(X,Y,f; kwargs...)
    p=PlutoVistaPlot(;datadim=2, kwargs...)
    contour!(p,X,Y,f; kwargs...)
end

function tricontour(pts,tris,f; kwargs...)
    p=PlutoVistaPlot(;datadim=2, kwargs...)
    tricontour!(p,pts,tris,f; kwargs...)
end

"""
    command!(p<: PlutoVistaPlot,cmd)

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
function command!(p::T,cmd) where {T <: PlutoVistaPlot}
    p.jsdict["cmdcount"]=p.jsdict["cmdcount"]+1
    pfx=string(p.jsdict["cmdcount"])
    p.jsdict[pfx]=cmd
    p
end


"""
    parameter!(p<: PlutoVistaPlot,name, value)

After [`command!`](@ref), create a parameter entry
"""
function parameter!(p::T,name,value) where {T <: PlutoVistaPlot}
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
