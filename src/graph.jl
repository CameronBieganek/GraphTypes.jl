

struct Edge{V} <: AbstractUndirectedEdge
    u::V
    v::V
end

function Edge(itr)
    length(itr) == 2 || throw(ArgumentError("Iterator of vertices must have length 2."))
    Edge(itr...)
end

function Base.hash(e::Edge, h::UInt)
    hash(:Edge, hash(e.u, h) ⊻ hash(e.v, h))
end

function Base.:(==)(d::Edge, e::Edge)
    ( isequal(d.u, e.u) && isequal(d.v, e.v) ) ||
    ( isequal(d.u, e.v) && isequal(d.v, e.u) )
end

Base.iterate(e::Edge) = (e.u, 1)

function Base.iterate(e::Edge, state::Int)
    state == 1 && return (e.v, 2)
    nothing
end

Base.length(::Edge) = 2
Base.eltype(::Type{Edge{V}}) where {V} = V
Base.IteratorSize(::Type{<:Edge}) = Base.HasLength()
Base.IteratorEltype(::Type{<:Edge}) = Base.HasEltype()

struct Graph{V, W <: Number} <: AbstractGraph
    neighbors::Dict{V, Set{V}}
    edges::Set{Edge{V}}
    weight::Dict{Edge{V}, W}
end

function Graph{V}() where {V}
    neighbors = Dict{V, Set{V}}()
    edges = Set{Edge{V}}()
    weight = Dict{Edge{V}, Float64}()
    Graph{V, Float64}(neighbors, edges, weight)
end

struct GraphVertices{V}
    g::Graph{V}
end

struct GraphEdges{V}
    g::Graph{V}
end

struct Neighbors{V}
    g::Graph{V}
    v::V
end

GraphInterface.vertices(g::Graph) = GraphVertices(g)
GraphInterface.edges(g::Graph) = GraphEdges(g)
GraphInterface.neighbors(g::Graph{V}, v) where {V} = Neighbors{V}(g, v)

raw(vertices::GraphVertices) = keys(vertices.g.neighbors)
raw(edges::GraphEdges) = edges.g.edges
raw(n::Neighbors) = n.g.neighbors[n.v]

Base.iterate(vertices::GraphVertices) = iterate(raw(vertices))
Base.iterate(vertices::GraphVertices, state) = iterate(raw(vertices), state)
Base.length(vertices::GraphVertices) = length(raw(vertices))
Base.eltype(::Type{GraphVertices{V}}) where {V} = V
Base.IteratorSize(::Type{<:GraphVertices}) = Base.HasLength()
Base.IteratorEltype(::Type{<:GraphVertices}) = Base.HasEltype()

Base.iterate(edges::GraphEdges) = iterate(raw(edges))
Base.iterate(edges::GraphEdges, state) = iterate(raw(edges), state)
Base.length(edges::GraphEdges) = length(raw(edges))
Base.eltype(::Type{GraphEdges{V}}) where {V} = Edge{V}
Base.IteratorSize(::Type{<:GraphEdges}) = Base.HasLength()
Base.IteratorEltype(::Type{<:GraphEdges}) = Base.HasEltype()

Base.iterate(n::Neighbors) = iterate(raw(n))
Base.iterate(n::Neighbors, state) = iterate(raw(n), state)
Base.length(n::Neighbors) = length(raw(n))
Base.eltype(::Type{Neighbors{V}}) where {V} = V
Base.IteratorSize(::Type{<:Neighbors}) = Base.HasLength()
Base.IteratorEltype(::Type{<:Neighbors}) = Base.HasEltype()

Base.in(v, vertices::GraphVertices) = (v in raw(vertices))
Base.in(e, edges::GraphEdges) = (e in raw(edges))

Base.empty(::Graph{V}) where {V} = Graph{V}()

function GraphInterface.add_vertex!(g::Graph{V}, v) where {V}
    if v ∉ vertices(g)
        g.neighbors[v] = Set{V}()
    end
    g
end

function _add_edge_no_weight!(g::Graph, e, u, v)
    # add_vertex! needs to go first so that we get an error right away if
    # `isequal(convert(vertex_type(g), u), u)` is false, and similarly for `v`.
    add_vertex!(g, u)
    add_vertex!(g, v)

    push!(g.neighbors[u], v)
    push!(g.neighbors[v], u)

    push!(g.edges, e)

    g
end

function _add_edge_with_weight!(g::Graph, e, u, v, w)
    _add_edge_no_weight!(g, e, u, v)
    set_weight!(g, e, w)
    g
end

function GraphInterface.add_edge!(g::Graph{V}, u, v) where {V}
    e = Edge{V}(u, v)
    _add_edge_no_weight!(g, e, u, v)
end

function GraphInterface.add_edge!(g::Graph{V}, u, v, w::Number) where {V}
    e = Edge{V}(u, v)
    _add_edge_with_weight!(g, e, u, v, w)
end

function GraphInterface.add_edge!(g::Graph{V}, e::Edge{V}) where {V}
    u, v = e
    _add_edge_no_weight!(g, e, u, v)
end

function GraphInterface.add_edge!(g::Graph{V}, e::Edge{V}, w::Number) where {V}
    u, v = e
    _add_edge_with_weight!(g, e, u, v, w)
end

function GraphInterface.rem_vertex!(g::Graph, v)
    for w in neighbors(g, v)
        rem_edge!(g, v, w)
    end
    delete!(g.neighbors, v)
    g
end

function _rem_edge!(g, e, u, v)
    delete!(g.neighbors[u], v)
    delete!(g.neighbors[v], u)

    delete!(g.edges, e)
    delete!(g.weight, e)

    g
end

function GraphInterface.rem_edge!(g::Graph{V}, u, v) where {V}
    e = Edge{V}(u, v)
    _rem_edge!(g, e, u, v)
end

function GraphInterface.rem_edge!(g::Graph{V}, e::Edge{V}) where {V}
    u, v = e
    _rem_edge!(g, e, u, v)
end

function GraphInterface.weight(g::Graph{V}, u, v) where {V}
    weight(g, Edge{V}(u, v))
end

function GraphInterface.weight(g::Graph{V, W}, e::Edge{V}) where {V, W}
    get(g.weight, e, one(W))
end

function GraphInterface.set_weight!(g::Graph{V}, u, v, w::Number) where {V}
    set_weight!(g, Edge{V}(u, v), w)
end

function GraphInterface.set_weight!(g::Graph{V}, e::Edge{V}, w::Number) where {V}
    g.weight[e] = w
end

function Base.show(io::IO, g::Graph)
    println(io, "Graph:")
    println(io, "    Vertex type: ",        vertex_type(g))
    println(io, "    Number of vertices: ", nv(g))
    print(  io, "    Number of edges: ",    ne(g))
end

function Base.show(io::IO, ::MIME"text/plain", e::Edge)
    println(io, "Edge:")
    print(io, "    ", e.u, " -- ", e.v)
end

function Base.show(io::IO, e::Edge)
    print(io, e.u, " -- ", e.v)
end

function print_first_two(io::IO, itr_name, itr)
    _1, rest = Iterators.peel(itr)
    if isempty(rest)
        print(io, itr_name, ": {", _1, "}")
    else
        _2, rest_rest = Iterators.peel(rest)
        if isempty(rest_rest)
            print(io, itr_name, ": {", _1, ", ", _2, "}")
        else
            print(io, itr_name, ": {", _1, ", ", _2, ", ...}")
        end
    end
end

Base.show(io::IO, vs::GraphVertices) = print_first_two(io, "Vertices", vs)
Base.show(io::IO, es::GraphEdges) = print_first_two(io, "Edges", es)
Base.show(io::IO, ns::Neighbors) = print_first_two(io, "Neighbors", ns)
