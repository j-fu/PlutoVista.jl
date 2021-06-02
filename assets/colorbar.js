function colorbar(uuid,w,h,cbdict)
{
    if (cbdict["cbar"]==1)
    {
        var hpad=0.1*h
        var h0=hpad
        var h1=h-hpad
        var dh=h1-h0
        
        var canvas = document.getElementById(uuid);
        var ctx = canvas.getContext("2d");

        
        var cstops=cbdict["cstops"]
        var colors=cbdict["colors"]
        var levels=cbdict["levels"]

        var grad = ctx.createLinearGradient(0,h1, 0, h0);

        var icol=0
        for (var i=0;i<cstops.length;i++)
        {
            var color=`rgba(${colors[icol]},${colors[icol+1]},${colors[icol+2]})`;
            grad.addColorStop(cstops[i],color);
            icol+=3
        }

        ctx.fillStyle = grad;
        ctx.fillRect(0,h0,w,dh);


        ctx.font = "12px Arial"
        ctx.textBaseline = "middle"
        ctx.textAlign = "left"

        ctx.strokeStyle = "rgb(0,0,0)"
        ctx.fillStyle = "rgb(0,0,0)"
        var lmin=levels[0]
        var lmax=levels[levels.length-1]
        for (var i=0;i<levels.length;i++)
        {
            var hlev=h1-dh*(levels[i]-lmin)/(lmax-lmin)
    	    ctx.beginPath();
            ctx.moveTo(0, hlev);
            ctx.lineTo(1.1*w,hlev);
     	    ctx.stroke();
            ctx.fillText(`${levels[i]}`,1.2*w,hlev)
        }
        
    }
}


