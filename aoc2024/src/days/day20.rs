pub fn day20(data: String) -> (Box<dyn std::fmt::Display>, Box<dyn std::fmt::Display>) {
    let (start, _end, size, racetrack) = create_graph(&data);
    let saving_threshold = 100;

    let distances = fill_distances(&racetrack, start, size);

    let part1 = check_shortcuts(&distances, size, saving_threshold);
    let part2 = check_longer_shortcuts(&distances, size, saving_threshold);

    (Box::new(part1), Box::new(part2))
}
fn check_shortcuts(dists: &HashMap<Point, usize>, size: (usize, usize), threshold: usize) -> usize {
    let mut num_cheats = 0;
    for (loc, dist) in dists {
        for new_loc in Direction::step_around(*loc, 2, size) {
            match dists.get(&new_loc) {
                Some(new_dist) => {
                    let diff = if new_dist > dist { new_dist - dist } else { 0 };
                    if diff.saturating_sub(2) >= threshold {
                        num_cheats += 1
                    }
                }
                None => (),
            }
        }
    }

    num_cheats
}
fn check_longer_shortcuts(
    dists: &HashMap<Point, usize>,
    size: (usize, usize),
    threshold: usize,
) -> usize {
    let mut num_cheats = 0;
    for (loc, dist) in dists {
        for (n, new_loc) in (0..=20).flat_map(|n| {
            Direction::step_around(*loc, n, size)
                .into_iter()
                .map(move |loc| (n, loc))
        }) {
            match dists.get(&new_loc) {
                Some(new_dist) => {
                    let diff = if new_dist > dist { new_dist - dist } else { 0 };
                    if diff.saturating_sub(n) >= threshold {
                        num_cheats += 1;
                    }
                }
                None => (),
            }
        }
    }

    num_cheats
}
fn fill_distances(graph: &Racetrack, start: Point, size: (usize, usize)) -> HashMap<Point, usize> {
    let mut dist = HashMap::new();
    let mut queue = Vec::new();

    for loc in (0..size.0)
        .flat_map(|r| (0..size.1).map(move |c| (r, c)))
        .filter(|loc| graph.contains_key(loc))
    {
        dist.insert(loc, usize::MAX);
        queue.push(loc);
    }
    *dist.get_mut(&start).unwrap() = 0;

    while let Some((min, _)) = queue.iter().enumerate().min_by_key(|(_, loc)| dist[loc]) {
        let u = queue.remove(min);

        for v in graph[&u].iter().filter(|v| queue.contains(v)) {
            let alt = dist[&u].saturating_add(1);
            if alt < dist[v] {
                *dist.get_mut(v).unwrap() = alt;
            }
        }
    }

    dist
}
fn create_graph(data: &str) -> (Point, Point, (usize, usize), Racetrack) {
    let size = (
        data.lines().count(),
        data.chars().take_while(|c| *c != '\n').count(),
    );
    let mut memory = HashMap::new();

    let mut start = (0, 0);
    let mut end = (0, 0);
    for (r, line) in data.lines().enumerate() {
        for (c, char) in line.chars().enumerate() {
            match char {
                '.' => (),
                'E' => end = (r, c),
                'S' => start = (r, c),
                '#' => continue,
                _ => panic!(),
            };
            memory.insert((r, c), vec![]);
        }
    }

    for loc in (0..size.0).flat_map(|r| (0..size.1).map(move |c| (r, c))) {
        let adjacent: Vec<_> = DIRECTIONS
            .into_iter()
            .filter_map(|dir| dir.step(loc, size))
            .filter(|loc| memory.contains_key(loc))
            .collect();

        for new_loc in adjacent {
            memory.entry(loc).and_modify(|e| e.push(new_loc));
        }
    }

    (start, end, size, memory)
}

fn _print(dists: &HashMap<Point, usize>, size: (usize, usize)) {
    for r in 0..size.0 {
        for c in 0..size.1 {
            match dists.get(&(r, c)) {
                Some(d) => print!("{}", d % 10),
                None => print!("#"),
            }
        }
        println!();
    }
}

use std::collections::{HashMap, HashSet};
type Point = (usize, usize);
type Racetrack = HashMap<Point, Vec<Point>>;
#[derive(Debug)]
enum Direction {
    Up,
    Down,
    Left,
    Right,
}
const DIRECTIONS: [Direction; 4] = [
    Direction::Up,
    Direction::Down,
    Direction::Left,
    Direction::Right,
];
impl Direction {
    fn step(self, start: Point, size: (usize, usize)) -> Option<Point> {
        self.step_n(start, 1, size)
    }
    fn step_n(self, start: Point, n: usize, size: (usize, usize)) -> Option<Point> {
        let (r, c) = start;
        Some(match self {
            Self::Up => (r.checked_sub(n)?, c),
            Self::Down => ((r + n < size.0).then_some(r + n)?, c),
            Self::Left => (r, c.checked_sub(n)?),
            Self::Right => (r, (c + n < size.1).then_some(c + n)?),
        })
    }
    fn step_around(start: Point, n: usize, size: (usize, usize)) -> HashSet<Point> {
        let (r, c) = start;
        let n = n as isize;
        let (rows, cols) = (size.0 as isize, size.1 as isize);

        let distances: Vec<_> = (0..=n)
            .map(|r_dist| (r_dist, n - r_dist))
            .chain((0..=n).map(|r_dist| (-r_dist, n - r_dist)))
            .chain((0..=n).map(|r_dist| (r_dist, r_dist - n)))
            .chain((0..=n).map(|r_dist| (-r_dist, r_dist - n)))
            .collect();

        distances
            .into_iter()
            .filter_map(|(r_dist, c_dist)| {
                let new_r = r as isize + r_dist;
                let new_c = c as isize + c_dist;
                if (0..rows).contains(&new_r) && (0..cols).contains(&new_c) {
                    Some((new_r as usize, new_c as usize))
                } else {
                    None
                }
            })
            .collect()
    }
}

const _DATA: &str = "###############
#...#...#.....#
#.#.#.#.#.###.#
#S#...#.#.#...#
#######.#.#.###
#######.#.#...#
#######.#.###.#
###..E#...#...#
###.#######.###
#...###...#...#
#.#####.#.###.#
#.#...#.#.#...#
#.#.#.#.#.#.###
#...#...#...###
###############";
