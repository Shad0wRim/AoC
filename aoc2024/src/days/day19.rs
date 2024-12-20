pub fn day19(data: String) -> (Box<dyn std::fmt::Display>, Box<dyn std::fmt::Display>) {
    let (patterns, towels) = parse_data(&data);

    let part1 = towels
        .iter()
        .filter(|towel| is_possible(towel, &patterns))
        .count();

    let part2 = towels
        .iter()
        .map(|towel| num_ways(towel, &patterns))
        .sum::<usize>();

    (Box::new(part1), Box::new(part2))
}

use std::collections::{HashMap, HashSet};
fn is_possible(towel: &[Stripe], patterns: &[Vec<Stripe>]) -> bool {
    let mut states = HashSet::from([0]);

    while !states.contains(&towel.len()) && !states.is_empty() {
        states = states
            .iter()
            .flat_map(|state| patterns.iter().map(move |pat| (pat, *state)))
            .filter(|(pat, state)| can_take_pattern(towel, *state, pat))
            .map(|(pat, state)| pat.len() + state)
            .collect()
    }
    !states.is_empty()
}
fn num_ways(towel: &[Stripe], patterns: &[Vec<Stripe>]) -> usize {
    // state: (idx, ways)
    let mut states = HashMap::from([(0, 1)]);

    let mut num_ways = 0;
    while !states.is_empty() {
        let paths: Vec<_> = states
            .iter()
            .flat_map(|state| patterns.iter().map(move |pat| (pat, state)))
            .filter(|(pat, state)| can_take_pattern(towel, *state.0, pat))
            .map(|(pat, state)| (*state.0 + pat.len(), *state.1))
            .collect();

        let mut new_states = HashMap::new();
        for state in paths {
            match state.0.cmp(&towel.len()) {
                std::cmp::Ordering::Less => {
                    new_states
                        .entry(state.0)
                        .and_modify(|count| *count += state.1)
                        .or_insert(state.1);
                }
                std::cmp::Ordering::Equal => num_ways += state.1,
                std::cmp::Ordering::Greater => (),
            };
        }
        states = new_states;
    }
    num_ways
}
fn can_take_pattern(towel: &[Stripe], state: usize, pattern: &[Stripe]) -> bool {
    towel.iter().skip(state).zip(pattern).all(|(t, p)| t == p)
}

fn parse_data(data: &str) -> (Vec<Vec<Stripe>>, Vec<Vec<Stripe>>) {
    let (patterns, towels) = data.split_once("\n\n").unwrap();

    let char_to_stripe = |c| match c {
        'w' => Stripe::White,
        'u' => Stripe::Blue,
        'b' => Stripe::Black,
        'r' => Stripe::Red,
        'g' => Stripe::Green,
        _ => panic!("Invalid stripe color"),
    };
    let patterns = patterns
        .split(", ")
        .map(|pattern| pattern.chars().map(char_to_stripe).collect())
        .collect();
    let towels = towels
        .lines()
        .map(|towel| towel.chars().map(char_to_stripe).collect())
        .collect();

    (patterns, towels)
}

#[derive(Debug, Clone, Copy, Hash, PartialEq, Eq)]
enum Stripe {
    White,
    Blue,
    Black,
    Red,
    Green,
}

const _DATA: &str = "r, wr, b, g, bwu, rb, gb, br

brwrr
bggr
gbbr
rrbgbr
ubwu
bwurrg
brgr
bbrgwb";
