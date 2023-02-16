/* Canvas based color bar for vtk plots */
function canvascolorbar(uuid,w,h,cbdict)
{
    var hpad=0.1*h
    var h0=hpad
    var h1=h-hpad
    var dh=h1-h0
    var canvas = document.getElementById(uuid);
    var ctx = canvas.getContext("2d");
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    ctx.textBaseline = "middle"
    ctx.textAlign = "left"

    if (cbdict["cbar"]==1) /*gradient colorbar for contour plots */
    {
        var cstops=cbdict["cbar_stops"]
        var colors=cbdict["cbar_colors"]
        var levels=cbdict["cbar_levels"]
        var legendfontsize=cbdict["cbar_fontsize"]
        ctx.font = `${legendfontsize}px Arial`

        var grad = ctx.createLinearGradient(0,h1, 0, h0);
        var icol=0
        for (var i=0;i<cstops.length;i++)
        {
            var color=`rgba(${colors[icol]},${colors[icol+1]},${colors[icol+2]})`;
            grad.addColorStop(cstops[i],color);
            icol+=3
        }
        ctx.fillStyle = grad;
        ctx.fillRect(0,h0,0.5*w,dh);


        ctx.strokeStyle = "rgb(0,0,0)"
        ctx.fillStyle = "rgb(0,0,0)"
        var lmin=levels[0]
        var lmax=levels[levels.length-1]
        for (var i=0;i<levels.length;i++)
        {
            var hlev=h1-dh*(levels[i]-lmin)/(lmax-lmin)
    	    ctx.beginPath();
            ctx.moveTo(0, hlev);
            ctx.lineTo(0.6*w,hlev);
     	    ctx.stroke();
            ctx.fillText(levels[i].toPrecision(3),0.7*w,hlev)
        }
        
    }
    /* discontinuous colorbars for cell and boundary region numbers*/
    else if (cbdict["cbar"]==2) 
    {
        var cstops=cbdict["cbar_stops"]
        var colors=cbdict["cbar_colors"]
        var levels=cbdict["cbar_levels"]
        var legendfontsize=cbdict["cbar_fontsize"]
        ctx.font = `${legendfontsize}px Arial`

        // Region markers
        if (cstops!=undefined)
        {
            var lmin=levels[0]
            var lmax=levels[levels.length-1]+1
            
            var icol=0
            var hl=dh*(levels[2]-levels[1])/(lmax-lmin)
            for (var i=0;i<levels.length;i++)
            {
                var hlev=h1-dh*(levels[i]-lmin)/(lmax-lmin)
                var color=`rgba(${colors[icol]},${colors[icol+1]},${colors[icol+2]})`;
                ctx.strokeStyle = color
                ctx.fillStyle = color
                ctx.fillRect(0,hlev,0.4*w,-hl)
                icol+=3
            }
            
            ctx.strokeStyle = "rgb(0,0,0)"
            ctx.fillStyle = "rgb(0,0,0)"
            for (var i=0;i<levels.length;i++)
            {
                var hlev=h1-dh*(levels[i]-lmin)/(lmax-lmin)-0.5*hl
                ctx.fillText(`${levels[i]}`,0.5*w,hlev)
            }
        }
        
        // edge markers
        var cstops=cbdict["ecbar_stops"]
        var colors=cbdict["ecbar_colors"]
        var levels=cbdict["ecbar_levels"]
        if (cstops!=undefined)
        {
            var lmin=levels[0]
            var lmax=levels[levels.length-1]+1
            
            var icol=0
            var hl=dh*(levels[2]-levels[1])/(lmax-lmin)
            for (var i=0;i<levels.length;i++)
            {
                var hlev=h1-dh*(levels[i]-lmin)/(lmax-lmin)
                var color=`rgba(${colors[icol]},${colors[icol+1]},${colors[icol+2]})`;
                ctx.strokeStyle = color
                ctx.fillStyle = color
                ctx.fillRect(w,hlev,0.4*w,-hl)
                icol+=3
            }
            
            ctx.strokeStyle = "rgb(0,0,0)"
            ctx.fillStyle = "rgb(0,0,0)"
            for (var i=0;i<levels.length;i++)
            {
                var hlev=h1-dh*(levels[i]-lmin)/(lmax-lmin)-0.5*hl
                ctx.fillText(`${levels[i]}`,1.5*w,hlev)
            }
        }
    }
}
