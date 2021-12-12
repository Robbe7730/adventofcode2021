adjacency = Dict()

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

function visit(node, visited)
    if node in visited
        return 0
    end
    if node == "end"
        return 1
    end

    if node[1] >= 'a' && node[1] <= 'z'
        push!(visited, node)
    end

    ret = 0
    for child in adjacency[node]
        ret += visit(child, visited)
    end

    if node[1] >= 'a' && node[1] <= 'z'
        pop!(visited)
    end

    return ret
end

println(visit("start", []))
