

# GraphTypes.jl

GraphTypes.jl provides the `Graph` type, which represents an undirected graph and conforms to
the `AbstractGraph` interface defined in
[GraphInterface.jl](https://github.com/CameronBieganek/GraphInterface.jl).

## Example Usage

```julia
julia> using GraphTypes

julia> g = Graph{Char}()
Graph:
    Vertex type: Char
    Number of vertices: 0
    Number of edges: 0

julia> add_vertex!(g, 'a')
Graph:
    Vertex type: Char
    Number of vertices: 1
    Number of edges: 0

julia> add_edge!(g, 'b', 'c')
Graph:
    Vertex type: Char
    Number of vertices: 3
    Number of edges: 1

julia> add_edge!(g, Edge("cd"))
Graph:
    Vertex type: Char
    Number of vertices: 4
    Number of edges: 2

julia> collect(vertices(g))
4-element Vector{Char}:
 'a': ASCII/Unicode U+0061 (category Ll: Letter, lowercase)
 'c': ASCII/Unicode U+0063 (category Ll: Letter, lowercase)
 'd': ASCII/Unicode U+0064 (category Ll: Letter, lowercase)
 'b': ASCII/Unicode U+0062 (category Ll: Letter, lowercase)

julia> collect(edges(g))
2-element Vector{Edge{Char}}:
 c -- d
 b -- c

julia> 'a' in vertices(g)
true

julia> Edge("bc") in edges(g)
true

julia> weight(g, 'b', 'c')
1.0

julia> neighbors(g, 'c')
Neighbors: {d, b}

julia> e = first(edges(g))
Edge:
    c -- d

julia> u, v = e;

julia> u
'c': ASCII/Unicode U+0063 (category Ll: Letter, lowercase)

julia> v
'd': ASCII/Unicode U+0064 (category Ll: Letter, lowercase)
```
