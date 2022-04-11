"""
$(TYPEDEF)

PlutoVistaPlot is a wrapper struct around different possible backends.
As default, for 1D plots, [`PlutoPlotlyPlot`](@ref) and for 2D and 3D plots,
[`PlutoVTKPlot`](@ref) are chosen. The backend is automatically chosen
when the first plot is invoked.

"""
mutable struct PlutoVistaPlot
    backend::Union{PlutoPlotlyPlot,PlutoCanvasPlot,PlutoVTKPlot,Nothing}
    resolution
    args
    PlutoVistaPlot(::Nothing)=new(nothing, (0,0), nothing)
end

"""
$(SIGNATURES)

Constructor for PlutoVistaPlot. 

Relevant keyword arguments:
- `resolution`: Screen resolution in pixels
- `dim`: Space dimension of subsequent plots

"""
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



####################################################################################
"""
$(SIGNATURES)

Plot `y` over `y`.

Arguments:
- `x` vector of x coordinates
- `y` vector of y coordinates (function values)

Keyword  arguments:
- `limits=(1,-1)`: function limits
- `xlimits=(1,-1)` : x axis limits
- `xlabel=""`: x axis label     
- `ylabel=""`: y axis label     
- `title="" : plot title     
- `xscale=:linear`: linear or log scale for x axis
- `yscale=:linear`: linear or log scale for y axis
- `legend=:none`: legend placement (:lt,:rt ...) 
- `clear=false`: clear plot contents
- `label=""`: label of particular plot
- `color=:auto`
- `titlefontsize=12`
- `axisfontsize=10`
- `tickfontsize=10`
- `legendfontsize=10`
- `linewidth=2`
- `linestyle=:solid`: 
- `markersize=6`
- `markercount=10`
- `markertype=:none`, possible values: `:dtriangle`, `:utriangle`, `:rtriangle`, `:ltriangle`, `:circle`, `:square`, `:cross`, `:+ `, `:xcross`, `:x `,`:diamond`, `:star5`, `:pentagon`, `:hexagon

"""
plot(x,y; kwargs...)=plot!(PlutoVistaPlot(;kwargs...),x,y;kwargs...)
    
"""
$(SIGNATURES)

Add additional x-y plot to `p`
"""
plot!(p::PlutoVistaPlot,x,y; backend=:plotly, clear=false, kwargs...) = plot!(backend!(p; datadim=1,backend=backend,clear=false, kwargs...),
                                                                              x,y;
                                                                              clear=clear,kwargs...)


"""
$(SIGNATURES)

Create empty 1D plot.
"""
function plot(;datadim=1,backend=:default,kwargs...)
    p=PlutoVistaPlot(;kwargs...)
    backend!(p;datadim=datadim,backend=backend, kwargs...)
end


##########################################################################
"""
$(SIGNATURES)

Filled colored tricontour with isolines. By default, a vtk.js based backend is used.
Plots piecewise linear function on  triangular grid.

Arguments:
- `pts`:  `2 x n_points` array of point coordinates
- `tris`: `3 x n_tris` array of point indices describing triangles
- `f`: `n`-vector of function values

Keyword arguments:
- `title=""`
- `clear=false`
- `xlabel="x"`: x axis label     
- `ylabel="y"`: y axis label     
- `colormap=:viridis`
- `levels=0`: either number of interior isolevels, or vector of isolevel values
- `colorbarticks=:default` : colorbar ticks. Default: levels
- `limits=:auto`: function limits 
- `aspect=1`: xy aspect ratio (plotly backend)

"""
tricontour(pts,tris,f; kwargs...)=tricontour!(PlutoVistaPlot(;kwargs...),pts,tris,f; kwargs...)

"""
$(SIGNATURES)

Add tricontour to existing plot
"""
tricontour!(p::PlutoVistaPlot,pts,tris,f;backend=:vtk, kwargs...)=tricontour!(backend!(p; datadim=2,backend=backend, kwargs...),
                                                                              pts,tris,f; kwargs...)

"""
$(SIGNATURES)

Create empty tricontour plot
"""
function tricontour(;kwargs...)
    p=PlutoVistaPlot(;kwargs...)
    backend!(p;datadim=2,kwargs...)
end


##########################################################################
"""
$(SIGNATURES)

Create triangular mesh from x and y coordinates, and call tricontour.
"""
contour(X,Y,f; kwargs...)=contour!(PlutoVistaPlot(;kwargs...),X,Y,f; kwargs...)


"""
$(SIGNATURES)

Add contour to existing plot
"""
contour!(p::PlutoVistaPlot,X,Y,f; backend=:vtk, kwargs...)=contour!(backend!(p;datadim=2,backend=backend, kwargs...),
                                                                    X,Y,f; kwargs...)
"""
$(SIGNATURES)

Create empty contour plot
"""
function contour(;kwargs...)
    p=PlutoVistaPlot(;kwargs...)
    backend!(p;datadim=2,kwargs...)
end

##########################################################################
"""
$(SIGNATURES)
Quiver plot, using vtk.js backend.

Arguments:

- `pts`: `2 x n_pts` array of points
- `qvec`: `2 x n_pts` array of vector values
"""
quiver2d(pts,qvec; kwargs...)=quiver2d!(PlutoVistaPlot(;kwargs...),pts,qvec; kwargs...)


"""
$(SIGNATURES)

Add quiver to existing plot
"""
quiver2d!(p::PlutoVistaPlot,pts,qvec;backend=:vtk, kwargs...)=quiver2d!(backend!(p; datadim=2,backend=backend, kwargs...),
                                                                              pts,qvec; kwargs...)
"""
$(SIGNATURES)

Create empty quiver plot
"""
function quiver2d(;kwargs...)
    p=PlutoVistaPlot(;kwargs...)
    backend!(p;datadim=3,kwargs...)
end


##########################################################################
"""
$(SIGNATURES)

Plot triangular mesh, showing triangle boundaries and outer boundaries, using vtk.js backend.

Arguments:
- `pts`:  `2 x n_points` array of point coordinates
- `tris`: `3 x n_tris` array of point indices describing triangles


Keyword arguments:

- `markers=nothing`: Optional `n_tris` integer vector of triangle markers
- `colormap`: optional colormap for triangle markers
- `edges`: `2 x n_edges` optional  array of point indices describing edges
- `edgemarkers=nothing`: optional `n_edges` vector of integer edge markers
- `edgecolormap=nothing`: optional colormap for edge markers

"""
trimesh(pts,tris; kwargs...)=trimesh!(PlutoVistaPlot(;kwargs...),pts,tris; kwargs...)

"""
$(SIGNATURES)

Add trimesh to plot.
"""
trimesh!(p::PlutoVistaPlot,pts,tris; backend=:vtk, kwargs...)=trimesh!(backend!(p;datadim=2,backend=backend, kwargs...),
                                                                        pts,tris; kwargs...)

"""
$(SIGNATURES)

Create empty trimesh plot.
"""
function trimesh(;kwargs...)
    p=PlutoVistaPlot(;kwargs...)
    backend!(p;datadim=2,kwargs...)
end





##########################################################################
"""
$(SIGNATURES)


Plot piecewise linear function on tetrahedral grid using vtk backend.
The plot consists of three parts:

- Transparent isosurfaces of function values according to `levels`
- Transparent plane cuts with function "hetmapes" according to `xplanes`,`yplanes`,`zplanes`
- Transparent domain outline


Arguments:
- `pts`:  `3 x n_points` array of point coordinates
- `tets`: `4 x n_tets` array of point indices describing tetrahedra
- `f`: `n_points`-vector of function values

Keyword arguments:
- `title=""`
- `clear=false`
- `colormap=:viridis`
- `faces=nothing`: optional `3 x n_faces` array of boundary faces
- `facemarkers=nothing`: optional `n_faces` integer vector of face markers
- `facecolormap=nothing`: optional colormap of facemarkers
- `levels=0`: either number of interior isolevels, or vector of isolevel values
- `limits=:auto`: function limits 
- `xplanes`: either number or array of x coordinate values of x-orthogonal plane sections
- `yplanes`: either number or array of y coordinate values of y-orthogonal plane sections
- `zplanes`: either number or array of z coordinate values of z-orthogonal plane sections
- `levelalpha=0.25`: alpha value for isosurfaces and plane cuts
- `outlinealpha=0.1`: alpha value for outline. Outliene is for value 0.0

"""
tetcontour(pts,tets,f; kwargs...)=tetcontour!(PlutoVistaPlot(;kwargs...),pts,tets,f; kwargs...)

"""
$(SIGNATURES)

Add tetcontour to plot
"""
tetcontour!(p::PlutoVistaPlot,pts,tets,f;backend=:vtk, kwargs...)=tetcontour!(backend!(p; datadim=2,backend=backend, kwargs...),
                                                                              pts,tets,f; kwargs...)
"""
$(SIGNATURES)

Create empty tetcontour plot.
"""
function tetcontour(;kwargs...)
    p=PlutoVistaPlot(;kwargs...)
    backend!(p;datadim=3,kwargs...)
end



##########################################################################
"""
$(SIGNATURES)

Plot tetrahedral mesh, showing tetrahedron boundaries and outer boundaries, using vtk.js backend.
The plot consists of two parts:

- A subset of tetrahedra visible after cutting of all tets with are on the positive side of the respective x, y, z planes
- A transpatemt outline of the boundary.

Arguments:
- `pts`:  `3 x n_points` array of point coordinates
- `tets`: `4 x n_tris` array of point indices describing tetrahedra


Keyword arguments:

- `markers=nothing`: Optional `n_tets` integer vector of tetrahedron markers
- `colormap`: optional colormap for tetrahedron markers
- `faces=nothing`: optional `3 x n_faces` array of boundary faces
- `facemarkers=nothing`: optional `n_faces` integer vector of face markers
- `facecolormap=nothing`: optional colormap of facemarkers
- `xplanes`: array of x coordinate values for cut-off in x-direction
- `yplanes`: array of y coordinate values for cut-off in y-direction
- `zplanes`: array of z coordinate values for cut-off in z-direction
- `outlinealpha=0.1`: alpha value for outline. Outliene is for value 0.0
"""
tetmesh(pts,tets; kwargs...)=tetmesh!(PlutoVistaPlot(;kwargs...),pts,tets; kwargs...)

"""
$(SIGNATURES)

Add tetmesh to plot
"""
tetmesh!(p::PlutoVistaPlot,pts,tets; backend=:vtk, kwargs...)=tetmesh!(backend!(p;datadim=3,backend=backend, kwargs...),
                                                                        pts,tets; kwargs...)

"""
$(SIGNATURES)

Create empty tetmesh plot.
"""
function tetmesh(;kwargs...)
    p=PlutoVistaPlot(;kwargs...)
    backend!(p;datadim=2,kwargs...)
end




#########################################################
"""
$(SIGNATURES)

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
```
"""
function command!(p::T,cmd) where {T <: AbstractPlutoVistaBackend}
    p.jsdict["cmdcount"]=p.jsdict["cmdcount"]+1
    pfx=string(p.jsdict["cmdcount"])
    p.jsdict[pfx]=cmd
    p
end


"""
$(SIGNATURES)

After [`command!`](@ref), create a parameter entry
"""
function parameter!(p::T,name,value) where {T <: AbstractPlutoVistaBackend}
    pfx=string(p.jsdict["cmdcount"])
    p.jsdict[pfx*name]=value
    p
end


"""
$(SIGNATURES)

Reset command list
"""
reset!(p::T) where {T <: AbstractPlutoVistaBackend} = p.jsdict=Dict{String,Any}("cmdcount" => 0)


"""
$(SIGNATURES)

Create triangulation data from X and Y coordinate vectors
"""
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

