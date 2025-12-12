function day10(data::String)
    part1 = part2 = 0

    for line in split(data, '\n', keepempty=false)
        machine_data = split(line)
        indicator_lights_target = map(c -> c == '#', collect(strip(machine_data[begin], ['[', ']'])))
        wiring_schematics = split.(strip.(c -> c in ['(', ')'], machine_data[begin+1:end-1]), ',') .|> w -> parse.(Int, w)
        foreach(w -> w .+= 1, wiring_schematics) # correct for 1 based indexing
        joltage_requirements = parse.(Int, split(strip(machine_data[end], ['{', '}']), ','))

        wirings = map(wiring_schematics) do wiring
            mask = zeros(Int, size(joltage_requirements))
            mask[wiring] .= 1
            mask
        end
        sort!(wirings; by=w -> count(isone, w), rev=true)

        toggle!(lights, bitvec) =
            for i in eachindex(bitvec)
                bitvec[i] || continue
                lights .⊻= wirings[i]
            end

        # part1
        # key detail: doesn't matter how many times its been pressed, just once
        # or none is fine
        minpushes = typemax(Int)
        for i in 0:2^length(wiring_schematics)-1
            bitvec = digits(Bool, i, base=2, pad=length(wiring_schematics))
            lights = fill(false, size(indicator_lights_target))
            toggle!(lights, bitvec)
            if lights == indicator_lights_target
                numpushes = count(bitvec)
                if numpushes < minpushes
                    minpushes = numpushes
                end
            end
        end
        part1 += minpushes
    end

    part1, part2
end
