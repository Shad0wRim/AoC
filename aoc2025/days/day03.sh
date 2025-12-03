# the number must be 12 numbers long, and the most significant digit is
# first. If we find the maximum digit possible for the most significant
# while still leaving space for the rest, we will maximize the value of 
# the number. Prefer the first digit to be earlier in the string to 
# leave more options for later digits to be maximized

find_max_digit() {
    local max idx i
    for ((i=0; i<${#1}; i++)); do
        ((max < ${1:i:1})) && max=${1:i:1} && idx=$i
    done
    echo $max $idx
}

find-joltage() {
    local i curr_idx line digits len last_idx dig
    while read line; do
        digits=
        len=${#line}
        last_idx=-1
        curr_idx=0
        for ((i=0; i < 12; i++)); do
            # adjust the substring to be past what we found is the max
            start=$((last_idx + 1))
            end=$((len - 12 + i))
            substr=${line:start:end-start+1}

            read dig curr_idx <<< $(find_max_digit "$substr")
            ((curr_idx += last_idx+1)) # correct index to be for whole string
            last_idx=$curr_idx
            digits+=$dig
        done
        echo "$digits"
    done
}

find-joltage \
    | paste -sd+ \
    | bc
