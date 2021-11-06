using HypertextLiteral

"""
    @bind width ScreenWidthGrabber()

Detect screen width from pluto notebook.
(see https://discourse.julialang.org/t/cell-width-in-pluto-notebook/49761/3)
"""
struct ScreenWidthGrabber end

function Base.show(io::IO, m::MIME"text/html", ::ScreenWidthGrabber)
    show(io,m, @htl("""
	<div>
	<script>
		var div = currentScript.parentElement
		div.value = screen.width
	</script>
	</div>
    """))
end


"""
    PlutoCellWidener(px)

Set pluto cell width to a given number of pixels.

(see https://discourse.julialang.org/t/cell-width-in-pluto-notebook/49761/3)

Setting width larger than standard may interfer with other Pluto functionality.
"""
struct PlutoCellWidener
	width
end

function Base.show(io::IO, m::MIME"text/html", widener::PlutoCellWidener)
    show(io,m, @htl("""
		<style>
			pluto-notebook {
				margin: auto;
				width: $(widener.width)px;
			}
		</style>
	    """)
	 )
end
