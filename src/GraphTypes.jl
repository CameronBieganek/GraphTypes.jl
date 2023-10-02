
module GraphTypes

using GraphInterface: GraphInterface,
    AbstractGraph,
    AbstractUndirectedEdge,
    add_edge!,
    add_edges!,
    add_vertex!,
    add_vertices!,
    add_weighted_edges!,
    edges,
    ne,
    neighbors,
    nv,
    rem_edge!,
    rem_edges!,
    rem_vertex!,
    rem_vertices!,
    set_weight!,
    vertex_type,
    vertices,
    weight

export Graph,
    Edge,
    add_edge!,
    add_edges!,
    add_vertex!,
    add_vertices!,
    add_weighted_edges!,
    edges,
    ne,
    neighbors,
    nv,
    rem_edge!,
    rem_edges!,
    rem_vertex!,
    rem_vertices!,
    set_weight!,
    vertex_type,
    vertices,
    weight

include("graph.jl")

end
