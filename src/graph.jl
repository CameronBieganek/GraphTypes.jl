

# TODO: Account for self-loops.

struct Graph{V, E}
    adj::Dict{V, Set{V}}
    edges::Set{E}
end

function Graph{V, E}() where {V, E}
    adj = Dict{V, Set{V}}()
    edges = Set{E}()
    Graph{V, E}(adj, edges)
end

struct GraphVertices{G <: Graph}
    g::G
end

struct GraphEdges{G <: Graph}
    g::G
end

# Immutable iterator of vertex neighbors so that the underlying
# data structure cannot be (easily) modified by the user.
struct Neighbors{G, V}
    g::G
    v::V
end

adj(g::Graph) = g.adj
adj(vertices::GraphVertices) = adj(vertices.g)
adj(edges::GraphEdges) = adj(edges.g)

neighbors(g::Graph, v) = Neighbors(g, v)
raw(n::Neighbors) = adj(n.g)[n.v]

Base.iterate(n::Neighbors) = iterate(raw(n))
Base.iterate(n::Neighbors, state) = iterate(raw(n), state)

vertextype(::Type{Graph{V, E}}) where {V, E} = V
edgetype(::Type{Graph{V, E}}) where {V, E} = E

Base.eltype(::Type{GraphVertices{G}}) where G = vertextype(G)
Base.eltype(::Type{GraphEdges{G}}) where G = edgetype(G)

vertices(g::Graph) = GraphVertices(g)
edges(g::Graph) = GraphEdges(g)

raw(vertices::GraphVertices) = keys(adj(vertices))
raw(edges::GraphEdges) = edges.g.edges

Base.iterate(vertices::GraphVertices) = iterate(raw(vertices))
Base.iterate(vertices::GraphVertices, state) = iterate(raw(vertices), state)

Base.iterate(edges::GraphEdges) = iterate(raw(edges))
Base.iterate(edges::GraphEdges, state) = iterate(raw(edges), state)

Base.in(v, vertices::GraphVertices) = (v in raw(vertices))
Base.in(e, edges::GraphEdges) = (e in raw(edges))

function Base.push!(vertices::GraphVertices, vs...)
    for v in vs
        if v ∉ vertices
            adj(vertices)[v] = Set{eltype(vertices)}()
        end
    end
    return vertices
end

function Base.push!(edges::GraphEdges, es...)
    g = edges.g

    for e in es
        u, v = e
        push!(vertices(g), u, v)
        push!(raw(edges), e)
        push!(raw(neighbors(g, u)), v)
        push!(raw(neighbors(g, v)), u)
    end

    return edges
end
