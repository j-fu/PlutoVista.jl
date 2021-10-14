using Documenter, Pluto,PlutoVista



function rendernotebook(name)
    input=joinpath(@__DIR__,"..","examples",name*".jl")
    output=joinpath(@__DIR__,"src",name*".html")
    session = Pluto.ServerSession();
    notebook = Pluto.SessionActions.open(session, input; run_async=false)
    html_contents = Pluto.generate_html(notebook)
    write(output, html_contents)
end


function mkdocs()

    rendernotebook("plutovista")
    

    makedocs(sitename="PlutoVista.jl",
             modules = [PlutoVista],
             doctest = false,
             clean = false,
             authors = "J. Fuhrmann",
             repo="https://github.com/j-fu/PlutoVista.jl",
             pages=[
                 "Home"=>"index.md",
                 "plotly.js API"=> "plotly.md",
                 "vtk.js API"=> "vtk.md",
                 "Internals" => "internals.md"
             ])
end

mkdocs()

deploydocs(repo = "github.com/j-fu/PlutoVista.jl.git",devbranch = "main")



