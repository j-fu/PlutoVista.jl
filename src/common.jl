abstract type AbstractVistaPlot end


"""
    command!(p<: AbstractVistaPlot,cmd)

Enter new command named `cmd`.

The idea is to pass one single Dict
with all plot data to javascript.

For this purpose we need a some "language".

Plot elements are described by commands executed
one after another. For this purpose, we use 
integers converted to strings as dict keys and pass the command
name as the corresponding entry.

The entry `cmdcount` keeps track of the number of
commands. So we can parse all commands from 1 to jsdict[:cmdcount]
in javascript in the same sequence as they have been entered.

Parameters are named and entered into the dictionary with the 
command number as prefix.

E.g. for a polyline as command number 5, we create the entries

```
"5" => "polyline"
"5x" => Vector of x coordinates in canvas coordinate system
"5y" => Vector of y coordinates in canvas coordinate system
"""
function command!(p::T,cmd) where {T <: AbstractVistaPlot}
    p.jsdict["cmdcount"]=p.jsdict["cmdcount"]+1
    pfx=string(p.jsdict["cmdcount"])
    p.jsdict[pfx]=cmd
    p
end


"""
    parameter!(p<: AbstractVistaPlot,name, value)

After [`command!`](@ref), create a parameter entry
"""
function parameter!(p::T,name,value) where {T <: AbstractVistaPlot}
    pfx=string(p.jsdict["cmdcount"])
    p.jsdict[pfx*name]=value
    p
end


function plutovista(;resolution=(300,300), datadim=1, kwargs...)
    if datadim==1
        PlotlyPlot(;resolution=resolution)
    else
        VTKPlot(;resolution=resolution)
    end
end

