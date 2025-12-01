function day01(data::String)
    dialpos = 50
    password1 = 0
    password2 = 0

    for line in split(data, '\n', keepempty=false)
        num = parse(Int, line[begin+1:end])
        if line[1] == 'R'
            dialpos += num
        elseif line[1] == 'L'
            # handle if dial is already on zero so it doesn't get double counted
            dialpos = dialpos == 0 ? 100 - num : dialpos - num
        end

        # count number of times went past 0
        if dialpos <= 0
            password2 += abs(div(dialpos, 100)) + 1
        elseif dialpos >= 100
            password2 += div(dialpos, 100)
        end

        dialpos = mod(dialpos, 100)

        # count number of times landed on zero
        if dialpos == 0
            password1 += 1
        end
    end

    password1, password2
end
