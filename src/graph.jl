

# TODO: Account for self-loops.

# An internal type for storing undirected edges.
struct Edge{V}
    u::V
    v::V
end

Edge(u, v) = Edge(promote(u, v)...)

function Base.hash(e::Edge, h::UInt)
    hash(:Edge, hash(e.u, h) ⊻ hash(e.v, h))
end

function Base.isequal(d::Edge, e::Edge)
    ( isequal(d.u, e.u) && isequal(d.v, e.v) ) ||
    ( isequal(d.u, e.v) && isequal(d.v, e.u) )
end

function Base.:(==)(d::Edge, e::Edge)
    ( d.u == e.u && d.v == e.v ) ||
    ( d.u == e.v && d.v == e.u )
end

struct Graph{V}
    adj::Dict{V, Set{V}}
    edges::Set{Edge{V}}
end

function Graph{V}() where {V}
    adj = Dict{V, Set{V}}()
    edges = Set{Edge{V}}()
    Graph{V}(adj, edges)
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

vertices(g::Graph) = GraphVertices(g)
edges(g::Graph) = GraphEdges(g)
neighbors(g::Graph, v) = Neighbors(g, v)

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
Base.in(e, edges::GraphEdges) = (e in raw(edges))

function add_vertex!(g::Graph{V}, v) where {V}
    if v ∉ vertices(g)
        g.adj[v] = Set{V}()
    end
    g
end

function add_edge!(g::Graph, u, v)
    add_vertex!(g, u)
    add_vertex!(g, v)
    push!(g.adj[u], v)
    push!(g.adj[v], u)
    push!(g.edges, Edge(u, v))
    g
end

function add_edge!(g::Graph, e)
    u, v = e
    add_edge!(g, u, v)
end
