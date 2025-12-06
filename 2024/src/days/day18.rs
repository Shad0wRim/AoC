pub fn day18(data: String) -> (Box<dyn std::fmt::Display>, Box<dyn std::fmt::Display>) {
    let corrupted: Vec<_> = data
        .lines()
        .filter_map(|line| line.split_once(","))
        .filter_map(|(x, y)| Some((x.parse().ok()?, y.parse().ok()?)))
        .collect();
    let memory = create_graph(&corrupted, 1024);

    let part1 = traverse_graph(&memory);

    let max_to_escape = bin_search(&corrupted);
    let (x, y) = corrupted[max_to_escape];
    let part2 = format!("{},{}", x, y);

    (Box::new(part1), Box::new(part2))
}
const SIZE: usize = 71;

fn traverse_graph(graph: &Memory) -> usize {
    let start = (0, 0);
    let end = (SIZE - 1, SIZE - 1);

    let mut dist = HashMap::new();
    let mut queue = Vec::new();

    for loc in (0..SIZE)
        .flat_map(|x| (0..SIZE).map(move |y| (x, y)))
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

    dist[&end]
}

fn bin_search(corrupted: &[Point]) -> usize {
    let mut high = corrupted.len();
    let mut low = 0;

    loop {
        let mid = (high + low) / 2;
        if mid == low {
            break mid;
        }
        let graph = create_graph(corrupted, mid);
        let dist = traverse_graph(&graph);
        match dist {
            usize::MAX => high = mid,
            _ => low = mid,
        }
    }
}

fn create_graph(corrupted: &[Point], fallen: usize) -> Memory {
    let mut memory = HashMap::new();

    let corrupted: Vec<_> = corrupted.iter().cloned().take(fallen).collect();

    for loc in (0..SIZE)
        .flat_map(|x| (0..SIZE).map(move |y| (x, y)))
        .filter(|loc| !corrupted.contains(loc))
    {
        let adjacent = DIRECTIONS
            .into_iter()
            .filter_map(|dir| dir.step(loc))
            .filter(|loc| !corrupted.contains(loc))
            .collect();

        memory.insert(loc, adjacent);
    }

    memory
}

use std::collections::HashMap;
type Memory = HashMap<Point, Vec<Point>>;
type Point = (usize, usize);

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
    fn step(self, start: Point) -> Option<Point> {
        let (x, y) = start;
        Some(match self {
            Self::Up => (x, y.checked_sub(1)?),
            Self::Down => (x, if y + 1 < SIZE { y + 1 } else { None? }),
            Self::Left => (x.checked_sub(1)?, y),
            Self::Right => (if x + 1 < SIZE { x + 1 } else { None? }, y),
        })
    }
}

const _DATA: &str = "5,4
4,2
4,5
3,0
2,1
6,3
2,4
1,5
0,6
3,3
2,6
5,1
1,2
5,5
2,5
6,5
1,4
0,4
6,4
1,1
6,1
1,0
0,5
1,6
2,0";
