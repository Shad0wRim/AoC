use itertools::Itertools;

#[allow(dead_code)]
const PRACTICE_DATA: &str = "............
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

pub fn day8() {
    let data = std::fs::read_to_string("res/day08.txt").unwrap();
    //let data = PRACTICE_DATA;
    let array: Array = data.lines().map(|line| line.chars().collect()).collect();
    let (rows, cols) = (array.len() as isize, array[0].len() as isize);
    let mut char_locs = std::collections::HashMap::new();
    array
        .iter()
        .flatten()
        .enumerate()
        .map(|(ind, c)| ((ind as isize / cols, ind as isize % cols), c))
        .filter(|(_, &c)| c != '.')
        .for_each(|(ind, c)| match char_locs.get_mut(c) {
            None => {
                char_locs.insert(*c, vec![ind]);
            }
            Some(locs) => locs.push(ind),
        });
    let in_bounds = |(r, c)| r >= 0 && r < rows && c >= 0 && c < cols;

    let mut node_locs1 = vec![];
    let mut node_locs2 = vec![];
    for antenna_locs in char_locs.values() {
        for antenna_pairs in antenna_locs.iter().combinations(2) {
            let first = antenna_pairs[0];
            let second = antenna_pairs[1];
            let (h, v) = (first.0 - second.0, first.1 - second.1);

            // only the nodes directly adjacent
            let mut nodes1 = vec![];
            for i in [-2, 1] {
                let node = (first.0 + i * h, first.1 + i * v);
                nodes1.push(node);
            }
            nodes1
                .into_iter()
                .filter(|node| in_bounds(*node))
                .for_each(|node| node_locs1.push(node));

            // all nodes
            let mut nodes2 = vec![];
            for i in -50..50 {
                let node = (first.0 + i * h, first.1 + i * v);
                nodes2.push(node);
            }
            nodes2
                .into_iter()
                .filter(|node| in_bounds(*node))
                .for_each(|node| node_locs2.push(node));
        }
    }
    let count1 = node_locs1.into_iter().unique().collect::<Vec<_>>().len();
    let count2 = node_locs2.into_iter().unique().collect::<Vec<_>>().len();
    println!("Part 1: {count1}");
    println!("Part 2: {count2}");
}

type Array = Vec<Vec<char>>;
