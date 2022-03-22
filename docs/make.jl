# --- Setup

# Imports
using Documenter
using Boid

# Make sure that the Julia source code directory is on LOAD_PATH
push!(LOAD_PATH, "../src/")

# Set up DocMeta
DocMeta.setdocmeta!(Boid, :DocTestSetup, :(using Boid); recursive=true)

# --- Generate documentation

makedocs(;
    modules=[Boid],
    authors="Kevin Chu <kevin@velexi.com> and contributors",
    repo="https://github.com/velexi-corporation/Boid.jl/blob/{commit}{path}#{line}",
    sitename="Boid",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://velexi-corporation.github.io/Boid.jl/stable",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        #"Installation" => "installation.md",
        #"API" => "api.md",
        #"Acknowledgements" => "acknowledgements.md",
        "Index" => "docs-index.md",
    ],
)

# --- Deploy documentation

deploydocs(; repo="github.com/velexi-corporation/Boid.jl", devbranch="main")
