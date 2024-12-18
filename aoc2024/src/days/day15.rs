pub fn day15(data: String) -> (Box<dyn std::fmt::Display>, Box<dyn std::fmt::Display>) {
    let (map_data, move_data) = data.split_once("\n\n").unwrap();

    let mut warehouse = Warehouse::parse_warehouse(map_data);
    let mut wide_warehouse = Warehouse::parse_warehouse_wide(map_data);
    let moves = Move::parse_moves(move_data);

    for dir in &moves {
        warehouse.move_robot(*dir);
        wide_warehouse.move_robot_wide(*dir);
    }
    warehouse.print();
    wide_warehouse.print();

    let part1 = warehouse.count_coords();
    let part2 = wide_warehouse.count_coords();

    (Box::new(part1), Box::new(part2))
}

#[derive(Clone, Debug, PartialEq, Eq)]
struct Warehouse {
    tiles: Vec<Tile>,
    size: (usize, usize),
}

impl Warehouse {
    fn parse_warehouse_wide(map: &str) -> Warehouse {
        let rows = map.lines().count();
        let cols = 2 * map.chars().take_while(|c| *c != '\n').count();
        let size = (rows, cols);

        let tiles = map
            .chars()
            .filter_map(Tile::from_char_wide)
            .flatten()
            .collect();

        Warehouse { tiles, size }
    }

    fn parse_warehouse(map: &str) -> Warehouse {
        let rows = map.lines().count();
        let cols = map.chars().take_while(|c| *c != '\n').count();
        let size = (rows, cols);

        let tiles = map.chars().filter_map(Tile::from_char).collect();

        Warehouse { tiles, size }
    }

    unsafe fn get_unchecked(&self, row: usize, col: usize) -> &Tile {
        self.tiles.get_unchecked(self.size.1 * row + col)
    }
    unsafe fn get_unchecked_mut(&mut self, row: usize, col: usize) -> &mut Tile {
        self.tiles.get_unchecked_mut(self.size.1 * row + col)
    }
    fn get(&self, row: usize, col: usize) -> Option<&Tile> {
        if row < self.size.0 && col < self.size.1 {
            unsafe { Some(self.get_unchecked(row, col)) }
        } else {
            None
        }
    }
    fn get_mut(&mut self, row: usize, col: usize) -> Option<&mut Tile> {
        if row < self.size.0 && col < self.size.1 {
            unsafe { Some(self.get_unchecked_mut(row, col)) }
        } else {
            None
        }
    }
    fn find_robot(&self) -> (usize, usize) {
        self.tiles
            .iter()
            .position(|t| *t == Tile::Robot)
            .map(|l| (l / self.size.1, l % self.size.1))
            .expect("There should be a robot")
    }
    /// returns true if the robot moved
    fn move_robot(&mut self, dir: Move) -> bool {
        let (r_row, r_col) = self.find_robot();
        let dir = match dir {
            Move::North => (-1, 0),
            Move::East => (0, 1),
            Move::South => (1, 0),
            Move::West => (0, -1),
        };

        let mut spaces = 1;
        loop {
            let (n_row1, n_col1) = (
                r_row.wrapping_add_signed(dir.0),
                r_col.wrapping_add_signed(dir.1),
            );
            let (n_row, n_col) = (
                r_row.wrapping_add_signed(dir.0 * spaces),
                r_col.wrapping_add_signed(dir.1 * spaces),
            );

            let Some(tile) = self.get(n_row, n_col) else {
                break false;
            };

            match tile {
                Tile::FullBox => spaces += 1,
                Tile::Wall => break false,
                Tile::Empty => {
                    *self.get_mut(r_row, r_col).unwrap() = Tile::Empty;
                    *self.get_mut(n_row1, n_col1).unwrap() = Tile::Robot;
                    if spaces != 1 {
                        *self.get_mut(n_row, n_col).unwrap() = Tile::FullBox;
                    }
                    break true;
                }
                _ => unreachable!(),
            }
        }
    }
    /// returns true if the robot moved
    fn move_robot_wide(&mut self, dir: Move) -> bool {
        let (robot_row, robot_col) = self.find_robot();
        match dir {
            dir @ (Move::East | Move::West) => {
                let dir = if dir == Move::East { 1 } else { -1 };
                let mut spaces = 1;
                loop {
                    let shifted_col = robot_col.wrapping_add_signed(dir * spaces);
                    let Some(tile) = self.get(robot_row, shifted_col) else {
                        break false;
                    };

                    match tile {
                        Tile::RightBox | Tile::LeftBox => spaces += 1,
                        Tile::Wall => break false,
                        Tile::Empty => {
                            for col_dist in (1..=spaces).rev() {
                                let shifted_col = robot_col.wrapping_add_signed(dir * col_dist);
                                let shifted_minus1_col =
                                    robot_col.wrapping_add_signed(dir * (col_dist - 1));

                                *self.get_mut(robot_row, shifted_col).unwrap() =
                                    *self.get(robot_row, shifted_minus1_col).unwrap();
                            }
                            *self.get_mut(robot_row, robot_col).unwrap() = Tile::Empty;
                            break true;
                        }
                        _ => unreachable!(),
                    }
                }
            }
            dir @ (Move::North | Move::South) => {
                let dir = if dir == Move::North { -1 } else { 1 };
                let mut box_cols = vec![vec![robot_col]];

                loop {
                    let shifted_row = robot_row.wrapping_add_signed(dir * box_cols.len() as isize);
                    let tiles: Vec<_> = box_cols
                        .last()
                        .unwrap()
                        .iter()
                        .map(|&col| *self.get(shifted_row, col).unwrap())
                        .collect();

                    if tiles.iter().any(|&tile| tile == Tile::Wall) {
                        break false;
                    } else if tiles.iter().all(|&tile| tile == Tile::Empty) {
                        if box_cols.len() == 1 {
                            *self.get_mut(shifted_row, robot_col).unwrap() = Tile::Robot;
                        } else {
                            let mut previous: Vec<_> = (0..self.size.1)
                                .map(|col| *self.get(robot_row, col).unwrap())
                                .collect();

                            for close in 0..box_cols.len() {
                                let far = close + 1;
                                let far_row = robot_row.wrapping_add_signed(dir * far as isize);
                                if far == box_cols.len() {
                                    for &col in &box_cols[close] {
                                        *self.get_mut(far_row, col).unwrap() = previous[col];
                                    }
                                } else {
                                    for (col, prev_tile) in previous.iter_mut().enumerate() {
                                        let closer = box_cols[close].contains(&col);
                                        let farther = box_cols[far].contains(&col);

                                        let tmp = *prev_tile;
                                        *prev_tile = *self.get(far_row, col).unwrap();

                                        match (closer, farther) {
                                            (true, _) => *self.get_mut(far_row, col).unwrap() = tmp,
                                            (false, true) => {
                                                *self.get_mut(far_row, col).unwrap() = Tile::Empty
                                            }
                                            (false, false) => (),
                                        }
                                    }
                                }
                            }
                        }

                        *self.get_mut(robot_row, robot_col).unwrap() = Tile::Empty;
                        break true;
                    } else {
                        let next_row = box_cols
                            .last()
                            .unwrap()
                            .iter()
                            .zip(tiles)
                            .flat_map(|(&col, tile)| match tile {
                                Tile::LeftBox => vec![col, col + 1],
                                Tile::RightBox => vec![col - 1, col],
                                Tile::Empty => vec![],
                                _ => unreachable!(),
                            })
                            .collect();
                        box_cols.push(next_row);
                    }
                }
            }
        }
    }
    fn count_coords(&self) -> usize {
        let mut total = 0;
        for r in 0..self.size.0 {
            for c in 0..self.size.1 {
                if let Some(Tile::FullBox | Tile::LeftBox) = self.get(r, c) {
                    total += 100 * r + c;
                }
            }
        }
        total
    }

    fn print(&self) {
        for r in 0..self.size.0 {
            for c in 0..self.size.1 {
                print!("{}", self.get(r, c).unwrap().to_char());
            }
            println!();
        }
    }
}

#[derive(Clone, Debug, Copy, PartialEq, Eq, Hash)]
enum Tile {
    Robot,
    FullBox,
    LeftBox,
    RightBox,
    Wall,
    Empty,
}
impl Tile {
    fn to_char(self) -> char {
        match self {
            Self::Robot => '@',
            Self::FullBox => 'O',
            Self::LeftBox => '[',
            Self::RightBox => ']',
            Self::Wall => '#',
            Self::Empty => '.',
        }
    }
    fn from_char_wide(c: char) -> Option<[Self; 2]> {
        Some(match c {
            '@' => [Self::Robot, Self::Empty],
            'O' => [Self::LeftBox, Self::RightBox],
            '#' => [Self::Wall, Self::Wall],
            '.' => [Self::Empty, Self::Empty],
            _ => None?,
        })
    }
    fn from_char(c: char) -> Option<Self> {
        Some(match c {
            '@' => Self::Robot,
            'O' => Self::FullBox,
            '#' => Self::Wall,
            '.' => Self::Empty,
            _ => None?,
        })
    }
}

#[derive(Clone, Debug, Copy, PartialEq, Eq, Hash)]
enum Move {
    North,
    East,
    South,
    West,
}
impl Move {
    fn parse_moves(moves: &str) -> Vec<Move> {
        moves
            .chars()
            .filter(|c| *c != '\n')
            .map(|c| match c {
                '^' => Move::North,
                '>' => Move::East,
                'v' => Move::South,
                '<' => Move::West,
                _ => unreachable!(),
            })
            .collect()
    }
}

#[allow(dead_code)]
const PRACTICE_DATA: &str = "##########
#..O..O.O#
#......O.#
#.OO..O.O#
#..O@..O.#
#O#..O...#
#O..O..O.#
#.OO.O.OO#
#....O...#
##########

<vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^
vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v
><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<
<<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^
^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><
^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^
>^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^
<><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>
^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>
v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^";
