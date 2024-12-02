use std::fs;

pub fn day2() {
    println!("Day 2:");
    let data = fs::read_to_string("res/day02.txt").unwrap();

    print!("Part 1: ");
    let mut num_safe = 0;
    for line in data.lines() {
        let nums: Vec<i32> = line.split(' ').filter_map(|x| x.parse().ok()).collect();

        if validate_report(nums) {
            num_safe += 1;
        }
    }
    println!("{num_safe}");

    print!("Part 2: ");
    num_safe = 0;
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
            num_safe += 1;
        }
    }
    println!("{num_safe}");
}

fn validate_report(report: Vec<i32>) -> bool {
    let increasing = report[0] < report[1];
    if increasing {
        report
            .windows(2)
            .fold(true, |b, x| b && (x[1] - x[0] >= 1 && x[1] - x[0] <= 3))
    } else {
        report
            .windows(2)
            .fold(true, |b, x| b && (x[0] - x[1] >= 1 && x[0] - x[1] <= 3))
    }
}
