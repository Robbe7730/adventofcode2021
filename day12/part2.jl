adjacency = Dict()
res = []

for line in readlines()
    from, to = split(line,'-')
    if ! haskey(adjacency, from)
        adjacency[from] = []
    end
    if ! haskey(adjacency, to)
        adjacency[to] = []
    end
    push!(adjacency[from], to)
    push!(adjacency[to], from)
end

function issmallcave(node)
    return node[1] >= 'a' && node[1] <= 'z'
end

function visit(node, visited, visit_twice)
    if issmallcave(node) && node in visited && node != visit_twice
        return
    end
    if node == "end"
        push!(visited, "end")
        push!(res, copy(visited))
        pop!(visited)
        return
    end

    if node == visit_twice && node in visited
        visit_twice = nothing
    end

    push!(visited, node)

    for child in adjacency[node]
        visit(child, visited, visit_twice)
    end

    pop!(visited)
end

function solve()
    for (key, value) in adjacency
        if issmallcave(key) && !(key in ["start", "end"])
            visit("start", [], key)
        end
    end
end

solve()
println(length(Set(res)))
