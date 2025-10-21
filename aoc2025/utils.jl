module utils

export get_aoc_data, datapath, runday

using Downloads: download
function get_aoc_data(day::Int)
    cookie = read(expanduser("~/.aoc-cookie"), String)
    download("https://adventofcode.com/2025/day/$day/input", datapath(day);
        headers=[
            "Content-Type" => "text/plain",
            "cookie" => "session=$cookie",
        ]
    )
end

datapath(day::Int) = "res/day$(lpad(day,2,'0')).txt"

using ..aoc_days: aoc_day
function runday(day::Int, use_practice_data::Bool=false)
    data = read(
        use_practice_data ?
        "res/example.txt" :
        datapath(day),
        String
    )

    println("-"^15 * "<< Day $day >>" * "-"^15)

    answers = day <= length(aoc_day) ? aoc_day[day](data) : nothing

    if isnothing(answers)
        println("day is unimplemented")
    elseif typeof(answers) <: Tuple || typeof(answers) <: Vector
        part1, part2 = answers
        println("Part 1: $part1")
        println("Part 2: $part2")
    else
        println("Part 1: $answers")
    end
end

end
