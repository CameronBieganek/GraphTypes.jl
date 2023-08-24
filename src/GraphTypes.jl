
module GraphTypes

using GraphInterface: GraphInterface,
    add_edge!,
    add_edges!,
    add_vertex!,
    add_vertices!,
    add_weighted_edge!,
    add_weighted_edges!,
    edges,
    ne,
    neighbors,
    nv,
    rem_edge!,
    rem_edges!,
    rem_vertex!,
    rem_vertices!,
    vertices

export Graph,
    add_edge!,
    add_edges!,
    add_vertex!,
    add_vertices!,
    add_weighted_edge!,
    add_weighted_edges!,
    edges,
    ne,
    neighbors,
    nv,
    rem_edge!,
    rem_edges!,
    rem_vertex!,
    rem_vertices!,
    vertices

include("graph.jl")

end
