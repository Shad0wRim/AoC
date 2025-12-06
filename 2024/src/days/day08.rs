use std::collections::{HashMap, HashSet};

pub fn day8(data: String) -> (Box<dyn std::fmt::Display>, Box<dyn std::fmt::Display>) {
    let array: Array = data.lines().map(|line| line.chars().collect()).collect();
    let (rows, cols) = (array.len() as isize, array[0].len() as isize);
    let mut char_locs: HashMap<&char, Vec<(isize, isize)>> = HashMap::new();
    array
        .iter()
        .flatten()
        .enumerate()
        .map(|(ind, c)| ((ind as isize / cols, ind as isize % cols), c))
        .filter(|(_, &c)| c != '.')
        .for_each(|(ind, c)| {
            char_locs
                .entry(c)
                .and_modify(|e| e.push(ind))
                .or_insert_with(|| vec![ind]);
        });
    let in_bounds = |(r, c)| (0..rows).contains(&r) && (0..cols).contains(&c);

    let mut node_locs1 = HashSet::new();
    let mut node_locs2 = HashSet::new();
    for antenna_locs in char_locs.values() {
        let antenna_combinations = (0..antenna_locs.len())
            .flat_map(|i| (i + 1..antenna_locs.len()).map(move |j| (i, j)))
            .map(|(i, j)| (antenna_locs[i], antenna_locs[j]));

        for (first, second) in antenna_combinations {
            let (h, v) = (first.0 - second.0, first.1 - second.1);

            // only the nodes directly adjacent
            let mut nodes1 = vec![];
            for i in [-2, 1] {
                let node = (first.0 + i * h, first.1 + i * v);
                nodes1.push(node);
            }
            node_locs1.extend(nodes1.into_iter().filter(|node| in_bounds(*node)));

            // all nodes
            let mut nodes2 = vec![];
            for i in -50..50 {
                let node = (first.0 + i * h, first.1 + i * v);
                nodes2.push(node);
            }
            node_locs2.extend(nodes2.into_iter().filter(|node| in_bounds(*node)));
        }
    }
    let part1 = node_locs1.len();
    let part2 = node_locs2.len();

    (Box::new(part1), Box::new(part2))
}

type Array = Vec<Vec<char>>;

const _DATA: &str = "............
........0...
.....0......
.......0....
....0.......
......A.....
............
............
........A...
.........A..
............
............";
