
@testset "Graph interface (Int vertices)" begin

    e1 = Edge(1, 2)
    e2 = Edge(2, 1)
    e3 = Edge{Int}(0x01, 0x02)
    e4 = Edge{Int}(0x02, 0x01)
    e5 = Edge([1, 2])
    @test e1 == e2 == e3 == e4 == e5
    @test hash(e1) == hash(e2) == hash(e3) == hash(e4) == hash(e5)

    @test_throws ArgumentError Edge([1, 2, 3])
    @test_throws MethodError Edge(1, 2, 3)

    g = Graph{Int}()
    add_vertex!(g, 11)
    add_vertex!(g, 12)
    add_vertex!(g, 13)
    add_edge!(g, 11, 12)
    add_edge!(g, 11, 12) # No-op
    add_edge!(g, 12, 11) # No-op
    add_edge!(g, Int8(11), 12) # No-op
    add_edge!(g, Edge(12, 13))
    add_edge!(g, 13, Int8(11))

    @test vertex_type(g) == Int
    @test length(vertices(g)) == 3
    @test issetequal(vertices(g), [11, 12, 13])

    @test length(edges(g)) == 3
    @test issetequal(
        edges(g),
        Edge.([(11, 12), (12, 13), (13, 11)])
    )

    @test issetequal(neighbors(g, 12),   [11, 13])
    @test issetequal(neighbors(g, 11),   [12, 13])
    @test issetequal(neighbors(g, 11.0), [12, 13])

    vs = vertices(g)
    @test 11 in vs; @test 12 in vs; @test 13 in vs
    @test 14 ∉ vs; @test 20 ∉ vs

    es = edges(g)
    @test Edge(11, 12) in es
    @test Edge(12, 11) in es
    @test Edge{vertex_type(g)}(0x0b, 0x0c) in es
    @test Edge(11, 13) in es
    @test Edge(11, 14) ∉ es
    @test Edge(15, 15) ∉ es
    @test (11, 12) ∉ es
    @test [11, 12] ∉ es
    @test [1, 2, 3] ∉ es
    @test "hello" ∉ es

    eg = empty(g)
    @test vertex_type(eg) == Int
    @test isempty(vertices(eg))
    @test isempty(edges(eg))

    g = Graph{Int}()
    add_vertex!(g, 2.0)
    add_vertex!(g, 0x03)
    @test vertex_type(g) == Int
    @test issetequal(vertices(g), [2, 3])
    @test all(==(Int) ∘ typeof, vertices(g))

    g = Graph{Int}()
    add_edge!(g, 2.0, 3.0)
    add_edge!(g, 4, 0x05)
    @test issetequal(vertices(g), [2, 3, 4, 5])
    @test all(==(Int) ∘ typeof, vertices(g))
    @test issetequal(
        edges(g),
        Edge.([(2, 3), (4, 5)])
    )

    g = Graph{Int}()
    add_vertices!(g, [3, 4, 5, 6])
    @test issetequal(vertices(g), [3, 4, 5, 6])
    rem_vertex!(g, 4)
    rem_vertex!(g, 6)
    @test issetequal(vertices(g), [5, 3])

    g = Graph{Int}()
    add_edges!(g, Edge.([
        (1, 2),
        (2, 3),
        (3, 4),
        (4, 1)
    ]))
    rem_vertex!(g, 3)
    @test issetequal(vertices(g), [1, 2, 4])
    @test issetequal(
        edges(g),
        Edge.([(1, 2), (4, 1)])
    )

    g = Graph{Int}()
    add_edges!(g, Edge.([
        (1, 2),
        (2, 3),
        (3, 4),
        (4, 1)
    ]))
    rem_edge!(g, 2, 3)
    rem_edge!(g, 4, 3)
    @test issetequal(vertices(g), [1, 2, 3, 4])
    @test issetequal(
        edges(g),
        Edge.([(1, 2), (1, 4)])
    )

    g = Graph{Int}()
    add_vertices!(g, [1, 2, 3, 4])
    rem_vertices!(g, [2, 3])
    @test issetequal(vertices(g), [1, 4])

    g = Graph{Int}()
    add_edges!(g, Edge.([
        (1, 2),
        (2, 3),
        (3, 4),
        (4, 1)
    ]))
    rem_edges!(g, Edge.([(2, 3), (4, 3)]))
    @test issetequal(vertices(g), [1, 2, 3, 4])
    @test issetequal(
        edges(g),
        Edge.([(1, 2), (1, 4)])
    )

    g = Graph{Int}()
    add_edge!(g, 1, 2)
    @test g.weights[1, 2] == g.weights[2, 1] == 1
    add_edge!(g, 2, 3, 2.5)
    add_edge!(g, 3, 0x04, 42)
    @test g.weights[2, 3] == g.weights[3, 2] == 2.5
    @test (
        g.weights[0x03, 4] ==
        g.weights[3, 0x04] ==
        g.weights[3, 4]    ==
        g.weights[4, 3]    ==
        42
    )

    g = Graph{Int}()
    add_weighted_edges!(g, [
        (1, 2, 100),
        (2, 3, 4.2),
        (3, 4, 0x08)
    ])
    @test g.weights[1, 2] == g.weights[2, 1] == 100
    @test g.weights[2, 3] == g.weights[3, 2] == 4.2
    @test g.weights[3, 4] == g.weights[4, 3] == 8

end


@testset "Graph interface (Char vertices)" begin

    e1 = Edge('a', 'b')
    e2 = Edge('b', 'a')
    e3 = Edge("ab")
    @test e1 == e2
    @test hash(e1) == hash(e2) == hash(e3)

    g = Graph{Char}()
    add_vertex!(g, 'a')
    add_vertex!(g, 'b')
    add_vertex!(g, 'c')
    add_edge!(g, Edge('a', 'b'))
    add_edge!(g, Edge("bc"))
    add_edge!(g, 'c', 'a')
    add_edge!(g, 'a', 'c') # No-op

    @test vertex_type(g) == Char
    @test length(vertices(g)) == 3
    @test issetequal(vertices(g), "abc")

    @test length(edges(g)) == 3
    @test issetequal(
        edges(g),
        Edge.(["ab", "bc", "ca"])
    )

    @test issetequal(neighbors(g, 'b'), ['a', 'c'])
    @test issetequal(neighbors(g, 'a'), ['b', 'c'])

    vs = vertices(g)
    @test 'a' in vs; @test 'b' in vs; @test 'c' in vs
    @test 'd' ∉ vs; @test 'e' ∉ vs

    es = edges(g)
    @test Edge("ab") in es
    @test Edge('b', 'a') in es
    @test Edge("bc") in es
    @test Edge('a', 'c') in es
    @test Edge('a', 'd') ∉ es
    @test Edge("de") ∉ es

    eg = empty(g)
    @test vertex_type(eg) == Char
    @test isempty(vertices(eg))
    @test isempty(edges(eg))

    g = Graph{Char}()
    add_vertices!(g, "abcd")
    @test issetequal(vertices(g), "abcd")
    rem_vertex!(g, 'b')
    rem_vertex!(g, 'd')
    @test issetequal(vertices(g), ['a', 'c'])

    g = Graph{Char}()
    add_edges!(g, Edge.(["ab", "bc", "cd", "da"]))
    rem_vertex!(g, 'c')
    @test issetequal(vertices(g), "abd")
    @test issetequal(
        edges(g),
        Edge.(["ab", "ad"])
    )

    g = Graph{Char}()
    add_edges!(g, Edge.(["ab", "bc", "cd", "da"]))
    rem_edge!(g, 'b', 'c')
    rem_edge!(g, Edge("da"))
    @test issetequal(vertices(g), "abcd")
    @test issetequal(
        edges(g),
        Edge.(["ab", "cd"])
    )

    g = Graph{Char}()
    add_vertices!(g, "abcd")
    rem_vertices!(g, "bc")
    @test issetequal(vertices(g), ['a', 'd'])

    g = Graph{Char}()
    add_edges!(g, Edge.(["ab", "bc", "cd", "da"]))
    rem_edges!(g, Edge.(["bc", "da"]))
    @test issetequal(vertices(g), "abcd")
    @test issetequal(
        edges(g),
        Edge.(["ab", "cd"])
    )

    g = Graph{Char}()
    add_edge!(g, Edge("ab"))
    @test g.weights['a', 'b'] == g.weights['b', 'a'] == 1
    add_edge!(g, 'b', 'c', 2.5)
    add_edge!(g, Edge("cd"), 42)
    @test g.weights['b', 'c'] == g.weights['c', 'b'] == 2.5
    @test g.weights[Edge("cd")] == g.weights[Edge("dc")] == 42

    g = Graph{Char}()
    add_weighted_edges!(g, [
        ('a', 'b', 100),
        ('b', 'c', 4.2),
        ('c', 'd', 0x08)
    ])
    @test g.weights['a', 'b'] == g.weights['b', 'a'] == 100
    @test g.weights[Edge("bc")] == g.weights[Edge("cb")] == 4.2
    @test g.weights['c', 'd'] == g.weights['d', 'c'] == 8

end
