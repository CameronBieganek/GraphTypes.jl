
@testset "Graph interface (Int vertices)" begin

    g = Graph{Int}()
    add_vertex!(g, 11)
    add_vertex!(g, 12)
    add_vertex!(g, 13)
    add_edge!(g, (11, 12))
    add_edge!(g, [12, 13])
    add_edge!(g, 13 => 11)

    @test eltype(g) == Int
    @test length(vertices(g)) == 3
    @test issetequal(vertices(g), [11, 12, 13])

    @test length(edges(g)) == 3
    @test issetequal(
        Set.(edges(g)),
        [Set((11, 12)), Set((12, 13)), Set((13, 11))]
    )

    @test issetequal(neighbors(g, 12), [11, 13])
    @test issetequal(neighbors(g, 11), [12, 13])

    vs = vertices(g)
    @test 11 in vs; @test 12 in vs; @test 13 in vs
    @test 14 ∉ vs; @test 20 ∉ vs

    es = edges(g)
    @test [12, 11] in es
    @test (12 => 13) in es
    @test (11, 13) in es
    @test (11, 14) ∉ es
    @test (15, 15) ∉ es

    g = Graph{Int}()
    add_vertex!(g, 2.0)
    add_vertex!(g, 0x03)
    @test eltype(g) == Int
    @test issetequal(vertices(g), [2, 3])
    @test all(==(Int) ∘ typeof, vertices(g))

    g = Graph{Int}()
    add_edge!(g, 2.0, 3.0)
    add_edge!(g, 4, 0x05)
    @test issetequal(vertices(g), [2, 3, 4, 5])
    @test all(==(Int) ∘ typeof, vertices(g))
    @test issetequal(
        Set.(edges(g)),
        [Set((2, 3)), Set((4, 5))]
    )

    g = Graph{Int}()
    add_vertices!(g, [3, 4, 5, 6])
    @test issetequal(vertices(g), [3, 4, 5, 6])
    rem_vertex!(g, 4)
    rem_vertex!(g, 6)
    @test issetequal(vertices(g), [5, 3])

    g = Graph{Int}()
    add_edges!(g, [
        (1, 2),
        (2, 3),
        (3, 4),
        (4, 1)
    ])
    rem_vertex!(g, 3)
    @test issetequal(vertices(g), [1, 2, 4])
    @test issetequal(
        Set.(edges(g)),
        [Set((1, 2)), Set((4, 1))]
    )

    g = Graph{Int}()
    add_edges!(g, [
        (1, 2),
        (2, 3),
        (3, 4),
        (4, 1)
    ])
    rem_edge!(g, 2, 3)
    rem_edge!(g, 4, 3)
    @test issetequal(vertices(g), [1, 2, 3, 4])
    @test issetequal(
        Set.(edges(g)),
        [Set((1, 2)), Set((1, 4))]
    )

    g = Graph{Int}()
    add_vertices!(g, [1, 2, 3, 4])
    rem_vertices!(g, [2, 3])
    @test issetequal(vertices(g), [1, 4])

    g = Graph{Int}()
    add_edges!(g, [
        (1, 2),
        (2, 3),
        (3, 4),
        (4, 1)
    ])
    rem_edges!(g, [(2, 3), (4, 3)])
    @test issetequal(vertices(g), [1, 2, 3, 4])
    @test issetequal(
        Set.(edges(g)),
        [Set((1, 2)), Set((1, 4))]
    )

    g = Graph{Int}()
    add_edge!(g, 1, 2)
    @test g.weights[1, 2] == g.weights[2, 1] == 1
    add_weighted_edge!(g, 2, 3, 2.5)
    add_weighted_edge!(g, 3, 0x04, 42)
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

    g = Graph{Char}()
    add_vertex!(g, 'a')
    add_vertex!(g, 'b')
    add_vertex!(g, 'c')
    add_edge!(g, ('a', 'b'))
    add_edge!(g, "bc")
    add_edge!(g, ['c', 'a'])

    @test eltype(g) == Char
    @test length(vertices(g)) == 3
    @test issetequal(vertices(g), "abc")

    @test length(edges(g)) == 3
    @test issetequal(
        Set.(edges(g)),
        [Set("ab"), Set("bc"), Set("ca")]
    )

    @test issetequal(neighbors(g, 'b'), ['a', 'c'])
    @test issetequal(neighbors(g, 'a'), ['b', 'c'])

    vs = vertices(g)
    @test 'a' in vs; @test 'b' in vs; @test 'c' in vs
    @test 'd' ∉ vs; @test 'e' ∉ vs

    es = edges(g)
    @test ['b', 'a'] in es
    @test "bc" in es
    @test ('a', 'c') in es
    @test ('a', 'd') ∉ es
    @test "de" ∉ es

    g = Graph{Char}()
    add_vertices!(g, "abcd")
    @test issetequal(vertices(g), "abcd")
    rem_vertex!(g, 'b')
    rem_vertex!(g, 'd')
    @test issetequal(vertices(g), ['a', 'c'])

    g = Graph{Char}()
    add_edges!(g, ["ab", "bc", "cd", "da"])
    rem_vertex!(g, 'c')
    @test issetequal(vertices(g), "abd")
    @test issetequal(
        Set.(edges(g)),
        [Set("ab"), Set("ad")]
    )

    g = Graph{Char}()
    add_edges!(g, ["ab", "bc", "cd", "da"])
    rem_edge!(g, 'b', 'c')
    rem_edge!(g, "da")
    @test issetequal(vertices(g), "abcd")
    @test issetequal(
        Set.(edges(g)),
        [Set("ab"), Set("cd")]
    )

    g = Graph{Char}()
    add_vertices!(g, "abcd")
    rem_vertices!(g, "bc")
    @test issetequal(vertices(g), ['a', 'd'])

    g = Graph{Char}()
    add_edges!(g, ["ab", "bc", "cd", "da"])
    rem_edges!(g, ["bc", "da"])
    @test issetequal(vertices(g), "abcd")
    @test issetequal(
        Set.(edges(g)),
        [Set("ab"), Set("cd")]
    )

    g = Graph{Char}()
    add_edge!(g, "ab")
    @test g.weights["ab"] == g.weights["ba"] == 1
    add_weighted_edge!(g, 'b', 'c', 2.5)
    add_weighted_edge!(g, "cd", 42)
    @test g.weights['b', 'c'] == g.weights["cb"] == 2.5
    @test g.weights["cd"] == g.weights["dc"] == 42

    g = Graph{Char}()
    add_weighted_edges!(g, [
        ('a', 'b', 100),
        ('b', 'c', 4.2),
        ('c', 'd', 0x08)
    ])
    @test g.weights['a', 'b'] == g.weights['b', 'a'] == 100
    @test g.weights["bc"] == g.weights["cb"] == 4.2
    @test g.weights["cd"] == g.weights["dc"] == 8

end
