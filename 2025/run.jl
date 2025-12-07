#!/usr/bin/env julia

include("days.jl")
include("utils.jl")
using .aoc_days: aoc_day
using .utils

runday(parse(Int, ARGS[1]), length(ARGS) > 1 && ARGS[2] == "practice")
