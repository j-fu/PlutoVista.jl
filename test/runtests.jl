ENV["PLUTO_USE_MANIFEST"]="true"
using Test, Pluto,PlutoVista



function rendernotebook(name)
    input=joinpath(@__DIR__,"..","examples",name*".jl")
    session = Pluto.ServerSession();
    notebook = Pluto.SessionActions.open(session, input; run_async=false)
    html_contents = Pluto.generate_html(notebook)
end

@test length(rendernotebook("plutovista"))>0

           
