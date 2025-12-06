function day06(data::String)
    op(oper) =
        if oper == "*" || oper == '*'
            *
        elseif oper == "+" || oper == '+'
            +
        end

    # part1
    data1 = reduce(vcat, (permutedims(collect(split(line))) for line in split(data, '\n', keepempty=false)))
    part1 = 0
    for col in eachcol(data1)
        nums = parse.(Int, col[begin:end-1])
        part1 += reduce(op(col[end]), nums)
    end

    # part2
    data2 = reduce(vcat, (permutedims(collect(line)) for line in split(data, '\n', keepempty=false)))

    part2 = 0
    curroper = nothing
    nums = Int[]
    for col in eachcol(data2)
        if all(isspace, col)
            part2 += reduce(curroper, nums)
            empty!(nums)
            continue
        end
        isnothing(op(col[end])) || (curroper = op(col[end]))

        push!(nums, parse(Int, String(col[begin:end-1])))
    end
    isempty(nums) || (part2 += reduce(curroper, nums))

    part1, part2
end
