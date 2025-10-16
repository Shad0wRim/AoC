include("days.jl")
using .aoc_days: aoc_day

function main()
    currday = 1
    datapath = "res/day$(lpad(currday,2,"0")).txt"
    if !isfile(datapath) || stat(datapath).size == 0
        println("fetching puzzle data")
        data = get_aoc_data(currday)
        if typeof(data) <: Exception
            println("Could not fetch data")
            return
        else
            write(datapath, data)
        end
    end

    data = read(datapath, String)
    answers = currday <= length(aoc_day) ?
              aoc_day[currday](data) :
              println("day is unimplemented")

    if isnothing(answers)
        println("day is unimplemented")
    elseif typeof(answers) <: Tuple || typeof(answers) <: Vector
        part1, part2 = answers
        println("Day $currday:")
        println("Part 1: $part1")
        println("Part 2: $part2")
    else
        println("Day $currday:")
        println("Part 1: $answers")
    end
end

using HTTP
function get_aoc_data(day::Int)
    cookie = ENV["AOC_TOKEN"]
    header = [
        "Content-Type" => "text/plain",
        "cookie" => "session=$cookie",
    ]
    url = "https://adventofcode.com/2025/day/$day/input"
    response = try
        response = HTTP.get(url, header)
        String(response.body)
    catch e
        @show e
    end
    return response
end

main()
