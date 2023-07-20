
@testset "Graph interface" begin

    g = Graph{Int, Tuple{Int, Int}}()
    vs = vertices(g)
    es = edges(g)
    push!(vs, 2, 4, 6, 8, 10, 12)
    push!(es, (4, 6), (4, 8), (8, 12), (10, 12))

end
