pub fn day14(data: String) -> (Box<dyn std::fmt::Display>, Box<dyn std::fmt::Display>) {
    let size = SIZE;
    let mut bots = parse_data(&data);

    simulate_bots(&mut bots, size, 100);
    let part1 = count_quadrants(&bots, size);

    simulate_bots(&mut bots, size, -100);
    let mut counter = 0;
    let part2 = loop {
        simulate_bots(&mut bots, size, 1);
        counter += 1;

        if found_tree(&bots) {
            print(&bots, size);
            break counter;
        }
    };

    (Box::new(part1), Box::new(part2))
}

fn simulate_bots(bots: &mut [BotData], size: (i32, i32), time: i32) {
    for bot in bots {
        bot.p.0 += bot.v.0 * time;
        bot.p.0 = bot.p.0.rem_euclid(size.0);

        bot.p.1 += bot.v.1 * time;
        bot.p.1 = bot.p.1.rem_euclid(size.1);
    }
}

fn count_quadrants(bots: &[BotData], size: (i32, i32)) -> i32 {
    let mid = (size.0 / 2, size.1 / 2);
    bots.iter()
        .fold([0, 0, 0, 0], |mut acc, bot| {
            if (0..mid.0).contains(&bot.p.0) && (0..mid.1).contains(&bot.p.1) {
                acc[0] += 1;
            } else if (0..mid.0).contains(&bot.p.0) && ((mid.1 + 1)..size.1).contains(&bot.p.1) {
                acc[1] += 1;
            } else if ((mid.0 + 1)..size.0).contains(&bot.p.0) && (0..mid.1).contains(&bot.p.1) {
                acc[2] += 1;
            } else if ((mid.0 + 1)..size.0).contains(&bot.p.0)
                && ((mid.1 + 1)..size.1).contains(&bot.p.1)
            {
                acc[3] += 1;
            }
            acc
        })
        .into_iter()
        .product()
}

fn found_tree(bots: &[BotData]) -> bool {
    let counts = counts_by(bots, |bot| bot.p);
    counts.values().all(|x| *x == 1) // assumption that no bots are overlapping in the easter egg
}

fn counts_by<T, K, F>(collection: T, f: F) -> HashMap<K, usize>
where
    T: IntoIterator,
    K: Eq + Hash,
    F: FnMut(T::Item) -> K,
{
    let mut hashmap = HashMap::new();
    for key in collection.into_iter().map(f) {
        hashmap.entry(key).and_modify(|e| *e += 1).or_insert(1);
    }

    hashmap
}

fn print(bots: &[BotData], size: (i32, i32)) {
    let counts = counts_by(bots, |bot| bot.p);

    for loc in (0..size.1).flat_map(|x| (0..size.0).map(move |y| (x, y))) {
        let loc = (loc.1, loc.0);

        if let Some(bot) = counts.get(&loc) {
            print!("{bot}");
        } else {
            print!(".");
        }

        if loc.0 == size.0 - 1 {
            println!()
        }
    }
}

fn parse_data(data: &str) -> Vec<BotData> {
    data.lines()
        .map(|line| {
            let mut x = line.split(['=', ',', ' ']).filter_map(|s| s.parse().ok());
            let [px, py, vx, vy] = [x.next(), x.next(), x.next(), x.next()].map(Option::unwrap);
            assert_eq!(x.next(), None);

            BotData {
                p: (px, py),
                v: (vx, vy),
            }
        })
        .collect()
}

use std::{collections::HashMap, hash::Hash};

struct BotData {
    p: (i32, i32),
    v: (i32, i32),
}

const _DATA: &str = "p=0,4 v=3,-3
p=6,3 v=-1,-3
p=10,3 v=-1,2
p=2,0 v=2,-1
p=0,0 v=1,3
p=3,0 v=-2,-2
p=7,6 v=-1,-3
p=3,0 v=-1,-2
p=9,3 v=2,3
p=7,3 v=-1,2
p=2,4 v=2,-3
p=9,5 v=-3,-3";
const _SIZE: (i32, i32) = (11, 7);

const SIZE: (i32, i32) = (101, 103);
