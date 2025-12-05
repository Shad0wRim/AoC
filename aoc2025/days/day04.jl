function day04(data::String)
    # collects into the array of characters, separated by newlines
    data = reduce(vcat, (permutedims(collect(s)) for s in split(data)))

    adjacent(idx) = begin
        x, y = idx.I

        CartesianIndex.([
            (x - 1, y - 1),
            (x - 1, y),
            (x - 1, y + 1),
            (x, y - 1),
            (x, y + 1),
            (x + 1, y - 1),
            (x + 1, y),
            (x + 1, y + 1),
        ])
    end

    get_accessible(data) = begin
        accessible = fill(false, size(data))

        for center_idx in CartesianIndices(data)
            data[center_idx] == '@' || continue
            adjacent_roll_count = 0
            for idx in adjacent(center_idx)
                try
                    data[idx] == '@' && (adjacent_roll_count += 1)
                catch
                end
            end
            adjacent_roll_count < 4 && (accessible[center_idx] = true)
        end

        accessible
    end

    # part1
    part1 = count(get_accessible(data))

    # part2
    part2 = 0
    while (
        accessible = get_accessible(data);
        num_accessible = count(accessible);
        num_accessible != 0
    )
        part2 += num_accessible
        data[accessible] .= '.'
    end

    part1, part2
end
