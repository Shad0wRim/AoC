#!/usr/bin/env julia

include("days.jl")
include("utils.jl")
using .aoc_days: aoc_day
using .utils

function main()
    day = parse(Int, first(ARGS))

    # download file if it is not in the res directory
    if !isfile(datapath(day))
        println("fetching puzzle data")
        get_aoc_data(day)
    end

    # run the corresponding day
    runday(day)
end

main()
