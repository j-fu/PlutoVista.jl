"""
$(TYPEDEF)

Structure containig plot information for vtk.js.
"""
mutable struct PlutoVTKPlot  <: AbstractPlutoVistaBackend
    # command list passed to javascript
    jsdict::Dict{String,Any}

    # size in screen coordinates
    w::Float64
    h::Float64

    # update of a already created plot ?

    update::Bool

    args
    
    # uuid for identifying html element
    uuid::UUID
    PlutoVTKPlot(::Nothing)=new()
end

"""
$(SIGNATURES)

Create a vtk plot with given resolution in the notebook.
"""
function PlutoVTKPlot(;resolution=(300,300), kwargs...)
    p=PlutoVTKPlot(nothing)
    p.uuid=uuid1()
    p.jsdict=Dict{String,Any}("cmdcount" => 0,"cbar" => 0)
    p.w=resolution[1]
    p.h=resolution[2]

    default_args=(title="",
                  titlefontsize=12,
                  axisfontsize=10,
                  tickfontsize=10,
                  xlabel="x",
                  ylabel="y",
                  zlabel="z",
                  aspect=1.0,
                  zoom=1.0,
                  legendfontsize=10,
                  colorbarticks=:default,
                  clear=false)

    p.args=merge(default_args,kwargs)

    
    p.update=false
    p
end

const canvascolorbar = read(joinpath(@__DIR__, "..", "assets", "canvascolorbar.js"), String)
const plutovtkplot = read(joinpath(@__DIR__, "..", "assets", "plutovtkplot.js"), String)

"""
    Base.show(io::IO,::MIME"text/html",p::PlutoVTKPlot)

Show plot in html. This creates a vtk.js based renderer along with a canvas
for handling the colorbar.
"""
function Base.show(io::IO, ::MIME"text/html", p::PlutoVTKPlot)
    uuidcbar="$(p.uuid)"*"cbar"
    div=""
    if !p.update
    div="""
        <div style="white-space:nowrap;">
        <div id="$(p.uuid)" style= "width: $(p.w-60)px; height: $(p.h-60)px; display: inline-block; "></div>
        <canvas id="$(uuidcbar)" width=60, height="$(p.h-25)"  style="display: inline-block; "></canvas>
        </div>
    """
    end
    result="""
        <script type="text/javascript" src="https://unpkg.com/vtk.js@25"></script>
        <script>
        $(plutovtkplot)
        $(canvascolorbar)
        const jsdict = $(Main.PlutoRunner.publish_to_js(p.jsdict))
        plutovtkplot("$(p.uuid)",jsdict,invalidation)
        canvascolorbar("$(uuidcbar)",20,$(p.h),jsdict)        
        </script>
        """
     p.update=true
     write(io,result*div)
end



"""
    axis3d!(vtkplot)
Add 3D coordinate system axes to the plot.
Sets camera handling to 3D mode.
"""
function axis3d!(p::PlutoVTKPlot; kwargs...)
    args=merge(p.args,kwargs)
    
    command!(p,"axis")
    parameter!(p,"axisfontsize"   ,kwargs[:axisfontsize])  
    parameter!(p,"tickfontsize"   ,kwargs[:tickfontsize])   
    parameter!(p,"zoom"   ,kwargs[:zoom])   
    parameter!(p,"cam","3D")
    parameter!(p,"xlabel",args[:xlabel])
    parameter!(p,"ylabel",args[:ylabel])
    parameter!(p,"zlabel",args[:zlabel])

end

"""
    axis2d!(vtkplot)
Add 2D coordinate system axes to the plot.
Sets camera handling to 2D mode.
"""
function axis2d!(p::PlutoVTKPlot; kwargs...)
    args=merge(p.args,kwargs)
    
    command!(p,"axis")
    parameter!(p,"axisfontsize"   ,kwargs[:axisfontsize])  
    parameter!(p,"tickfontsize"   ,kwargs[:tickfontsize])   
    parameter!(p,"zoom"   ,kwargs[:zoom])   
    parameter!(p,"xlabel",args[:xlabel])
    aspect=args[:aspect]
    if aspect<1.0
        parameter!(p,"ylabel","$(args[:ylabel])/$(1/args[:aspect])")
    elseif aspect>1.0
        parameter!(p,"ylabel","$(args[:ylabel])*$(aspect)")
    else
        parameter!(p,"ylabel","$(args[:ylabel])")
    end
    
    parameter!(p,"zlabel",args[:zlabel])
    parameter!(p,"cam","2D")
end

"""
       vtkpolys(tris; offset=0)
Set up  polygon (triangle) data for vtk. 
Coding is   [3, i11, i12, i13,   3 , i21, i22 ,i23, ...]
Careful: js indexing counts from zero.
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
    outline!(p::PlutoVTKPlot,pts,faces,facemarkers,facecolormap,nbregions,xyzmin,xyzmax;alpha=0.1)

Plot transparent outline of grid boundaries.
"""
function outline!(p::PlutoVTKPlot,pts,faces,facemarkers,facecolormap,nbregions,xyzmin,xyzmax;alpha=0.1)
    bregpoints0,bregfacets0=extract_visible_bfaces3D(pts,faces,facemarkers,nbregions,
                                                                   xyzmax,
                                                                   primepoints=hcat(xyzmin,xyzmax)
                                                                   )
    bregpoints=hcat([reshape(reinterpret(Float32,bregpoints0[i]),(3,length(bregpoints0[i]))) for i=1:nbregions]...)
    bregfacets=vcat([vtkpolys(reshape(reinterpret(Int32,bregfacets0[i]),(3,length(bregfacets0[i]))),
                              offset= ( i==1 ? 0 : sum(k->length(bregpoints0[k]),1:i-1) ) )
                     for i=1:nbregions]...)
    bfacemarkers=vcat([fill(i,length(bregfacets0[i])) for i=1:nbregions]...)
    
    if typeof(facecolormap)==Symbol
        facecmap=colorschemes[facecolormap]
    else
        facecmap=ColorScheme(facecolormap)
    end
    facergb=reinterpret(Float64,get(facecmap,bfacemarkers,(1,size(facecmap))))
    nfaces=length(facergb)÷3
    facergba=zeros(UInt8,nfaces*4)
    irgb=0
    irgba=0
    for i=1:nfaces
        facergba[irgba+1]=UInt8(floor(facergb[irgb+1]*255))
        facergba[irgba+2]=UInt8(floor(facergb[irgb+2]*255))
        facergba[irgba+3]=UInt8(floor(facergb[irgb+3]*255))
        facergba[irgba+4]=UInt8(floor(alpha*255))
        irgb+=3
        irgba+=4
    end
    parameter!(p,"opolys",bregfacets)
    parameter!(p,"opoints",vec(bregpoints))
    parameter!(p,"ocolors",facergba)
    
end



"""
$(SIGNATURES)

Plot piecewise linear function on  triangular grid given as "heatmap".
Isolines can be given as a number or as a range.
"""
function tricontour!(p::PlutoVTKPlot, pts, tris,f;kwargs...)
    reset!(p)

    default_args=(colormap=:viridis, levels=0, limits=:auto,gridscale=1.0)
    args=merge(p.args,default_args)
    args=merge(args,kwargs)

    colormap=args[:colormap]

    


    command!(p,"tricontour")

    levels,crange,colorbarticks=makeisolevels(f,
                                              args[:levels],
                                              args[:limits] == :auto ? (1,-1) : args[:limits] ,
                                              args[:colorbarticks]== :default ? nothing : args[:colorbarticks])


    crange=Float64.(crange)

    parameter!(p,"points",vec(vcat(pts,zeros(eltype(pts),length(f))')))
    parameter!(p,"polys",vtkpolys(tris))
    parameter!(p,"gridscale",args[:gridscale])

    rgb=reinterpret(Float64,Base.get(colorschemes[colormap],f,crange))
    parameter!(p,"colors",UInt8.(floor.(rgb*255)))

    parameter!(p,"isopoints","none")
    parameter!(p,"isolines","none")
    parameter!(p,"aspect",args[:aspect])
    
    
    iso_pts=marching_triangles(pts,tris,f,collect(levels))
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
    
    # It seems a colorbar is best drawn via canvas...
    # https://github.com/Kitware/vtk-js/issues/1621
    bar_stops=collect(0:0.01:1)
    bar_rgb=reinterpret(Float64,get(colorschemes[colormap],bar_stops,(0,1)))
    bar_rgb=UInt8.(floor.(bar_rgb*255))
    p.jsdict["cbar"]=1
    p.jsdict["cbar_stops"]=bar_stops
    p.jsdict["cbar_colors"]=bar_rgb
    p.jsdict["cbar_levels"]=collect(colorbarticks)
    p.jsdict["cbar_fontsize"]=args[:legendfontsize]

    axis2d!(p; args...)
    p
end

"""
$(SIGNATURES)

Plot piecewise linear function on  triangular grid created from the tensor product of X and Y arrays as "heatmap".
Levels can be given as a number or as a range.
"""
contour!(p::PlutoVTKPlot,X,Y,f; kwargs...)=tricontour!(p,triang(X,Y)...,vec(f);kwargs...)


"""
$(SIGNATURES)

Plot isosurfaces given by `levels` and contour maps on planes given by the `*planes` parameters
for piecewise linear function on  tetrahedral mesh. 
"""
function tetcontour!(p::PlutoVTKPlot, pts, tets,func; kwargs...)
    reset!(p)

    default_args=(colormap=:viridis,
                  levels=5,
                  limits=:auto,
                  faces=nothing,
                  facemarkers=nothing,
                  facecolormap=nothing,
                  xplanes=[prevfloat(Inf)],
                  yplanes=[prevfloat(Inf)],
                  zplanes=[prevfloat(Inf)],
                  levelalpha=0.25,
                  outlinealpha=0.1)
    args=merge(p.args,default_args)
    args=merge(args,kwargs)

    levels,crange,colorbarticks=makeisolevels(func,
                                              args[:levels],
                                              args[:limits] == :auto ? (1,-1) : args[:limits] ,
                                              args[:colorbarticks]== :default ? nothing : args[:colorbarticks])

    colormap=args[:colormap]
    faces=args[:faces]
    facemarkers=args[:facemarkers]
    facecolormap=args[:facecolormap]

    command!(p,"tetcontour")
    xyzmin=zeros(3)
    xyzmax=ones(3)

    nbregions= facemarkers==nothing ? 0 :  maximum(facemarkers)

    if faces!=nothing && nbregions==0
        nbregions=1
        facemarkers=fill(Int32(1),size(faces,2))
    end

    if facecolormap==nothing
        facecolormap=bregion_cmap(nbregions)
    end
        
    @views for idim=1:3
        xyzmin[idim]=minimum(pts[idim,:])
        xyzmax[idim]=maximum(pts[idim,:])
    end 

    xplanes=args[:xplanes] 
    yplanes=args[:yplanes] 
    zplanes=args[:zplanes]  
        
    cpts0,faces0,values=marching_tetrahedra(pts,tets,func,
                                            primepoints=hcat(xyzmin,xyzmax),
                                            primevalues=crange,
                                            makeplanes(xyzmin,xyzmax,xplanes,yplanes,zplanes),
                                            levels;
                                            tol=0.0
                                            )

    cfaces=reshape(reinterpret(Int32,faces0),(3,length(faces0)))
    cpts=copy(reinterpret(Float32,cpts0))
    parameter!(p,"points",cpts)
    parameter!(p,"polys",vtkpolys(cfaces))
    nan_replacement=0.5*(crange[1]+crange[2])
    for i=1:length(values)
        if isnan(values[i]) || isinf(values[i])
            values[i]=nan_replacement
        end
    end
    # nan_replacement=0.0
    # for i=1:length(cpts)
    #     if isnan(cpts[i]) || isinf(cpts[i])
    #         cpts[i]=nan_replacement
    #     end
    # end

    crange=Float64.(crange)
    rgb=reinterpret(Float64,get(colorschemes[colormap],values,crange))
    

    
    if args[:levelalpha]>0
        nfaces=length(rgb)÷3
        rgba=zeros(UInt8,nfaces*4)
        irgb=0
        irgba=0
        for i=1:nfaces
            rgba[irgba+1]=UInt8(floor(rgb[irgb+1]*255))
            rgba[irgba+2]=UInt8(floor(rgb[irgb+2]*255))
            rgba[irgba+3]=UInt8(floor(rgb[irgb+3]*255))
            rgba[irgba+4]=UInt8(floor(args[:levelalpha]*255))
            irgb+=3
            irgba+=4
        end
        parameter!(p,"transparent",1)
        parameter!(p,"colors",rgba)
    else
        parameter!(p,"transparent",0)
        parameter!(p,"colors",UInt8.(floor.(rgb*255)))
    end        

    # It seems a colorbar is best drawn via canvas...
    # https://github.com/Kitware/vtk-js/issues/1621
    bar_stops=collect(0:0.01:1)
    bar_rgb=reinterpret(Float64,get(colorschemes[colormap],bar_stops,(0,1)))
    bar_rgb=UInt8.(floor.(bar_rgb*255))
    p.jsdict["cbar"]=1
    p.jsdict["cbar_stops"]=bar_stops
    p.jsdict["cbar_colors"]=bar_rgb
    p.jsdict["cbar_levels"]=vcat([crange[1]],levels,[crange[2]])
    p.jsdict["cbar_fontsize"]=args[:legendfontsize]


    if args[:outlinealpha]>0 && faces!=nothing
        parameter!(p,"outline",1)
        outline!(p,pts,faces,facemarkers,facecolormap,nbregions,xyzmin,xyzmax;alpha=args[:outlinealpha])
    else
        parameter!(p,"outline",0)
    end

    axis3d!(p; args...)
    p
    
end




"""
$(SIGNATURES)

Plot  triangular grid with optional region and boundary markers.
"""
function trimesh!(p::PlutoVTKPlot,pts, tris; kwargs...)
    reset!(p)

    default_args=(markers=nothing,
                  colormap=nothing,
                  edges=nothing,
                  gridscale=1.0,
                  edgemarkers=nothing,
                  edgecolormap=nothing)
    
    args=merge(p.args,default_args)
    args=merge(args,kwargs)
    parameter!(p,"aspect",args[:aspect])
    
    colormap=args[:colormap]
    markers=args[:markers]
    edgemarkers=args[:edgemarkers]
    edgecolormap=args[:edgecolormap]
    edges=args[:edges]

    ntri=size(tris,2)
    command!(p,"trimesh")

    cminmax=extrema(pts, dims=(2,))
    extent=maximum([cminmax[i][2]-cminmax[i][1] for i=1:2])
    zcoord=fill(extent/100,size(pts,2))


    parameter!(p,"points",vec(vcat(pts,zcoord')))
    parameter!(p,"polys",vtkpolys(tris))
    parameter!(p,"gridscale",args[:gridscale])
    parameter!(p,"aspect",args[:aspect])



    
    if markers!=nothing
        nregions=maximum(markers)
        if colormap==nothing
            colormap=region_cmap(nregions)
        end
        if typeof(colormap)==Symbol
            cmap=colorschemes[colormap]
        else
            cmap=ColorScheme(colormap)
        end
        rgb=reinterpret(Float64,get(cmap,markers,(1,size(cmap))))
        parameter!(p,"colors",UInt8.(floor.(rgb*255)))

        bar_stops=collect(1:size(cmap))
        bar_rgb=reinterpret(Float64,get(cmap,bar_stops,(1,size(cmap))))
        bar_rgb=UInt8.(floor.(bar_rgb*255))
        p.jsdict["cbar"]=2
        p.jsdict["cbar_stops"]=bar_stops
        p.jsdict["cbar_colors"]=bar_rgb
        p.jsdict["cbar_levels"]=collect(1:size(cmap))
        p.jsdict["cbar_fontsize"]=args[:legendfontsize]
        
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
            (fmin,nbregions)=Int64.(extrema(edgemarkers))
            if edgecolormap==nothing
                edgecolormap=bregion_cmap(nbregions)
            end
            if typeof(edgecolormap)==Symbol
                ecmap=colorschemes[edgecolormap]
            else
                ecmap=ColorScheme(edgecolormap)
            end
            edgergb=reinterpret(Float64,get(ecmap,edgemarkers,(1,size(ecmap))))
            parameter!(p,"linecolors",UInt8.(floor.(edgergb*255)))

            ebar_stops=collect(1:size(ecmap))
            ebar_rgb=reinterpret(Float64,get(ecmap,ebar_stops,(1,size(ecmap))))
            ebar_rgb=UInt8.(floor.(ebar_rgb*255))
            p.jsdict["ecbar_stops"]=ebar_stops
            p.jsdict["ecbar_colors"]=ebar_rgb
            p.jsdict["ecbar_levels"]=collect(1:size(ecmap))
        else
            parameter!(p,"linecolors","none")
        end
    else
        parameter!(p,"lines","none")
        parameter!(p,"linecolors","none")
    end
    
    
    
    
    axis2d!(p; args...)
    p
end


"""
$(SIGNATURES)

Plot parts of tetrahedral mesh below the planes given by the `*plane` parameters.
"""
function tetmesh!(p::PlutoVTKPlot, pts, tets;kwargs...)
    reset!(p)

    default_args=(markers=nothing,
                  colormap=nothing,
                  faces=nothing,
                  facemarkers=nothing,
                  facecolormap=nothing,
                  xplanes=[prevfloat(Inf)],
                  yplanes=[prevfloat(Inf)],
                  zplanes=[prevfloat(Inf)],
                  outlinealpha=0.1)
    
    args=merge(p.args,default_args)
    args=merge(args,kwargs)
    
    markers=args[:markers]
    colormap=args[:colormap]
    faces=args[:faces]
    facemarkers=args[:facemarkers]
    facecolormap=args[:facecolormap]

    xplane=args[:xplanes][1]
    yplane=args[:yplanes][1]
    zplane=args[:zplanes][1]
    
    
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
        colormap=region_cmap(nregions)
    end

    if facecolormap==nothing
        facecolormap=bregion_cmap(nbregions)
    end


    
    xyzmin=zeros(3)
    xyzmax=ones(3)

    @views for idim=1:3
        xyzmin[idim]=minimum(pts[idim,:])
        xyzmax[idim]=maximum(pts[idim,:])
    end

    
    xyzcut=[xplane,yplane,zplane]

    regpoints0,regfacets0=extract_visible_cells3D(pts,tets,markers,nregions,
                                                                xyzcut,
                                                                primepoints=hcat(xyzmin,xyzmax)
                                                                )
    
    points=hcat( [          reshape(reinterpret(Float32,regpoints0[i]),(3,length(regpoints0[i])))   for i=1:nregions]... )
    facets=vcat( [vtkpolys( reshape(reinterpret(Int32,  regfacets0[i]),(3,length(regfacets0[i]))),
                            offset= ( i==1 ? 0 : sum(k->length(regpoints0[k]),1:i-1) ) )
                            for i=1:nregions]... )

    
    regmarkers=vcat([fill(i,length(regfacets0[i])) for i=1:nregions]...)

    if typeof(colormap)==Symbol
        cmap=colorschemes[colormap]
    else
        cmap=ColorScheme(colormap)
    end
    rgb=reinterpret(Float64,get(cmap,regmarkers,(1,size(cmap))))
    nfaces=length(rgb)÷3

    
    bar_stops=collect(1:size(cmap))
    bar_rgb=reinterpret(Float64,get(cmap,bar_stops,(1,size(cmap))))
    bar_rgb=UInt8.(floor.(bar_rgb*255))
    p.jsdict["cbar"]=2
    p.jsdict["cbar_stops"]=bar_stops
    p.jsdict["cbar_colors"]=bar_rgb
    p.jsdict["cbar_levels"]=collect(1:size(cmap))
    p.jsdict["cbar_fontsize"]=args[:legendfontsize]


    if faces!=nothing
        bregpoints0,bregfacets0=extract_visible_bfaces3D(pts,faces,facemarkers,nbregions,
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
        facergb=reinterpret(Float64,get(facecmap,bfacemarkers,(1,size(facecmap))))
        facets=vcat(facets,bregfacets)
        points=hcat(points,bregpoints)
        rgb=vcat(rgb,facergb)

        ecmap=facecmap
        ebar_stops=collect(1:size(ecmap))
        ebar_rgb=reinterpret(Float64,get(ecmap,ebar_stops,(1,size(ecmap))))
        ebar_rgb=UInt8.(floor.(ebar_rgb*255))
        p.jsdict["ecbar_stops"]=ebar_stops
        p.jsdict["ecbar_colors"]=ebar_rgb
        p.jsdict["ecbar_levels"]=collect(1:size(ecmap))
    end

    if args[:outlinealpha]>0 && faces!=nothing
        parameter!(p,"outline",1)
        outline!(p,pts,faces,facemarkers,facecolormap,nbregions,xyzmin,xyzmax;alpha=args[:outlinealpha])
    else
        parameter!(p,"outline",0)
    end

    parameter!(p,"polys",facets)
    parameter!(p,"points",vec(points))
    parameter!(p,"colors",UInt8.(floor.(rgb*255)))

    axis3d!(p; args...)
    p
end




"""
$(SIGNATURES)

2D quiver.
"""
function quiver2d!(p::PlutoVTKPlot, pts, qvec; kwargs...)
    args=merge(p.args,kwargs)
    if args[:clear]
        reset!(p)
    end
    command!(p,"quiver")
    zcoord=zeros(size(pts,2))

    cminmax=extrema(pts, dims=(2,))

    # length scale for arrowhead drawing
    extent=maximum([cminmax[i][2]-cminmax[i][1] for i=1:2])
    l0=extent/150

    pts3=vcat(pts,zcoord')
    vec3=vcat(qvec,zcoord')
    

    nvec=size(qvec,2)
    # Calculate points for arrowheads
    apts=copy(pts3)
    bpts=copy(pts3)

    # possibly make them parameters to satisfy user's taste
    arrowtip_width_factor=1.5
    arrowtip_length_factor=4.0
   
    for i=1:nvec

        #normal to vectors
        #     vnorm=sqrt(qvec[1,i]^2+qvec[2,i]^2)
        # We don't normalise it as everything should be scaled with vector length
        normal1= arrowtip_width_factor*l0*qvec[2,i]
        normal2=-arrowtip_width_factor*l0*qvec[1,i]


        # distance from tip
        dist1=arrowtip_length_factor*l0*qvec[1,i]
        dist2=arrowtip_length_factor*l0*qvec[2,i]

        # side points for arrowhead
        apts[1,i]=pts[1,i]+qvec[1,i]-dist1+normal1
        apts[2,i]=pts[2,i]+qvec[2,i]-dist2+normal2

        bpts[1,i]=pts[1,i]+qvec[1,i]-dist1-normal1
        bpts[2,i]=pts[2,i]+qvec[2,i]-dist2-normal2
    end


    qpts=hcat(pts3,pts3+vec3,apts,bpts)

    
    npts=size(pts,2)
    lines=Vector{UInt32}(undef,3*npts+4*npts)
    iline=0
    ipt=0
    for i=1:npts

        # vector line
        lines[iline+1]=2
        lines[iline+2]=ipt      # pts3
        lines[iline+3]=npts+ipt # pts3+vec3 
        iline=iline+3


        # arrowhead
        lines[iline+1]=3
        lines[iline+2]=2*npts+ipt  # apts
        lines[iline+3]=npts+ipt    # pts3+vec3
        lines[iline+4]=3*npts+ipt  # bpts

        iline=iline+4
        
        ipt=ipt+1
    end

    parameter!(p,"points",vec(qpts))
    parameter!(p,"lines",lines)
    axis2d!(p; args...)
    p
end



#####################################
# Experimental part
"""
$(SIGNATURES)

Experimental: Plot piecewise linear function on  triangular grid given by points and triangles
as matrices
"""
function triplot!(p::PlutoVTKPlot,pts, tris,f; kwargs...)
    reset!(p)
    args=merge((kwargs...),p.args)
    command!(p,"triplot")
    # make 3D points from 2D points by adding function value as
    # z coordinate
    p.jsdict["cbar"]=0
    parameter!(p,"points",vec(vcat(pts,f')))
    parameter!(p,"polys",vtkpolys(tris))
    axis3d!(p;args...)
    p
end


function plot!(p::PlutoVTKPlot,x,y; kwargs...)
    reset!(p)
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
