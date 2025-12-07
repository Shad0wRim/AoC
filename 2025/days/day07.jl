function day07(data::String)
    data = reduce(hcat, (collect(line) for line in split(data)))

    numsplits = 0
    numpaths = map(x -> Int(x == 'S'), data[:, 1])
    for line in eachcol(data), i in eachindex(line)
        if line[i] == '^' && numpaths[i] > 0
            # part1
            numsplits += 1

            # part2
            try numpaths[i-1] += numpaths[i] catch end
            try numpaths[i+1] += numpaths[i] catch end
            numpaths[i] = 0
        end
    end

    numsplits, sum(numpaths)
end
