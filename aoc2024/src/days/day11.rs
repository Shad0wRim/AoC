pub fn day11(data: String) -> (Box<dyn std::fmt::Display>, Box<dyn std::fmt::Display>) {
    let data: Box<[u128]> = data
        .split_whitespace()
        .map(|n| n.parse().unwrap())
        .collect();
    let part1 = count_stones(&data, 25);
    let part2 = count_stones(&data, 75);
    (Box::new(part1), Box::new(part2))
}

fn count_stones(stones: &[u128], splits: u32) -> u128 {
    use std::collections::HashMap;
    fn rec_impl(stone: u128, splits: u32, memo: &mut HashMap<(u128, u32), u128>) -> u128 {
        if let Some(val) = memo.get(&(stone, splits)) {
            return *val;
        } else if splits == 0 {
            return 1;
        }

        let new_stones = if stone == 0 {
            (1, None)
        } else if (stone.ilog10() + 1) % 2 == 0 {
            let digits = stone.ilog10() + 1;
            let high = stone / 10u128.pow(digits / 2);
            let low = stone % 10u128.pow(digits / 2);
            (high, Some(low))
        } else {
            (stone * 2024, None)
        };

        let result = match new_stones {
            (n, None) => rec_impl(n, splits - 1, memo),
            (high, Some(low)) => rec_impl(high, splits - 1, memo) + rec_impl(low, splits - 1, memo),
        };

        memo.insert((stone, splits), result);
        result
    }

    let mut memo = HashMap::new();
    stones
        .iter()
        .map(|stone| rec_impl(*stone, splits, &mut memo))
        .sum()
}
