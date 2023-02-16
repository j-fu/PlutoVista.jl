
function plutocanvasplot(canvas_uuid,jsdict)
{
    var canvas = document.getElementById(canvas_uuid);
    var ctx = canvas.getContext("2d");

    var fillstyle="rgb(255,255,255)"
    var linestyle="rgb(0,0,0)"
    var textstyle="rgb(0,0,0)"
    var linewidth=1
    
    for (var cmd = 1 ; cmd <= jsdict.cmdcount ; cmd++)
    {  
        if (jsdict[cmd]=="polyline")
        {
    	    var x=jsdict[cmd+"x"]
 	    var y=jsdict[cmd+"y"]
            ctx.lineWidth=linewidth
            ctx.strokeStyle=linestyle
	    ctx.beginPath();
	    for (var i = 0; i < x.length; i++)
            {
                ctx.lineTo(x[i], y[i]);
            }
	    ctx.stroke();
        }



        else if (jsdict[cmd]=="lines")
        {
    	    var x=jsdict[cmd+"x"]
 	    var y=jsdict[cmd+"y"]
            ctx.lineWidth=linewidth
            ctx.strokeStyle=linestyle
	    for (var i = 0; i < x.length; i+=2)
            {
    	        ctx.beginPath();
                ctx.moveTo(x[i], y[i]);
                ctx.lineTo(x[i+1], y[i+1]);
     	        ctx.stroke();
            }
        }

        else if (jsdict[cmd]=="polygon")
        {
    	    var x=jsdict[cmd+"x"]
 	    var y=jsdict[cmd+"y"]
            ctx.fillStyle=fillstyle
	    ctx.beginPath();
	    for (var i = 0; i < x.length; i++)
            {
                ctx.lineTo(x[i], y[i]);
            }
	    ctx.fill();
        }

        
        else if (jsdict[cmd]=="linecolor")
        {
    	    var rgb=jsdict[cmd+"rgb"]
            linestyle="rgb("+rgb[0]+","+rgb[1]+","+rgb[2]+")"  
        }

        else if (jsdict[cmd]=="linewidth")
        {
    	    linewidth=jsdict[cmd+"w"]
        }

        
        else if (jsdict[cmd]=="fillcolor")
        {
    	    var rgb=jsdict[cmd+"rgb"]
            fillstyle="rgb("+rgb[0]+","+rgb[1]+","+rgb[2]+")"  
        }


        else if (jsdict[cmd]=="textcolor")
        {
    	    var rgb=jsdict[cmd+"rgb"]
            textstyle="rgb("+rgb[0]+","+rgb[1]+","+rgb[2]+")"  
        }


        else if (jsdict[cmd]=="textsize")
        {
            ctx.font = jsdict[cmd+"pt"]+"px Arial"
        }

        else if (jsdict[cmd]=="textalign")
        {
            ctx.textAlign = jsdict[cmd+"align"]
        }

        else if (jsdict[cmd]=="textbaseline")
        {
            ctx.textBaseline = jsdict[cmd+"align"]
        }

        
        else if (jsdict[cmd]=="text")
        {
            ctx.fillStyle=textstyle
            ctx.strokeStyle=textstyle
            ctx.fillText(jsdict[cmd+"txt"],jsdict[cmd+"x"],jsdict[cmd+"y"])
        }
    }
}

