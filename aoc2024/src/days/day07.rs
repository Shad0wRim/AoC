#[allow(dead_code)]
const PRACTICE_DATA: &str = "190: 10 19
3267: 81 40 27
83: 17 5
156: 15 6
7290: 6 8 6 15
161011: 16 10 13
192: 17 8 14
21037: 9 7 18 13
292: 11 6 16 20";

pub fn day7(data: String) -> (Box<dyn std::fmt::Display>, Box<dyn std::fmt::Display>) {
    let mut equations = std::collections::HashMap::new();
    for line in data.lines() {
        let Some((left, right)) = line.split_once(": ") else {
            panic!();
        };
        let total: u64 = left.parse().unwrap();
        let vals: Vec<u64> = right.split(' ').map(|num| num.parse().unwrap()).collect();
        equations.insert(total, vals);
    }

    let mut part1 = 0;
    let mut part2 = 0;
    for (k, v) in &equations {
        if try_ops(*k, v) {
            part1 += *k;
        }
        if try_ops_with_concat(*k, v) {
            part2 += *k;
        }
    }

    (Box::new(part1), Box::new(part2))
}

fn try_ops(target: u64, values: &[u64]) -> bool {
    fn try_ops_rec(target: u64, values: &[u64], ind: usize, acc: u64) -> bool {
        if acc > target {
            return false;
        } else if ind >= values.len() {
            return acc == target;
        }
        let sum = try_ops_rec(target, values, ind + 1, acc + values[ind]);
        let prod = try_ops_rec(target, values, ind + 1, acc * values[ind]);

        sum || prod
    }
    try_ops_rec(target, values, 1, values[0])
}

fn try_ops_with_concat(target: u64, values: &[u64]) -> bool {
    fn try_ops_rec(target: u64, values: &[u64], ind: usize, acc: u64) -> bool {
        if acc > target {
            return false;
        } else if ind >= values.len() {
            return acc == target;
        }
        let sum = try_ops_rec(target, values, ind + 1, acc + values[ind]);
        let prod = try_ops_rec(target, values, ind + 1, acc * values[ind]);
        let concat = try_ops_rec(
            target,
            values,
            ind + 1,
            format!("{}{}", acc, values[ind]).parse().unwrap(),
        );

        sum || prod || concat
    }
    try_ops_rec(target, values, 1, values[0])
}
