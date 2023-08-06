
module GraphTypes

using GraphInterface: GraphInterface,
    add_edge!,
    add_edges!,
    add_vertex!,
    add_vertices!,
    edges,
    neighbors,
    vertices

export Graph,
    add_edge!,
    add_edges!,
    add_vertex!,
    add_vertices!,
    edges,
    neighbors,
    vertices


include("graph.jl")

end
