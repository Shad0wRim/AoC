function day02(data::String)
    part1 = part2 = 0
    # parsing
    for idrange in split(data, [',', '\n'], keepempty=false)
        firstid, lastid = parse.(Int, split(idrange, '-'))
        for id in firstid:lastid
            idstr = string(id)

            # part1
            firsthalf = idstr[begin:div(end, 2)]
            secondhalf = idstr[begin+div(end, 2):end]
            if firsthalf == secondhalf
                part1 += id
            end

            # part2
            if !isnothing(match(r"^(.+)\1+$", idstr)) # cursed regex
                part2 += id
            end
        end
    end

    part1, part2
end
