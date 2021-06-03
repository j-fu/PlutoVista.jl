
function plotlyplot(uuid,jsdict,w,h)
{
    var data=[]
    
    var layout = {
        autosize: false,
        width: w,
        height:h,
        
        xaxis: {
            title: 'x'
        },
        yaxis: {
            title: 'y'
        },
        
        
        margin: {
            l: 40,
            r: 0,
            b: 40,
            t: 30,
            pad: 4
        },
    };
            
    
    var cmdcount=jsdict.cmdcount
    for (var icmd = 1 ; icmd <= cmdcount ; icmd++)
    {  
        var cmd=icmd.toString()

        var mode = jsdict[cmd+"_markertype"] == "none" ? "lines" : "lines+markers"

        if (jsdict[cmd]=="plot")
        {
            var color=jsdict[cmd+"_color"]
            var col=`"rgb(${color[0]},${color[1]},${color[2]})"`
            var trace = {
                x: jsdict[cmd+"_x"],
                y: jsdict[cmd+"_y"],
                mode: mode,
                name: jsdict[cmd+"_label"],
                showlegend: jsdict[cmd+"_label"] == "" ? false : true,
                marker: {
                    color: col,
                    symbol: jsdict[cmd+"_markertype"],
                    size: jsdict[cmd+"_markersize"],
                    maxdisplayed: jsdict[cmd+"_markercount"],
                },
                line: {
                    color: col,
                    width: jsdict[cmd+"_linewidth"],
                    dash: jsdict[cmd+"_linestyle"],
                }
            };
            data.push(trace)
        }
        else if (jsdict[cmd]=="triplot"|| jsdict[cmd]=="triupdate")
        {
            var data = {
                type: 'mesh3d',
                x: jsdict[cmd+"_x"],
                y: jsdict[cmd+"_y"],
                z: jsdict[cmd+"_z"],
                i: jsdict[cmd+"_i"],
                j: jsdict[cmd+"_j"],
                k: jsdict[cmd+"_k"],
                facecolor: [0.75,0.75,0.75],
                flatshading: false,
                lightposition: {x: -10, y: 0, z:20},
                lighting: {specular: 2,
                           diffuse: 0.8,
                           fresnel: 0.5,
                           ambient: 0.25,
                          },
            }
            
            var layout = {
                autosize: false,
                width: w,
                height:h,
                margin: {
                    l: 0,
                    r: 0,
                    b: 0,
                    t: 0,
                    pad: 4
                },
            };
            
            if (jsdict[cmd]=="triplot")
                Plotly.newPlot(uuid, [data],layout)
            else
                Plotly.react(uuid, [data],layout)
            return
        }
    }

    Plotly.newPlot(uuid, data,layout)

}
