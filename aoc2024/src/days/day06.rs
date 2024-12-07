use std::{isize, usize};

#[allow(dead_code)]
const PRACTICE_DATA: &str = "....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#...";

pub fn day6() {
    let data = std::fs::read_to_string("res/day06.txt").unwrap();

    let mut array = fill_array(&data);
    let Ok(_res) = run_until_loop_or_exit(&mut array) else {
        return;
    };
    let count = array.iter().fold(0, |count, line| {
        count
            + line.iter().fold(0, |count, tile| {
                count + matches!(tile, Tile::Visited) as usize
            })
    });
    println!("Part 1: {count}");

    let mut array = fill_array(&data);
    let count = check_all_locs(&mut array);
    println!("Part 2: {count}");
}

fn make_move(
    array: &mut Array,
    (r, c): (&mut usize, &mut usize),
    face: &mut Facing,
) -> Option<bool> {
    let num_rows = array.len() as isize;
    let num_cols = array[0].len() as isize;
    let (next_r, next_c) = next_loc((*r as isize, *c as isize), *face);
    if next_r < 0 || next_r >= num_rows || next_c < 0 || next_c >= num_cols {
        array[*r][*c] = Tile::Visited;
        return Some(false);
    }
    let (next_r, next_c) = (next_r as usize, next_c as usize);

    match array[next_r][next_c] {
        Tile::Empty | Tile::Visited => {
            array[*r][*c] = Tile::Visited;
            array[next_r][next_c] = Tile::Guard(*face);
            (*r, *c) = (next_r, next_c);
            None
        }
        Tile::VisitedObstruction(past) if past == *face => Some(true),
        Tile::Obstruction | Tile::VisitedObstruction(_) => {
            array[next_r][next_c] = Tile::VisitedObstruction(*face);
            *face = turn(*face);
            array[*r][*c] = Tile::Guard(*face);
            None
        }
        Tile::Guard(_) => None,
    }
}

fn check_all_locs(array: &mut Array) -> usize {
    let (rows, cols) = (array.len(), array[0].len());
    let mut handles = vec![];
    for r in 0..rows {
        for c in 0..cols {
            let new_arr = array.clone();
            let handle = std::thread::spawn(move || {
                let mut arr = new_arr;
                if !matches!(arr[r][c], Tile::Obstruction) {
                    arr[r][c] = Tile::Obstruction;
                    match run_until_loop_or_exit(&mut arr) {
                        Ok(true) => Some((r, c)),
                        _ => None,
                    }
                } else {
                    None
                }
            });
            handles.push(handle);
        }
    }
    let mut locs = vec![];
    for handle in handles {
        match handle.join() {
            Ok(Some(loc)) if locs.contains(&loc) => {}
            Ok(Some(loc)) => locs.push(loc),
            Ok(None) => {}
            Err(_) => println!("panicked"),
        };
    }
    locs.len()
}

fn run_until_loop_or_exit(array: &mut Array) -> Result<bool, ()> {
    let Some(((mut r, mut c), mut face)) = find_guard(&array) else {
        return Err(());
    };
    loop {
        if let Some(x) = make_move(array, (&mut r, &mut c), &mut face) {
            return Ok(x);
        }
    }
}

#[allow(dead_code)]
fn tile_to_char(tile: Tile) -> char {
    match tile {
        Tile::Guard(Facing::Up) => '^',
        Tile::Guard(Facing::Down) => 'v',
        Tile::Guard(Facing::Left) => '<',
        Tile::Guard(Facing::Right) => '>',
        Tile::Empty => '.',
        Tile::Obstruction => '#',
        Tile::VisitedObstruction(_) => '+',
        Tile::Visited => 'V',
    }
}

fn turn(face: Facing) -> Facing {
    use Facing::*;
    match face {
        Up => Right,
        Down => Left,
        Left => Up,
        Right => Down,
    }
}

fn next_loc((r, c): (isize, isize), face: Facing) -> (isize, isize) {
    match face {
        Facing::Up => (r - 1, c),
        Facing::Down => (r + 1, c),
        Facing::Left => (r, c - 1),
        Facing::Right => (r, c + 1),
    }
}

fn find_guard(array: &Array) -> Option<((usize, usize), Facing)> {
    for (r, line) in array.iter().enumerate() {
        for (c, &tile) in line.iter().enumerate() {
            if let Tile::Guard(face) = tile {
                return Some(((r, c), face));
            }
        }
    }
    None
}

fn fill_array(data: &str) -> Vec<Vec<Tile>> {
    let mut array = vec![];
    for line in data.lines() {
        let mut tile_line = vec![];
        for char in line.chars() {
            let tile = match char {
                '.' => Tile::Empty,
                '#' => Tile::Obstruction,
                '^' => Tile::Guard(Facing::Up),
                '>' => Tile::Guard(Facing::Right),
                'v' => Tile::Guard(Facing::Down),
                '<' => Tile::Guard(Facing::Left),
                _ => panic!(),
            };
            tile_line.push(tile);
        }
        array.push(tile_line);
    }
    array
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum Tile {
    Guard(Facing),
    Empty,
    Obstruction,
    VisitedObstruction(Facing),
    Visited,
}
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum Facing {
    Up,
    Down,
    Left,
    Right,
}
type Array = Vec<Vec<Tile>>;
