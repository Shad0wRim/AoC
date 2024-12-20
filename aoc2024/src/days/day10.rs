pub fn day10(data: String) -> (Box<dyn std::fmt::Display>, Box<dyn std::fmt::Display>) {
    let data = data
        .as_bytes()
        .split(|&b| b == b'\n')
        .map(|line| line.iter().map(|&b| b - b'0').collect::<Vec<_>>())
        .filter(|line| !line.is_empty())
        .collect::<Vec<_>>();

    let slopes = transform_data(data);

    let scores = slopes
        .iter()
        .flatten()
        .filter(|t| t.height == 0)
        .map(|start| traverse_trail_scores(start, &slopes))
        .sum::<usize>();
    let ratings = slopes
        .iter()
        .flatten()
        .filter(|t| t.height == 0)
        .map(|start| traverse_trail_rating(start, &slopes))
        .sum::<usize>();

    (Box::new(scores), Box::new(ratings))
}

fn traverse_trail_scores(start: &Trail, data: &Vec<Vec<Trail>>) -> usize {
    use std::collections::HashSet;
    fn traverse_trail_rec<'a>(start: &'a Trail, data: &'a Vec<Vec<Trail>>) -> HashSet<&'a Trail> {
        if start.height == 9 {
            return HashSet::from([start]);
        }

        let mut dirs = [None; 4];
        (start.north == Some(1)).then(|| dirs[0] = Some(&data[start.row - 1][start.col]));
        (start.south == Some(1)).then(|| dirs[1] = Some(&data[start.row + 1][start.col]));
        (start.east == Some(1)).then(|| dirs[2] = Some(&data[start.row][start.col + 1]));
        (start.west == Some(1)).then(|| dirs[3] = Some(&data[start.row][start.col - 1]));

        dirs.into_iter()
            .flatten()
            .flat_map(|s| traverse_trail_rec(s, data))
            .collect()
    }
    traverse_trail_rec(start, data).len()
}

fn traverse_trail_rating(start: &Trail, data: &Vec<Vec<Trail>>) -> usize {
    if start.height == 9 {
        return 1;
    }

    let mut dirs = [None; 4];
    (start.north == Some(1)).then(|| dirs[0] = Some(&data[start.row - 1][start.col]));
    (start.south == Some(1)).then(|| dirs[1] = Some(&data[start.row + 1][start.col]));
    (start.east == Some(1)).then(|| dirs[2] = Some(&data[start.row][start.col + 1]));
    (start.west == Some(1)).then(|| dirs[3] = Some(&data[start.row][start.col - 1]));

    dirs.into_iter()
        .flatten()
        .map(|s| traverse_trail_rating(s, data))
        .sum()
}

fn transform_data(data: Vec<Vec<u8>>) -> Vec<Vec<Trail>> {
    let cols = data[0].len();
    data.iter()
        .flatten()
        .enumerate()
        .map(|(i, val)| ((i / cols, i % cols), val))
        .map(|((r, c), &val)| Trail {
            row: r,
            col: c,
            height: val,
            north: data
                .get(r.wrapping_sub(1))
                .and_then(|l| l.get(c))
                .map(|&v| v as i32 - val as i32),
            south: data
                .get(r.wrapping_add(1))
                .and_then(|l| l.get(c))
                .map(|&v| v as i32 - val as i32),
            east: data
                .get(r)
                .and_then(|l| l.get(c.wrapping_add(1)))
                .map(|&v| v as i32 - val as i32),
            west: data
                .get(r)
                .and_then(|l| l.get(c.wrapping_sub(1)))
                .map(|&v| v as i32 - val as i32),
        })
        .collect::<Vec<_>>()
        .chunks(cols)
        .map(|line| line.to_vec())
        .collect::<Vec<_>>()
}

#[derive(Eq, PartialEq, Hash, Clone)]
struct Trail {
    row: usize,
    col: usize,
    height: u8,
    north: Option<i32>,
    south: Option<i32>,
    east: Option<i32>,
    west: Option<i32>,
}

const _DATA: &str = "89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732";
