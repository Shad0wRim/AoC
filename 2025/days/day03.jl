function day03(data::String)
    joltage1 = 0
    joltage2 = 0
    for line in split(data, '\n', keepempty=false)
        # part1
        maxjolt1 = 0
        for i in eachindex(line), j in i+1:lastindex(line)
            jolt = parse(Int, "$(line[i])$(line[j])")
            maxjolt1 = jolt > maxjolt1 ? jolt : maxjolt1
        end
        joltage1 += maxjolt1

        # part2
        dig = fill('0', 12)
        idx = zeros(Int, 12)
        dig[1], idx[1] = findmax(line[begin:end-11])
        for i in 2:12
            dig[i], idx[i] = findmax(line[idx[i-1]+1:end-(12-i)])
            idx[i] += idx[i-1]
        end
        joltage2 += parse(Int, join(dig))
    end
    joltage1, joltage2
end
