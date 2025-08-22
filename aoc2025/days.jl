module aoc_days

export aoc_day

files = readdir("days", join=true) |> sort!
const aoc_day = map(include, files)

end
