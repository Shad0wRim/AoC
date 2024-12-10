#[allow(dead_code)]
const PRACTICE_DATA: &[u8] = b"89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732";

pub fn day10() {
    let data = std::fs::read("res/day10.txt")
        .unwrap()
        .split(|&b| b == b'\n')
        .map(|line| line.iter().map(|&b| b - b'0').collect::<Vec<_>>())
        .filter(|line| !line.is_empty())
        .collect::<Vec<_>>();
    //let data = PRACTICE_DATA
    //    .split(|&b| b == b'\n')
    //    .map(|line| line.iter().map(|&b| b - b'0').collect::<Vec<_>>())
    //    .filter(|line| !line.is_empty())
    //    .collect::<Vec<_>>();

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

    println!("Part 1: {scores}");
    println!("Part 2: {ratings}");
}

use itertools::Itertools;

#[rustfmt::skip]
fn traverse_trail_scores(start: &Trail, data: &Vec<Vec<Trail>>) -> usize {
    fn traverse_trail_rec<'a>(start: &'a Trail, data: &'a Vec<Vec<Trail>>) -> Vec<&'a Trail> {
        if start.height == 9 { return vec![start]; }

        let mut dirs = [None; 4];
        if start.north == Some(1) { dirs[0] = Some(&data[start.row - 1][start.col]) }
        if start.south == Some(1) { dirs[1] = Some(&data[start.row + 1][start.col]) }
        if start.east == Some(1)  { dirs[2] = Some(&data[start.row][start.col + 1]) }
        if start.west == Some(1)  { dirs[3] = Some(&data[start.row][start.col - 1]) }

        dirs.into_iter()
            .flatten()
            .flat_map(|s| traverse_trail_rec(s, data))
            .collect()
    }
    traverse_trail_rec(start, data).into_iter().unique().count()
}

#[rustfmt::skip]
fn traverse_trail_rating(start: &Trail, data: &Vec<Vec<Trail>>) -> usize {
    if start.height == 9 { return 1; }

    let mut dirs = [None; 4];
    if start.north == Some(1) { dirs[0] = Some(&data[start.row - 1][start.col]) }
    if start.south == Some(1) { dirs[1] = Some(&data[start.row + 1][start.col]) }
    if start.east == Some(1) { dirs[2] = Some(&data[start.row][start.col + 1]) }
    if start.west == Some(1) { dirs[3] = Some(&data[start.row][start.col - 1]) }

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
        .chunks(cols)
        .into_iter()
        .map(|line| line.into_iter().collect::<Vec<_>>())
        .collect::<Vec<_>>()
}

#[derive(Eq, PartialEq, Hash)]
struct Trail {
    row: usize,
    col: usize,
    height: u8,
    north: Option<i32>,
    south: Option<i32>,
    east: Option<i32>,
    west: Option<i32>,
}
