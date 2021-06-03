
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
            
    
    for (var cmd = 1 ; cmd <= jsdict.cmdcount ; cmd++)
    {  

        if (jsdict[cmd]=="plot")
        {
            
            var mode  = jsdict[cmd+"markertype"] == "none" ? "lines" : "lines+markers"
            var color=jsdict[cmd+"color"] 
            var rgb = color == "auto" ? ""      : `"rgb(${color[0]},${color[1]},${color[2]})"`
            var trace = {
                x: jsdict[cmd+"x"],
                y: jsdict[cmd+"y"],
                mode: mode,
                name: jsdict[cmd+"label"],
                showlegend: jsdict[cmd+"label"] == "" ? false : true,
                marker: {
                    color: rgb,
                    symbol: jsdict[cmd+"markertype"],
                    size: jsdict[cmd+"markersize"],
                    maxdisplayed: jsdict[cmd+"markercount"],
                },
                line: {
                    color: rgb,
                    width: jsdict[cmd+"linewidth"],
                    dash:  jsdict[cmd+"linestyle"],
                }
            };
            data.push(trace)
        }
        else if (jsdict[cmd]=="triplot"|| jsdict[cmd]=="triupdate")
        { //  Experimental, slower than js
            var data = {
                type: 'mesh3d',
                x: jsdict[cmd+"x"],
                y: jsdict[cmd+"y"],
                z: jsdict[cmd+"z"],
                i: jsdict[cmd+"i"],
                j: jsdict[cmd+"j"],
                k: jsdict[cmd+"k"],
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
