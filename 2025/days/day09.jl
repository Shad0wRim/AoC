function day09(data::String)
    data = collect(parse.(Int, split(line, ',')) for line in split(data, keepempty=false))

    # part1
    part1 = 0
    for i in eachindex(data), j in i+1:lastindex(data)
        area = prod(abs.(data[i] .- data[j]) .+ 1)
        area > part1 && (part1 = area)
    end
    part1
end
