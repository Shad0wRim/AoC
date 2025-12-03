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
        maxjolt2 = 0
        dig = ['0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0']
        dig[1], idx1 = findmax(line[begin:end-11])
        dig[2], idx2 = findmax(line[idx1+1:end-10])
        idx2 += idx1
        dig[3], idx3 = findmax(line[idx2+1:end-9])
        idx3 += idx2
        dig[4], idx4 = findmax(line[idx3+1:end-8])
        idx4 += idx3
        dig[5], idx5 = findmax(line[idx4+1:end-7])
        idx5 += idx4
        dig[6], idx6 = findmax(line[idx5+1:end-6])
        idx6 += idx5
        dig[7], idx7 = findmax(line[idx6+1:end-5])
        idx7 += idx6
        dig[8], idx8 = findmax(line[idx7+1:end-4])
        idx8 += idx7
        dig[9], idx9 = findmax(line[idx8+1:end-3])
        idx9 += idx8
        dig[10], idx10 = findmax(line[idx9+1:end-2])
        idx10 += idx9
        dig[11], idx11 = findmax(line[idx10+1:end-1])
        idx11 += idx10
        dig[12], idx12 = findmax(line[idx11+1:end])
        idx12 += idx11


        joltage2 += parse(Int, join(dig))
    end
    joltage1, joltage2
end
