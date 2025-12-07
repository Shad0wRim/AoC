function day07(data::String)
    data = reduce(hcat, (collect(line) for line in split(data)))

    # part1
    numsplits = 0
    for rowidx in axes(data, 2)
        rowidx == firstindex(data, 2) && continue
        prevrow = view(data, :, rowidx - 1)
        currrow = view(data, :, rowidx)

        for i in eachindex(currrow)
            if currrow[i] == '^' && prevrow[i] == '|'
                numsplits += 1
                try currrow[i-1] = '|' catch end
                try currrow[i+1] = '|' catch end
            elseif currrow[i] == '.' && prevrow[i] in ['|', 'S']
                currrow[i] = '|'
            end
        end
    end
    replace!(x -> x == '|' ? '.' : x, data)


    numpaths = map(x -> Int(x == 'S'),data[:, 1])
    for rowidx in axes(data, 2)
        currrow = view(data, :, rowidx)

        for i in eachindex(currrow)
            if currrow[i] == '^' && numpaths[i] > 0
                try numpaths[i-1] += numpaths[i] catch end
                try numpaths[i+1] += numpaths[i] catch end
                numpaths[i] = 0
            end
        end
        @show numpaths
    end

    show(stderr, "text/plain", (data))
    println()

    numsplits, sum(numpaths)
end
