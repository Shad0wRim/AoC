LogicalMatrix = Union{BitMatrix,Matrix{Bool}}

function day12(data::String)
    function pgrid(arr::LogicalMatrix)
        for col in eachcol(arr)
            for b in col
                print(b ? '#' : '.')
            end
            println()
        end
    end
    function allorientations(shape::T)::Vector{T} where {T<:AbstractMatrix}
        rotations = [rotr90(shape, k) for k in 0:3]
        rev = reverse(shape; dims=1)
        append!(rotations, rotr90(rev, k) for k in 0:3)
        unique!(rotations)
    end
    function insert_grid!(grid::LogicalMatrix, shape::LogicalMatrix, loc::Tuple{Int,Int})::Nothing
        present_locs = Tuple.(findall(shape))
        shifted_locs = [CartesianIndex(hereloc .+ (loc .- 1)) for hereloc in present_locs]

        if !any(grid[shifted_locs])
            grid[shifted_locs] .= true
        else
            error("position is filled already")
        end

        return
    end

    shapes..., regions = split(data, "\n\n")
    shapes = [reduce(vcat,
        permutedims(collect(line) .== '#')
        for line in split(shape) if length(line) != 2
    ) for shape in shapes]
    regions = map(split(regions, '\n'; keepempty=false)) do region
        w, l, quantities... = parse.(Int, split(region, [':', 'x', ' ']; keepempty=false))
        (w, l), quantities
    end

    total_left = Tuple{Tuple{Int,Int},Vector{Int}}[]
    part1 = 0
    for (sz, qs) in regions
        # if the grid cant fit all of the filled tiles, just skip it
        sum(count(shapes[i]) * q for (i, q) in enumerate(qs)) > prod(sz) && continue
        # if it is sparse enough and can fit everything without needing to
        # overlap, then its good to go
        sum(9 * q for q in qs)  <= prod(sz .- sz .% 3) && (part1 += 1; continue)

        # otherwise its a hard problem, deal with it later
        push!(total_left, (sz, qs))
    end
    length(total_left) == 0 && return part1

    error("$(length(total_left)) regions left unsolved")
end

