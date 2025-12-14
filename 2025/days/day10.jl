function day10(data::String)
    part1 = part2 = 0

    # utility functions
    function rref!(arr::Matrix{Rational{Int}})
        nrows, ncols = size(arr)
        pivotrow = 1
        pivotcol = 1
        while pivotrow <= nrows && pivotcol <= ncols
            if arr[pivotrow, pivotcol] == 0
                swaprow_idx = findfirst(!iszero, arr[pivotrow+1:end, pivotcol])
                if isnothing(swaprow_idx)
                    # skip if cant find a pivot
                    pivotcol += 1
                    continue
                end
                swaprow_idx += pivotrow
                arr[pivotrow, :], arr[swaprow_idx, :] = arr[swaprow_idx, :], arr[pivotrow, :]
            end
            # normalize pivot row
            arr[pivotrow, :] ./= arr[pivotrow, pivotcol]
            # eliminate the rest of the columns
            for row in axes(arr, 1)
                row != pivotrow || continue
                arr[row, :] .-= arr[pivotrow, :] * arr[row, pivotcol]
            end
            pivotrow += 1
            pivotcol += 1
        end
    end

    for line in split(data, '\n', keepempty=false)
        # parsing
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

        # part1
        # key detail: doesn't matter how many times its been pressed, just once
        # or none is fine
        minpushes = typemax(Int)
        for i in 0:2^length(wiring_schematics)-1
            bitvec = digits(Bool, i, base=2, pad=length(wiring_schematics))
            lights = fill(false, size(indicator_lights_target))
            for i in eachindex(bitvec) # toggle the buttons
                bitvec[i] || continue
                lights .⊻= wirings[i] # xor each value to toggle it
            end
            if lights == indicator_lights_target
                numpushes = count(bitvec)
                if numpushes < minpushes
                    minpushes = numpushes
                end
            end
        end
        part1 += minpushes

        # part2
        arr = Rational.(stack(wirings))
        augmented = hcat(arr, joltage_requirements)
        rref!(augmented)

        pivotcols = [ # get the column of the pivot entry for each row
            findfirst(isone, row)
            for row in eachrow(augmented)
            if !isnothing(findfirst(isone, row))
        ]
        freevars = setdiff(axes(arr, 2), pivotcols)
        num_freevars = length(freevars)

        nullspace = reduce(vcat,
            begin
                rowidx = findfirst(==(var), pivotcols)
                local null_entry, part_entry
                if isnothing(rowidx)
                    freeidx = findfirst(isequal(var), freevars)
                    null_entry = zeros(Rational{Int}, length(freevars))
                    null_entry[freeidx] = 1
                else
                    null_entry = -augmented[rowidx, freevars]
                end
                permutedims(null_entry)
            end for var in axes(arr, 2)
        )
        particular_solution = [(
            rowidx = findfirst(==(var), pivotcols);
            isnothing(rowidx) ? 0 : augmented[rowidx, end]
        ) for var in axes(arr, 2)]

        maxpresses_needed = maximum(joltage_requirements)

        part2 += begin
            minsol::Vector{Int} = iszero(num_freevars) ? particular_solution : [typemax(Int)]
            for freevar_test in Iterators.product(repeat([0:maxpresses_needed], num_freevars)...)
                sol = particular_solution + nullspace * [freevar_test...]
                all(sol .>= 0) && all(isinteger, sol) || continue
                sum(sol) < sum(minsol) && (minsol = Int.(sol))
            end
            @show minsol
            sum(minsol)
        end
    end

    part1, part2
end
