function day05(data::String)
    id_ranges, available_ids = split(data, "\n\n")
    id_ranges = [parse.(Int, split(line, '-')) for line in split(id_ranges)]
    id_ranges = map(r -> ((a, b) = r; a:b), id_ranges)
    available_ids = parse.(Int, split(available_ids))

    # part1
    fresh_count1 = 0
    for id in available_ids
        for range in id_ranges
            if id in range
                fresh_count1 += 1
                break
            end
        end
    end

    # part2
    all_combinations(ranges) = begin
        @assert issorted(ranges; by=first)
        combined = Dict{Tuple,UnitRange}()
        for i in eachindex(ranges), j in i+1:lastindex(ranges)
            irange = ranges[i]
            jrange = ranges[j]
            @assert first(irange) <= first(jrange) "$(first(irange)) - $(first(jrange))"
            if last(irange) >= first(jrange)
                if last(irange) >= last(jrange)
                    push!(combined, (i, j) => irange)
                else
                    push!(combined, (i, j) => first(irange):last(jrange))
                end
            end
        end
        combined
    end

    corrected_ranges = UnitRange{Int}[]
    temp_ranges = sort(id_ranges, by=first)
    while !isempty(temp_ranges)
        println("start of loop")

        combos = all_combinations(temp_ranges)
        solitary_range_indices = Set(eachindex(temp_ranges))
        for (l, r) in keys(combos)
            setdiff!(solitary_range_indices, l, r)
        end
        @show solitary_ranges = temp_ranges[collect(solitary_range_indices)]
        append!(corrected_ranges, solitary_ranges)
        sort!(corrected_ranges, by=first)
        @assert all_combinations(corrected_ranges) |> isempty

        temp_ranges = begin
            # combine simple combinations, 2->3, then ignore any other combos with 
            # those indices. Keep track of what indices have been combined, then 
            # add the missing ones back. 
            used_indices = Set()
            new_ranges = UnitRange{Int}[]
            for ((l, r), range) in pairs(combos)
                (l in used_indices || r in used_indices) && continue
                push!(used_indices, l, r)
                push!(new_ranges, range)
            end
            union!(used_indices, solitary_range_indices)
            unused_indices = setdiff!(Set(eachindex(temp_ranges)), used_indices)
            append!(new_ranges, temp_ranges[collect(unused_indices)])
            sort(new_ranges, by=first)
        end
        @show length(temp_ranges)
    end

    fresh_count2 = sum(length(r) for r in corrected_ranges)

    fresh_count1, fresh_count2
end
