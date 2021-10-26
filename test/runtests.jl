using Test, Pluto,PlutoVista,Pkg

function testnotebook(name)
    input=joinpath(@__DIR__,"..","examples",name*".jl")

    notebook=Pluto.load_notebook_nobackup(input)

    pkgcellfortest=findfirst(c->occursin("PkgCellForTest",c.code),notebook.cells)
    if  pkgcellfortest!=nothing
        notebook.cells[pkgcellfortest].code=replace(notebook.cells[pkgcellfortest].code,"md"=>"","\"\"\""=>"")
        @info "PkgCellForTest=$(pkgcellfortest)\n$(notebook.cells[pkgcellfortest].code)"
        Pluto.save_notebook(notebook,"tmp.jl")
        input="tmp.jl"
        sleep(1)
    end

    session = Pluto.ServerSession();
    notebook = Pluto.SessionActions.open(session, input; run_async=false)
    errored=false
    for c in notebook.cells
        if c.errored
            errored=true
            @error "Error in  $(c.cell_id): $(c.output.body[:msg])\n $(c.code)"
        end
    end
    !errored
end

notebooks=["vtktest","plotlytest","plutovista"]

@testset "notebooks" begin
    for notebook in notebooks
        @info "notebook: $(notebook)"
        @test testnotebook(notebook)
    end
end

#=

How to run notebook with dev'ed package:
name="tmanifest.jl"

Pluto.load_notebook(name,disable_writing_notebook_file=true)
pkgcellfortest=findfirst(c->occursin("PkgCellForTest",c.code),notebook.cells)
notebook.cells[pkgcellfortest].code=replace(notebook.cells[pkgcellfortest].code,"md"=>"","\"\"\""=>"")
Pluto.save_notebook(notebook,"tmp.jl")

find cell with Pkg
unmarkdown this cell
run tmp.jl

=#           
