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
    sorted_ranges = sort(id_ranges, by=first) # sort so that lower bounds are increasing
    corrected_ranges = [first(sorted_ranges)]
    for range in sorted_ranges[begin+1:end]
        end_range = corrected_ranges[end]

        if first(range) > last(end_range) # non overlapping, just insert
            push!(corrected_ranges, range)
        elseif last(range) > last(end_range)
            corrected_ranges[end] = first(end_range):last(range) # update if not fully contained
        end
    end

    fresh_count2 = sum(length(r) for r in corrected_ranges)

    fresh_count1, fresh_count2
end
