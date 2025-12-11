function day11(data::String)
    data = map(split(data, '\n', keepempty=false)) do line
        name, output = split(line, ':')
        output = split(output)
        name, output
    end
    push!(data, ("out", Int[]))
    name_to_num = Dict(name => i for (i, (name, _)) in enumerate(data))
    graph::Vector{Vector{Int}} = [map(o -> name_to_num[o], last(e)) for e in data]
    out = name_to_num["out"]

    count_paths(start::Int, finish::Int) = begin
        function impl(node::Int, cache::Dict{Int,Int})::Int
            try return cache[node] catch end
            node == finish && return 1
            return cache[node] = sum(impl(n, cache) for n in graph[node]; init=0)
        end
        impl(start, Dict{Int,Int}())
    end

    # part1
    you = name_to_num["you"]
    part1 = count_paths(you, out)

    # part2
    svr = name_to_num["svr"]
    fft = name_to_num["fft"]
    dac = name_to_num["dac"]

    svr_fft = count_paths(svr, fft)
    fft_dac = count_paths(fft, dac)
    dac_out = count_paths(dac, out)

    svr_dac = count_paths(svr, dac)
    dac_fft = count_paths(dac, fft)
    fft_out = count_paths(fft, out)

    part2 = svr_fft * fft_dac * dac_out + svr_dac * dac_fft * fft_out

    part1, part2
end
