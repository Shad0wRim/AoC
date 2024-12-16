pub fn day12(data: String) -> (Box<dyn std::fmt::Display>, Box<dyn std::fmt::Display>) {
    let data: Vec<Vec<u8>> = data.lines().map(|line| line.bytes().collect()).collect();

    let regions = get_regions(&data);

    let areas = || regions.iter().map(|region| region.len());
    let perims = regions.iter().map(|region| get_perimeter(region, &data));
    let sides = regions.iter().map(|region| get_sides(region, &data));

    let prices = areas()
        .clone()
        .zip(perims)
        .map(|(area, perim)| area * perim)
        .sum::<usize>();
    let discount_prices = areas()
        .zip(sides)
        .map(|(area, side)| area * side)
        .sum::<usize>();

    (Box::new(prices), Box::new(discount_prices))
}

#[allow(dead_code)]
const PRACTICE_DATA: &str = "OOOOO
OXOXO
OOOOO
OXOXO
OOOOO";

fn get_sides(region: &[(usize, usize)], data: &[Vec<u8>]) -> usize {
    let size = (data.len(), data[0].len());
    DIRECTIONS
        .into_iter()
        .map(|dir| {
            region
                .iter()
                .filter(|&&loc| new_loc(loc, dir, size).is_none_or(|x| !region.contains(&x)))
                .fold((Vec::new(), 0usize), |mut acc, &(r, c)| {
                    let adjacent = match dir {
                        Direction::North | Direction::South => (r, c.wrapping_sub(1)),
                        Direction::East | Direction::West => (r.wrapping_sub(1), c),
                    };

                    (!acc.0.contains(&adjacent)).then(|| acc.1 += 1);
                    acc.0.push((r, c));

                    acc
                })
                .1
        })
        .sum()
}

fn get_perimeter(region: &[(usize, usize)], data: &[Vec<u8>]) -> usize {
    let size = (data.len(), data[0].len());
    region
        .iter()
        .map(|&plant| {
            4 - DIRECTIONS
                .into_iter()
                .filter_map(|dir| new_loc(plant, dir, size))
                .map(|loc| region.contains(&loc) as usize)
                .sum::<usize>()
        })
        .sum()
}

fn get_regions(data: &[Vec<u8>]) -> Vec<Vec<(usize, usize)>> {
    let size @ (rows, cols) = (data.len(), data[0].len());

    let mut in_region = vec![vec![false; cols]; rows];
    let mut regions = vec![];

    for loc in (0..rows * cols).map(|i| (i / cols, i % cols)) {
        if in_region[loc.0][loc.1] {
            continue;
        }

        let mut region = flood_fill(loc, data, size, &mut in_region);
        region.sort();
        regions.push(region);
    }
    regions
}

fn flood_fill(
    start: (usize, usize),
    data: &[Vec<u8>],
    size: (usize, usize),
    visited: &mut Vec<Vec<bool>>,
) -> Vec<(usize, usize)> {
    let (row, col) = start;
    let val = data[row][col];
    if visited[row][col] {
        return vec![];
    }
    visited[row][col] = true;

    let mut locs = vec![(row, col)];

    DIRECTIONS
        .map(|dir| new_loc(start, dir, size))
        .into_iter()
        .flatten()
        .filter(|&(r, c)| data[r][c] == val)
        .for_each(|loc| {
            locs.extend_from_slice(&flood_fill(loc, data, size, visited));
        });

    locs
}

#[derive(Clone, Copy)]
enum Direction {
    North,
    South,
    East,
    West,
}

const DIRECTIONS: [Direction; 4] = [
    Direction::North,
    Direction::South,
    Direction::East,
    Direction::West,
];

fn new_loc(start: (usize, usize), dir: Direction, size: (usize, usize)) -> Option<(usize, usize)> {
    let (row, col) = start;
    let (num_rows, num_cols) = size;
    Some(match dir {
        Direction::North => (row.checked_sub(1)?, col),
        Direction::South => ((0..num_rows).contains(&(row + 1)).then_some((row + 1, col)))?,
        Direction::East => ((0..num_cols).contains(&(col + 1)).then_some((row, col + 1)))?,
        Direction::West => (row, col.checked_sub(1)?),
    })
}
