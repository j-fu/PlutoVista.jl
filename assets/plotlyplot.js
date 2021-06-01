


function plotlyplot(uuid,jsdict,w,h)
{

    var cmdcount=jsdict.cmdcount
    for (var icmd = 1 ; icmd <= cmdcount ; icmd++)
    {  
        var cmd=icmd.toString() 
        if (jsdict[cmd]=="triplot"|| jsdict[cmd]=="triupdate")
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
        }
    }
}
