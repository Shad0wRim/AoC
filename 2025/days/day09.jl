Rect = Tuple{UnitRange{Int},UnitRange{Int}}
function day09(data::String)
    points = collect(parse.(Int, split(line, ',')) for line in split(data, keepempty=false))

    # part1
    part1 = 0
    for i in eachindex(points), j in i+1:lastindex(points)
        area = prod(abs.(points[i] .- points[j]) .+ 1)
        area > part1 && (part1 = area)
    end

    # part2
    # get all boundaries of the rect for all pairs of rects
    # if all the boundaries are inside, then the whole thing is inside
    # find parts of the boundaries that dont overlap with edges
    # check if they are inside or outside the shape
    edges = Rect[]
    for ((px, py), (cx, cy)) in zip(points[begin:end-1], points[begin+1:end])
        push!(edges, (UnitRange(minmax(px, cx)...), UnitRange(minmax(py, cy)...)))
    end
    let
        px, py = last(points)
        cx, cy = first(points)
        push!(edges, (UnitRange(minmax(px, cx)...), UnitRange(minmax(py, cy)...)))
    end

    rects = Rect[]
    for i in eachindex(points), j in i+1:lastindex(points)
        ix, iy = points[i]
        jx, jy = points[j]
        xrange = UnitRange(minmax(ix, jx)...)
        yrange = UnitRange(minmax(iy, jy)...)
        push!(rects, (xrange, yrange))
    end

    maxx = maximum(first.(points))
    maxy = maximum(last.(points))

    # utility functions
    rectarea(rect) = prod(length.(rect))
    isvertical(r::Rect) = length(first(r)) == 1
    ishorizontal(r::Rect) = length(last(r)) == 1
    e_vert = filter(isvertical, edges)
    e_horz = filter(ishorizontal, edges)
    setdiff_range(r1::UnitRange{Int}, r2::UnitRange{Int})::Vector{UnitRange{Int}} = begin
        r1l, r1r = extrema(r1)
        r2l, r2r = extrema(r2)
        if r1l <= r2l && r1r <= r2r
            [r1l:r2l-1]
        elseif r1l >= r2l && r1r >= r2r
            [r2r+1:r1r]
        elseif r1l >= r2l && r1r <= r2r
            [1:0]
        elseif r1l <= r2l && r1r >= r2r
            [r1l:r2l-1, r2r+1:r1r]
        end
    end
    remove_overlapping(r::Rect)::Vector{Rect} = begin
        local single, multi, aligned_edges
        if isvertical(r)
            single = first
            multi = last
            aligned_edges = e_vert
        elseif ishorizontal(r)
            single = last
            multi = first
            aligned_edges = e_horz
        else
            error("only works with thin rects")
        end
        r_s = single(r)
        r_m = multi(r)
        overlapping_edges = multi.(filter(e -> single(e) == r_s, aligned_edges))
        filter!(overlapping_edges) do es_m
            last(es_m) >= first(r_m) && last(r_m) >= first(es_m)
        end
        nonoverlapping = collect(Iterators.flatten(
            setdiff_range(r_m, e) for e in overlapping_edges
        ))
        return [isvertical(r) ? (r_s, n_m) : (n_m, r_s) for n_m in nonoverlapping]
    end
    clip_endpoints(r::Rect)::Rect = begin
        if ishorizontal(r)
            lowerx, upperx = extrema(first(r))
            if any(e -> lowerx in first(e) && only(last(r)) in last(e), e_vert)
                lowerx = lowerx + 1
            end
            if any(e -> upperx in first(e) && only(last(r)) in last(e), e_vert)
                upperx = upperx - 1
            end
            all((lowerx, upperx) .!= extrema(first(r))) && error("this shouldn't happen")
            return (lowerx:upperx, last(r))
        elseif isvertical(r)
            lowery, uppery = extrema(last(r))
            if any(e -> lowery in last(e) && only(first(r)) in first(e), e_horz)
                lowery = lowery + 1
            end
            if any(e -> uppery in last(e) && only(first(r)) in first(e), e_horz)
                uppery = uppery - 1
            end
            all((lowery, uppery) .!= extrema(last(r))) && error("this shouldn't happen")
            return (first(r), lowery:uppery)
        else
            error("unreachable")
        end
    end

    # main logic
    validrects = Rect[]
    for rect in rects
        # any(length.(rect) .== 1) && continue
        # rect == (2:9, 3:7) || continue

        rxs, rys = extrema.(rect)
        rleftx, rrightx = rxs
        rtopy, rbottomy = rys
        rect_edges = Rect[
            (rleftx:rrightx, rtopy:rtopy)       # top
            (rleftx:rrightx, rbottomy:rbottomy) # bottom
            (rleftx:rleftx, rtopy:rbottomy)     # left
            (rrightx:rrightx, rtopy:rbottomy)   # right
        ]

        need_to_check = collect(Iterators.flatmap(remove_overlapping, rect_edges))
        filter!(r -> rectarea(r) != 0, need_to_check)
        if isempty(need_to_check)
            push!(validrects, rect)
            continue
        end
        need_to_check = map!(clip_endpoints, need_to_check)

        # check if they cross a perpendicular edge
        (() -> begin
            for curr_range in need_to_check
                curr_xs, curr_ys = curr_range
                isvertical(curr_range) &&
                    any(e -> only(last(e)) in curr_ys && only(curr_xs) in first(e), e_horz) &&
                    return false
                ishorizontal(curr_range) &&
                    any(e -> only(first(e)) in curr_xs && only(curr_ys) in last(e), e_vert) &&
                    return false
            end
            return true
        end)() || continue

        # check if any of the interior points is inside, by counting how many
        # times edges were walked past
        (() -> begin
            for curr_range in need_to_check
                x, y = last.(curr_range)
                inline_x = x in first.(points)
                inline_y = y in last.(points)

                if inline_x && inline_y
                    # go away from other points
                    y_inline_x_points = last.(points[(first.(points).==x)])
                    x_inline_y_points = first.(points[(last.(points).==y)])
                    path = if all(y_inline_x_points .> y)
                        (x:x, 1:y)
                    elseif all(y_inline_x_points .< y)
                        (x:x, y:maxy)
                    elseif all(x_inline_y_points .> x)
                        (1:x, y:y)
                    elseif all(x_inline_y_points .< x)
                        (x:maxx, y:y)
                    else
                        error("annoying: $rect, $((x,y))")
                    end
                    wall_count = if isvertical(path)
                        count(e -> only(last(e)) in last(path) && only(first(path)) in first(e), e_horz)
                    else
                        count(e -> only(first(e)) in first(path) && only(last(path)) in last(e), e_vert)
                    end
                    wall_count % 2 == 0 && return false
                elseif inline_x
                    # go left or right
                    wall_count = count(e -> only(first(e)) in 1:x && y in last(e), e_vert)
                    wall_count % 2 == 0 && return false
                elseif inline_y
                    # go up or down
                    wall_count = count(e -> only(last(e)) in 1:y && x in first(e), e_horz)
                    wall_count % 2 == 0 && return false
                else
                    error("unreachable")
                end
            end
            return true
        end)() || continue

        push!(validrects, rect)
    end

    part2 = maximum(rectarea, validrects; init=0)

    part1, part2
end
