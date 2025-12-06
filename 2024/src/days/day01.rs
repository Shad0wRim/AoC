pub fn day1(data: String) -> (Box<dyn std::fmt::Display>, Box<dyn std::fmt::Display>) {
    let mut left_data = vec![];
    let mut right_data = vec![];
    for str in data.lines() {
        let [l, r] = str
            .split("   ")
            .map(|x| x.parse::<i32>().unwrap())
            .collect::<Vec<_>>()[..]
        else {
            panic!();
        };
        left_data.push(l);
        right_data.push(r);
    }
    let mut sorted_left = left_data.clone();
    sorted_left.sort_unstable();
    let mut sorted_right = right_data.clone();
    sorted_right.sort_unstable();

    let data = sorted_left.iter().zip(sorted_right.iter());
    let part1: i32 = data.map(|(l, r)| (l - r).abs()).sum();

    let mut counts = std::collections::HashMap::new();
    for num in right_data {
        if let Some(x) = counts.get_mut(&num) {
            *x += 1;
        } else {
            counts.insert(num, 1);
        }
    }
    let part2: i32 = left_data
        .iter()
        .map(|l| l * counts.get(l).unwrap_or(&0))
        .sum();

    (Box::new(part1), Box::new(part2))
}
