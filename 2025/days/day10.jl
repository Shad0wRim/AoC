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
    function toggle!(lights, bitvec, wirings)
        for i in eachindex(bitvec)
            bitvec[i] || continue
            lights .⊻= wirings[i] # xor each value to toggle it
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
            toggle!(lights, bitvec, wirings)
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
        pivotcols = [
            findfirst(isone, row)
            for row in eachrow(augmented)
            if !isnothing(findfirst(isone, row))
        ]
        freecols = setdiff(axes(arr, 2), pivotcols)
        num_freevars = length(freecols)
        nullspace = Matrix{Rational{Int}}[]
        particular_solution = Rational{Int}[]
        for var in axes(arr, 2)
            rowidx = findfirst(isequal(var), pivotcols)
            local null_entry, part_entry
            if isnothing(rowidx)
                freeidx = findfirst(isequal(var), freecols)
                null_entry = zeros(Rational{Int}, length(freecols))
                null_entry[freeidx] = 1
                part_entry = 0
            else
                null_entry = -augmented[rowidx, freecols]
                part_entry = augmented[rowidx, end]
            end
            push!(nullspace, permutedims(null_entry))
            push!(particular_solution, part_entry)
        end
        nullspace = reduce(vcat, nullspace)

        part2 += Int(if num_freevars == 0
            sum(particular_solution) # there is only one solution
        elseif num_freevars == 1
            minsolution = typemax(Int)
            for s in 0:200
                sol = particular_solution + nullspace * [s]
                all(sol .>= 0) && all(isinteger, sol) || continue
                minsolution > sum(sol) && (minsolution = sum(sol))
            end
            if minsolution == typemax(Int)
                @show machine_data particular_solution nullspace
                error("didn't find a solution")
            end
            minsolution
        elseif num_freevars == 2
            minsolution = typemax(Int)
            for s in 0:200, t in 0:200
                sol = particular_solution + nullspace * [s, t]
                all(sol .>= 0) && all(isinteger, sol) || continue
                minsolution > sum(sol) && (minsolution = sum(sol))
            end
            if minsolution == typemax(Int)
                @show machine_data particular_solution nullspace
                error("didn't find a solution")
            end
            minsolution
        elseif num_freevars == 3
            minsolution = typemax(Int)
            for s in 0:200, t in 0:200, u in 0:200
                sol = particular_solution + nullspace * [s, t, u]
                all(sol .>= 0) && all(isinteger, sol) || continue
                minsolution > sum(sol) && (minsolution = sum(sol))
            end
            if minsolution == typemax(Int)
                @show machine_data particular_solution nullspace
                error("didn't find a solution")
            end
            minsolution
        else
            error("nullity of $num_freevars not handled yet")
        end)
    end

    part1, part2
end
