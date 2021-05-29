

mutable struct CanvasPlot <:AbstractVistaPlot
    # command list passed to javascript
    jsdict::Dict{String,Any}

    # size in canvas coordinates
    w::Float64
    h::Float64

    # world coordinates
    xmin::Float64
    xmax::Float64
    ymin::Float64
    ymax::Float64

    # transformation data
    ax::Float64
    bx::Float64
    ay::Float64
    by::Float64

    # unique identifier of html entity
    uuid::UUID

    CanvasPlot(::Nothing)=new()
end

"""
````
 CanvasPlot(;resolution=(300,300),
             xrange::AbstractVector=0:1,
             yrange::AbstractVector=0:1)
````

Create a canvas plot with given resolution in the notebook
and given "world coordinate" range.
"""
function CanvasPlot(;resolution=(300,300),
                    xrange::AbstractVector=0:1,
                    yrange::AbstractVector=0:1)
    
    p=CanvasPlot(nothing)
    p.uuid=uuid1()
    p.jsdict=Dict{String,Any}("cmdcount" => 0)
    p.w=resolution[1]
    p.h=resolution[2]
    _world!(p,extrema(xrange)...,extrema(yrange)...)
    p
end



"""
Set new world coordinates and calculate transformation data
"""
function _world!(p,xmin,xmax,ymin,ymax)
    p.xmin=xmin
    p.xmax=xmax
    p.ymin=ymin
    p.ymax=ymax
    p.ax= p.w/(p.xmax-p.xmin);
    p.ay=-p.h/(p.ymax-p.ymin);
    p.bx=0   - p.ax *p.xmin;
    p.by=p.h - p.ay *p.ymin;
    nothing
end

"""
Transform a pair of coordinates from world to canvas
"""
_tran2d(p,x,y)=(x*p.ax+p.bx,y*p.ay+p.by)



"""
Pass pair of coordinate arrays for `lines!`,`polyline!`,`polygon!`  
"""
function _poly!(p::CanvasPlot,cmd,x,y)
    pfx=command!(p,cmd)
    
    tx=Vector{Float32}(undef,length(x))
    ty=Vector{Float32}(undef,length(y))
    for i=1:length(x)
        tx[i],ty[i]=_tran2d(p,x[i],y[i])
    end
    p.jsdict[pfx*"_x"]=tx
    p.jsdict[pfx*"_y"]=ty
    p
    
end





"""
Show plot
"""
function Base.show(io::IO, ::MIME"text/html", p::CanvasPlot)
    canvasplot = read(joinpath(@__DIR__, "..", "assets", "canvasplot.js"), String)
    result="""
    <script>
    $(canvasplot)
    const jsdict = $(Main.PlutoRunner.publish_to_js(p.jsdict))
    canvasplot("$(p.uuid)",jsdict)        
    </script>
    <canvas id="$(p.uuid)" width="$(p.w)" height="$(p.h)"></canvas>
    """
    write(io,result)
end

"""
     lines!(p::CanvasPlot,x,y)

Plot lines. Every two coordinates define a line.
"""
function lines!(p::CanvasPlot,x,y)
    _poly!(p,"lines",x,y)
end

"""
      polyline!(p::CanvasPlot,x,y)

Plot a polyline.
"""
function polyline!(p::CanvasPlot,x,y)
    _poly!(p,"polyline",x,y)
end

"""
      polygon!(p::CanvasPlot,x,y)

Plot a polygon and fill it.
"""
function polygon!(p::CanvasPlot,x,y)
    _poly!(p,"polygon",x,y)
end


"""
     linecolor!(p::CanvasPlot,r,g,b)

Set line color.
"""
function linecolor!(p::CanvasPlot,r,g,b)
    pfx=command!(p,"linecolor")
    p.jsdict[pfx*"_rgb"]=255*Float32[r,g,b]
end


"""
      linewidth!(p::CanvasPlot,w)

Set line width in pixels
"""
function linewidth!(p::CanvasPlot,w)
    pfx=command!(p,"linewidth")
    p.jsdict[pfx*"_w"]=w
end

"""
     fillcolor!(p::CanvasPlot,r,g,b)

Set polygon fill color.
"""
function fillcolor!(p::CanvasPlot,r,g,b)
    pfx=command!(p,"fillcolor")
    p.jsdict[pfx*"_rgb"]=255*Float32[r,g,b]
end


"""
     textcolor!(p::CanvasPlot,r,g,b)

Set text color
"""
function textcolor!(p::CanvasPlot,r,g,b)
    pfx=command!(p,"textcolor")
    p.jsdict[pfx*"_rgb"]=255*Float32[r,g,b]
end


"""
      textsize!(p::CanvasPlot,px)

Set text size in pixels
"""
function textsize!(p::CanvasPlot,px)
    pfx=command!(p,"textsize")
    p.jsdict[pfx*"_pt"]=px
end


const halign=Dict("c"=>"center",
                  "l"=>"left",
                  "r"=>"right")

const valign=Dict("b"=>"bottom",
                  "c"=>"middle",
                  "t"=>"top")


"""
    textalign!(p::CanvasPlot,align)

Set text alignment.

`align:` one of `[:lt,:lc,lb,:ct,:cc,:cb,:rt,:rc,:rb]`
"""
function textalign!(p::CanvasPlot,align)
    a=String(align)

    pfx=command!(p,"textalign")
    p.jsdict[pfx*"_align"]=halign[a[1:1]]

    pfx=command!(p,"textbaseline")
    p.jsdict[pfx*"_align"]=valign[a[2:2]]

end


"""
    text!(p::CanvasPlot,txt,x,y)

Draw text at position x,y.
"""
function text!(p::CanvasPlot,txt,x,y)
    pfx=command!(p,"text")
    tx,ty=_tran2d(p,x,y)
    p.jsdict[pfx*"_x"]=tx
    p.jsdict[pfx*"_y"]=ty
    p.jsdict[pfx*"_txt"]=txt
end

"""
         axis!(p::CanvasPlot;
               xtics=0:1,
               ytics=0:1,
               axislinewidth=2,
               gridlinewidth=1.5,
               ticlength=7,
               ticsize=15,
               xpad=30,
               ypad=30)

Draw an axis with grid and tics, set new
world coordinates according to tics.
"""
function axis!(p::CanvasPlot;
               xtics=0:1,
               ytics=0:1,
               axislinewidth=2,
               gridlinewidth=1.5,
               ticlength=7,
               ticsize=15,
               xpad=30,
               ypad=30)
    linecolor!(p,0,0,0)
    xmin,xmax=extrema(xtics)
    ymin,ymax=extrema(ytics)


    world_ypad=ypad*(ymax-ymin)/p.h
    world_xpad=xpad*(xmax-xmin)/p.w
    
                 
    _world!(p,xmin-world_xpad,xmax+world_xpad/2,ymin-world_ypad,ymax+world_ypad/2)

    
    linewidth!(p,gridlinewidth)
    linecolor!(p,0.85,0.85,0.85)
    for y in ytics
        lines!(p,[xmin,xmax],[y,y])
    end
    for x in xtics
        lines!(p,[x,x],[ymin,ymax])
    end

    

    linewidth!(p,axislinewidth)
    linecolor!(p,0,0,0)

    lines!(p,[xmin,xmax],[ymin,ymin])
    lines!(p,[xmin,xmax],[ymax,ymax])
    lines!(p,[xmin,xmin],[ymin,ymax])
    lines!(p,[xmax,xmax],[ymin,ymax])

    linewidth!(p,gridlinewidth)
    linecolor!(p,0,0,0)
    world_xticlength=-ticlength/p.ay
    world_yticlength=ticlength/p.ax

    textcolor!(p,0,0,0)
    textsize!(p,ticsize)
    textalign!(p,:rc)
    for y in ytics
        lines!(p,[xmin-world_yticlength,xmin],[y,y])
        text!(p, string(y), xmin-world_yticlength,y)
    end
    
    textalign!(p,:ct)
    for x in xtics
        lines!(p,[x,x],[ymin-world_xticlength,ymin])
        text!(p, string(x), x,ymin-world_xticlength)
        
    end
end
