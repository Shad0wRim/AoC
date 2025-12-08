function day08(data::String)
    data = map(s -> parse.(Int, s), collect(split.(split(data, keepempty=false), ',')))
    endpoint = 1000

    dists2 = Pair{Tuple{Int,Int},Int}[] # squared distances
    for i in eachindex(data), j in i+1:lastindex(data)
        dist2 = sum((data[i] .- data[j]) .^ 2)
        push!(dists2, (i, j) => dist2)
    end
    sort!(dists2, by=last)

    # part1
    circuits = Set{Int}[]
    for distentry in dists2[1:endpoint]
        i, j = first(distentry)
        locs = findall(c -> i in c || j in c, circuits)
        numlocs = length(locs)
        if numlocs == 0
            push!(circuits, Set([i, j]))
        elseif numlocs == 1
            push!(circuits[first(locs)], i, j)
        elseif numlocs == 2
            newset = union(circuits[locs]...)
            deleteat!(circuits, locs)
            push!(circuits, newset)
        else
            error("Shouldn't have more than 2 locations for a junction")
        end
    end
    part1 = prod(sort!(map(length, circuits); rev=true) |> v -> first(v, 3))

    # part2
    local part2
    for distentry in dists2[endpoint+1:end]
        i, j = first(distentry)
        locs = findall(c -> i in c || j in c, circuits)
        numlocs = length(locs)
        if numlocs == 0
            push!(circuits, Set([i, j]))
        elseif numlocs == 1
            push!(circuits[first(locs)], i, j)
        elseif numlocs == 2
            newset = union(circuits[locs]...)
            deleteat!(circuits, locs)
            push!(circuits, newset)
        else
            error("Shouldn't have more than 2 locations for a junction")
        end

        if isempty(setdiff(eachindex(data) |> Set, circuits...))
            x1 = first(data[i])
            x2 = first(data[j])
            part2 = x1 * x2
            break
        end
    end

    part1, part2
end
