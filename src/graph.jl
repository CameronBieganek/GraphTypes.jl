

# An internal type for storing undirected edges.
struct Edge{V}
    u::V
    v::V
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

# This is its own type so that we can use `g.weights[u, v]` and `g.weights[e]`.
struct GraphWeights{V}
    lookup::Dict{Edge{V}, Float64}
end

struct Graph{V}
    adj::Dict{V, Set{V}}
    edges::Set{Edge{V}}
    weights::GraphWeights{V}
end

function Graph{V}() where {V}
    adj = Dict{V, Set{V}}()
    edges = Set{Edge{V}}()
    weights = GraphWeights(Dict{Edge{V}, Float64}())
    Graph{V}(adj, edges, weights)
end

Base.eltype(::Type{Graph{V}}) where {V} = V

struct GraphVertices{V, G <: Graph}
    g::G
    GraphVertices(g::Graph) = new{eltype(g), typeof(g)}(g)
end

struct GraphEdges{V, G <: Graph}
    g::G
    GraphEdges(g::Graph) = new{eltype(g), typeof(g)}(g)
end

struct Neighbors{V, G}
    g::G
    v::V
end

GraphInterface.vertices(g::Graph) = GraphVertices(g)
GraphInterface.edges(g::Graph) = GraphEdges(g)
GraphInterface.neighbors(g::Graph, v) = Neighbors(g, v)

raw(vertices::GraphVertices) = keys(vertices.g.adj)
raw(edges::GraphEdges) = edges.g.edges
raw(n::Neighbors) = n.g.adj[n.v]

Base.iterate(vertices::GraphVertices) = iterate(raw(vertices))
Base.iterate(vertices::GraphVertices, state) = iterate(raw(vertices), state)
Base.length(vertices::GraphVertices) = length(raw(vertices))
Base.eltype(::Type{<:GraphVertices{V}}) where {V} = V
Base.IteratorSize(::Type{<:GraphVertices}) = Base.HasLength()
Base.IteratorEltype(::Type{<:GraphVertices}) = Base.HasEltype()

Base.iterate(edges::GraphEdges) = iterate(raw(edges))
Base.iterate(edges::GraphEdges, state) = iterate(raw(edges), state)
Base.length(edges::GraphEdges) = length(raw(edges))
Base.eltype(::Type{<:GraphEdges{V}}) where {V} = Edge{V}
Base.IteratorSize(::Type{<:GraphEdges}) = Base.HasLength()
Base.IteratorEltype(::Type{<:GraphEdges}) = Base.HasEltype()

Base.iterate(n::Neighbors) = iterate(raw(n))
Base.iterate(n::Neighbors, state) = iterate(raw(n), state)
Base.length(n::Neighbors) = length(raw(n))
Base.eltype(::Type{<:Neighbors{V}}) where {V} = V
Base.IteratorSize(::Type{<:Neighbors}) = Base.HasLength()
Base.IteratorEltype(::Type{<:Neighbors}) = Base.HasEltype()

Base.in(v, vertices::GraphVertices) = (v in raw(vertices))
Base.in(e, edges::GraphEdges) = (Edge(e...) in raw(edges))

function Base.getindex(weights::GraphWeights{V}, u, v) where {V}
    weights.lookup[Edge{V}(u, v)]
end

function Base.getindex(weights::GraphWeights, e)
    u, v = e
    weights[u, v]
end

function Base.setindex!(weights::GraphWeights{V}, w::Real, u, v) where {V}
    weights.lookup[Edge{V}(u, v)] = w
end

function Base.setindex!(weights::GraphWeights, w::Real, e)
    u, v = e
    weights[u, v] = w
end

function GraphInterface.add_vertex!(g::Graph{V}, v) where {V}
    if v ∉ vertices(g)
        g.adj[v] = Set{V}()
    end
    g
end

function GraphInterface.add_weighted_edge!(g::Graph, u, v, w::Real)
    g.weights[u, v] = w
    add_vertex!(g, u)
    add_vertex!(g, v)
    push!(g.adj[u], v)
    push!(g.adj[v], u)
    push!(g.edges, Edge{eltype(g)}(u, v))
    g
end

function GraphInterface.rem_vertex!(g::Graph, v)
    for w in neighbors(g, v)
        rem_edge!(g, v, w)
    end
    delete!(g.adj, v)
    g
end

function GraphInterface.rem_edge!(g::Graph, u, v)
    delete!(g.adj[u], v)
    delete!(g.adj[v], u)

    e = Edge{eltype(g)}(u, v)
    delete!(g.edges, e)
    delete!(g.weights.lookup, e)

    g
end

function Base.show(io::IO, g::Graph)
    println(io, "Graph:")
    println(io, "    Vertex type: ", eltype(g))
    println(io, "    Number of vertices: ", nv(g))
    print(io, "    Number of edges: ", ne(g))
end

function Base.show(io::IO, ::MIME"text/plain", e::Edge)
    print(io::IO, "Edge: {", e.u, ", ", e.v, "}")
end

function Base.show(io::IO, e::Edge)
    print(io::IO, "{", e.u, ", ", e.v, "}")
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
Base.show(io::IO, ::GraphWeights) = print(io, "GraphWeights")
