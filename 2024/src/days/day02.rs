pub fn day2(data: String) -> (Box<dyn std::fmt::Display>, Box<dyn std::fmt::Display>) {
    let mut part1 = 0;
    for line in data.lines() {
        let nums: Vec<i32> = line.split(' ').filter_map(|x| x.parse().ok()).collect();

        if validate_report(nums) {
            part1 += 1;
        }
    }

    let mut part2 = 0;
    for line in data.lines() {
        let nums: Vec<i32> = line.split(' ').filter_map(|x| x.parse().ok()).collect();

        let mut is_safe = false;
        for ind in 0..nums.len() {
            let mut small_nums = nums.clone();
            small_nums.remove(ind);
            if validate_report(small_nums) {
                is_safe = true;
                break;
            }
        }
        if is_safe {
            part2 += 1;
        }
    }

    (Box::new(part1), Box::new(part2))
}

fn validate_report(report: Vec<i32>) -> bool {
    let increasing = report[0] < report[1];
    if increasing {
        report
            .windows(2)
            .all(|x| x[1] - x[0] >= 1 && x[1] - x[0] <= 3)
    } else {
        report
            .windows(2)
            .all(|x| x[0] - x[1] >= 1 && x[0] - x[1] <= 3)
    }
}
