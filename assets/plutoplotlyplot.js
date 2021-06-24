function create2DArray(A,n,m) {
    // thx, https://stackoverflow.com/a/16501723/8922290
    
    var arr = [];
    for (var i = 0; i < m; i++) {
        arr[i] = [];
        for (var j = 0; j < n; j++) {
            arr[i][j] = A[i * n + j];
        }
    }
    return arr;
}

function make_colorscale(cstops,colors)
{
    var colorscale=[]
    var icol=0
    for (var i=0;i<cstops.length;i++)
    {
        var color=`rgb(${colors[icol]},${colors[icol+1]},${colors[icol+2]})`;
        colorscale.push([cstops[i],color])
        icol+=3
    }
    return colorscale
}

function plutoplotlyplot(uuid,jsdict,w,h)
{

    var graphDiv = document.getElementById(uuid)

//    https://www.somesolvedproblems.com/2018/10/how-to-customize-plotlys-modebar.html
    var buttons=[["resetScale2d", "toImage","toggleHover"]]

    var layout = {
        autosize: false,
        width: w,
        height:h,
        title: {
            text: '',
            font: {
                size: 14
            }
        },
        
        modebar: {
            orientation: 'h',
        },
        
        hovermode: false,
        xaxis: {
            title: '',
            mirror: true,
            ticks: "outside",
            showline: true,
            zeroline: false,
            linewidth: 2,
            gridcolor: '#bdbdbd',
        },

        yaxis: {
            title: '',
            mirror: true,
            ticks: "outside",
            showline: true,
            zeroline: false,
            linewidth: 2,
            gridcolor: '#bdbdbd',
        },

        showlegend: false,
        legend:{
                bgcolor: 'rgba(255,255,255,0.8)',
        },
        
        margin: {
            l: 40,
            r: 10,
            b: 40,
            t: 30,
            pad: 0
        },
    };
            
    var data=[]
    
    for (var cmd = 1 ; cmd <= jsdict.cmdcount ; cmd++)
    {  

        if (jsdict[cmd]=="plot")
        {
            if (graphDiv.data!=undefined && jsdict[cmd+"clear"] == 1)
            {

                while(graphDiv.data.length>0)
                {
                    Plotly.deleteTraces(graphDiv, [0]);
                }
            }

            if (graphDiv.data!=undefined )
            {
                data=graphDiv.data
                layout=graphDiv.layout
            }
            
            
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


            
            
            var yrange=jsdict[cmd+"ylimits"]
            if (yrange[1]>yrange[0])
            {
                layout.yaxis.range=[yrange[0],yrange[1]]
                layout.yaxis.autorange=false
            }
            
            var xrange=jsdict[cmd+"xlimits"]
            if (xrange[1]>xrange[0])
            {
                layout.xaxis.range=[xrange[0],xrange[1]]
                layout.xaxis.autorange=false
            }

            layout.title.text=jsdict[cmd+"title"]

            layout.showlegend= layout.showlegend || (jsdict[cmd+"showlegend"] == 1 ? true : false)

            var lxpos=jsdict[cmd+"legendxpos"]
            var lypos=jsdict[cmd+"legendypos"]


            if (lxpos=='r')
            {
                layout.legend.xanchor="right"
                layout.legend.x=1
            }
            else if (lxpos=='c')
            {
              layout.legend.xanchor='center'
              layout.legend.x=0.5
            }
            else if (lxpos=='l')
            {
              layout.legend.xanchor='left'
              layout.legend.x=0
            }

            if (lypos=='t')
            {
              layout.legend.yanchor='top'
              layout.legend.y=1
            }
            else if (lypos=='c')
            {
              layout.legend.yanchor='center'
              layout.legend.y=0.5
            }
            else if (lypos=='b')
            {
              layout.legend.yanchor='bottom'
              layout.legend.y=0
            }

            
            layout.xaxis.title=jsdict[cmd+"xlabel"]
            layout.yaxis.title=jsdict[cmd+"ylabel"]
            
            
            data.push(trace)
            
        }
        else if (jsdict[cmd]=="contour")
        {
            var x=jsdict[cmd+"x"]
            var y=jsdict[cmd+"y"]
            var z=create2DArray(jsdict[cmd+"z"],x.length,y.length)
            var cstops=jsdict[cmd+"cstops"]
            var colors=jsdict[cmd+"colors"]

            var colorscale=make_colorscale(cstops,colors)

            
            var contour = {
                type: 'contour',
                x: x,
                y: y,
                z: z,
                colorscale: colorscale,
                contours: {
                    coloring: 'heatmap',
                    start: jsdict[cmd+"costart"],
                    end: jsdict[cmd+"coend"],
                    size: jsdict[cmd+"cosize"]
                }
            }
            data.push(contour)
        }
        else if (jsdict[cmd]=="tricontour")
        {
            var data=[]
            // this is slower than vtk, but has hover and
            // stays interactive in html
            var cstops=jsdict[cmd+"cstops"]
            var colors=jsdict[cmd+"colors"]

            var colorscale=make_colorscale(cstops,colors)
            var f=jsdict[cmd+"f"]
            var hinfo=[]
            for (var i=0; i<f.length; i++)
            {
                hinfo.push(`f: ${Number.parseFloat(f[i]).toPrecision(5)}`)
            }

            var mesh = {
                type: 'mesh3d',
                x: jsdict[cmd+"x"],
                y: jsdict[cmd+"y"],
                z: jsdict[cmd+"z"],
                i: jsdict[cmd+"i"],
                j: jsdict[cmd+"j"],
                k: jsdict[cmd+"k"],
                intensity: f,
                hoverinfo: "x+y+text",
                text: hinfo,
                colorscale: colorscale,
                name : ''
            }

  
            // shoehorn 3D scene into 2D mode
            layout.scene={
                dragmode : 'pan',
                camera : {
                    // dirty trick to get axis directions right (turntable rotation 180deg around z...)
                    up: {x:0.0, y:0.0001, z:-2},
                    eye: {x:-0.00000001, y:0.0, z:-2},
                    projection: {
                        hoverinfo: "x+y+text",
                        type: 'orthographic'
                    },
                },
                xaxis: { tickangle: 0,showspikes: false, autorange: "reversed"},
                yaxis: { tickangle: 0,showspikes: false},
                zaxis: { visible: false, showgrid: false,showspikes: false}
            }
            data.push(mesh)

            var iso_x=jsdict[cmd+"iso_x"]
            var iso_y=jsdict[cmd+"iso_y"]
            var iso_z=jsdict[cmd+"iso_z"]
            if (iso_x!="none")
            {
                var line = {
                    type: 'scatter3d',
                    x: iso_x,
                    y: iso_y,
                    z: iso_z,
                    hoverinfo: "none",
                    mode: 'lines',
                    name: '',
                    showlegend: false ,
                    line: {
                        color: "black"
                        //                    width: jsdict[cmd+"linewidth"],
                        //                    dash:  jsdict[cmd+"linestyle"],
                    }
                };
                data.push(line)
            }
            Plotly.newPlot(uuid, data,layout)
        }
        else if (jsdict[cmd]=="triplot"|| jsdict[cmd]=="triupdate")
        { //  Experimental, slower than vtk

            
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
            
            layout.scene={
                aspectmode : 'cube',
            }
            
            

            //            if (jsdict[cmd]=="triplot")
                Plotly.newPlot(uuid, [data],layout)
            //            else
            //                Plotly.react(uuid, [data],layout)
            return
        }
    }
    //,{displayModeBar: false,}
    // after all plot commands
    if (graphDiv.data==undefined)
    {
        Plotly.newPlot(uuid, data,layout, {modeBarButtons: buttons,})
    }
    else
    {
        Plotly.react(uuid, graphDiv.data,layout, {modeBarButtons: buttons,})
    }

    
}
