[![linux-macos-windows](https://github.com/j-fu/PlutoVista.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/j-fu/PlutoVista.jl/actions/workflows/ci.yml)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://j-fu.github.io/PlutoVista.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://j-fu.github.io/PlutoVista.jl/dev)

PlutoVista.jl
==================

Plot library for Pluto notebooks based on [plotly.js](https://plotly.com/javascript/) for 1D data
and [vtk.js](https://kitware.github.io/vtk-js/index.html) (thus using WebGL)  for 2/3D data.

It uses the Pluto [💁 API to make objects available inside JS](https://github.com/fonsp/Pluto.jl/pull/1124)
to pass plot data from Julia to HTML5.

It can serve as a backend for [GridVisualize.jl](https://github.com/j-fu/GridVisualize.jl).

Example notebook: [pluto](https://raw.githubusercontent.com/j-fu/PlutoVista.jl/main/examples/plutovista.jl),
[html](https://j-fu.github.io/PlutoVista.jl/dev/plutovista.html)


