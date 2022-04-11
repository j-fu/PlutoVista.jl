using Test, Pluto

function testnotebook(input)
    # de-markdown eventual cells with Pkg.develop and write
    # to pluto-tmp.jl
    notebook=Pluto.load_notebook_nobackup(input)
    pkgcellfortest=findfirst(c->occursin("Pkg.activate",c.code),notebook.cells)
    if  pkgcellfortest!=nothing
        # de-markdown pkg cell
        notebook.cells[pkgcellfortest].code=replace(notebook.cells[pkgcellfortest].code,"md"=>"")
        notebook.cells[pkgcellfortest].code=replace(notebook.cells[pkgcellfortest].code,"\"\"\""=>"")
        notebook.cells[pkgcellfortest].code=replace(notebook.cells[pkgcellfortest].code,";"=>"")
        @info "Pkg cell: $(pkgcellfortest)\n$(notebook.cells[pkgcellfortest].code)"
        Pluto.save_notebook(notebook,"pluto-tmp.jl")
        input="pluto-tmp.jl"
        sleep(1)
    end

    # run notebook and check for cell errors
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


@testset "notebooks" begin
    notebooks=["vtktest.jl","plotlytest.jl","plutovista.jl"]
    for notebook in notebooks
        input=joinpath(@__DIR__,"..","examples",notebook)
        @info "notebook: $(input)"
        @test testnotebook(input)
    end
end

