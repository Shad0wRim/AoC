pub fn day16(data: String) -> (Box<dyn std::fmt::Display>, Box<dyn std::fmt::Display>) {
    let maze = Maze::parse_maze(&data);

    let reindeer = Reindeer {
        loc: maze.start_position(),
        facing: Direction::East,
        points: 0,
        visited: vec![maze.start_position()],
    };

    let (part1, part2) = traverse_maze(reindeer, &maze);
    maze.print();

    (Box::new(part1), Box::new(part2))
}

fn traverse_maze(reindeer: Reindeer, maze: &Maze) -> (u32, u32) {
    use std::collections::HashSet;

    let mut visited = HashSet::new();
    visited.insert(reindeer.clone());

    let end_pos = maze.end_position();
    let mut searchers = vec![reindeer];

    let mut winning_paths = HashSet::new();
    let mut winning_points = u32::MAX;

    loop {
        //println!("{}", searchers.len());
        let mut new_searchers = vec![];
        for point in searchers {
            let dirs = [
                point.step_forward(),
                point.step_clockwise(),
                point.step_counterclockwise(),
            ];

            if let Some(win_state) = dirs.iter().find(|x| maze.get(x.loc) == Some(&Tile::End)) {
                match winning_points.cmp(&win_state.points) {
                    std::cmp::Ordering::Greater => {
                        winning_points = win_state.points;
                        winning_paths = HashSet::from_iter(win_state.visited.clone());
                    }
                    std::cmp::Ordering::Equal => winning_paths.extend(&win_state.visited),
                    std::cmp::Ordering::Less => (),
                }
            };

            let valid_dirs = dirs
                .into_iter()
                .filter(|x| maze.get(x.loc) != Some(&Tile::Wall))
                .filter(|x| {
                    !visited
                        .iter()
                        .any(|v| x.loc == v.loc && v.points < x.points)
                })
                .filter(|x| {
                    match (x.loc.0 - end_pos.0, end_pos.1 - x.loc.1) {
                        (0, d) | (d, 0) => x.points + d as u32,
                        (dr, dc) => x.points + dr as u32 + dc as u32 + 1000,
                    }
                    .lt(&winning_points)
                });

            new_searchers.extend(valid_dirs);
            visited.insert(point);
        }
        if new_searchers.is_empty() {
            break;
        } else {
            searchers = new_searchers;
        }
    }

    (winning_points, winning_paths.len() as u32)
}

#[derive(Clone, PartialEq, Eq, Hash, Debug)]
struct Reindeer {
    loc: (usize, usize),
    facing: Direction,
    points: u32,
    visited: Vec<(usize, usize)>,
}
impl Reindeer {
    fn step_forward(&self) -> Self {
        let mut visited = self.visited.clone();
        visited.push(self.facing.step(self.loc));
        Self {
            loc: self.facing.step(self.loc),
            facing: self.facing,
            points: self.points + 1,
            visited,
        }
    }
    fn step_clockwise(&self) -> Self {
        let mut visited = self.visited.clone();
        visited.push(self.facing.turn_clockwise().step(self.loc));
        Self {
            loc: self.facing.turn_clockwise().step(self.loc),
            facing: self.facing.turn_clockwise(),
            points: self.points + 1001,
            visited,
        }
    }
    fn step_counterclockwise(&self) -> Self {
        let mut visited = self.visited.clone();
        visited.push(self.facing.turn_counterclockwise().step(self.loc));
        Self {
            loc: self.facing.turn_counterclockwise().step(self.loc),
            facing: self.facing.turn_counterclockwise(),
            points: self.points + 1001,
            visited,
        }
    }
}

struct Maze {
    maze: Vec<Vec<Tile>>,
}
impl Maze {
    fn parse_maze(data: &str) -> Maze {
        let maze = data
            .lines()
            .map(|line| line.chars().filter_map(Tile::from_char).collect())
            .collect();
        Maze { maze }
    }
    fn size(&self) -> (usize, usize) {
        (self.maze.len(), self.maze[0].len())
    }
    fn start_position(&self) -> (usize, usize) {
        let (_, cols) = self.size();
        self.maze
            .iter()
            .flatten()
            .enumerate()
            .map(|(i, val)| ((i / cols, i % cols), val))
            .find(|(_, val)| **val == Tile::Start)
            .unwrap()
            .0
    }
    fn end_position(&self) -> (usize, usize) {
        let (_, cols) = self.size();
        self.maze
            .iter()
            .flatten()
            .enumerate()
            .map(|(i, val)| ((i / cols, i % cols), val))
            .find(|(_, val)| **val == Tile::End)
            .unwrap()
            .0
    }
    fn print(&self) {
        for line in &self.maze {
            for tile in line {
                print!("{}", tile.to_char());
            }
            println!();
        }
    }
    fn get(&self, loc: (usize, usize)) -> Option<&Tile> {
        self.maze.get(loc.0)?.get(loc.1)
    }
}

#[derive(PartialEq, Eq, Hash, Clone, Copy, Debug)]
enum Direction {
    North,
    South,
    East,
    West,
}
impl Direction {
    fn turn_clockwise(self) -> Self {
        match self {
            Self::North => Self::East,
            Self::South => Self::West,
            Self::East => Self::South,
            Self::West => Self::North,
        }
    }
    fn turn_counterclockwise(self) -> Self {
        match self {
            Self::North => Self::West,
            Self::South => Self::East,
            Self::East => Self::North,
            Self::West => Self::South,
        }
    }
    fn step(self, loc: (usize, usize)) -> (usize, usize) {
        let step = match self {
            Self::North => (-1, 0),
            Self::South => (1, 0),
            Self::East => (0, 1),
            Self::West => (0, -1),
        };
        (
            loc.0.wrapping_add_signed(step.0),
            loc.1.wrapping_add_signed(step.1),
        )
    }
}

#[derive(PartialEq, Eq, Hash, Clone, Copy)]
enum Tile {
    Wall,
    Empty,
    Start,
    End,
}
impl Tile {
    fn from_char(c: char) -> Option<Self> {
        Some(match c {
            '#' => Self::Wall,
            '.' => Self::Empty,
            'S' => Self::Start,
            'E' => Self::End,
            _ => None?,
        })
    }
    fn to_char(self) -> char {
        match self {
            Self::Wall => '#',
            Self::Empty => '.',
            Self::Start => 'S',
            Self::End => 'E',
        }
    }
}

#[allow(dead_code)]
const PRACTICE_DATA: &str = "#################
#...#...#...#..E#
#.#.#.#.#.#.#.#.#
#.#.#.#...#...#.#
#.#.#.#.###.#.#.#
#...#.#.#.....#.#
#.#.#.#.#.#####.#
#.#...#.#.#.....#
#.#.#####.#.###.#
#.#.#.......#...#
#.#.###.#####.###
#.#.#...#.....#.#
#.#.#.#####.###.#
#.#.#.........#.#
#.#.#.#########.#
#S#.............#
#################";
