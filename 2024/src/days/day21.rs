pub fn day21(_data: String) -> (Box<dyn std::fmt::Display>, Box<dyn std::fmt::Display>) {
    let codes = parse_data(&_data);
    dbg!(&codes);
    let part1 = 0;
    let part2 = 0;

    (Box::new(part1), Box::new(part2))
}

fn parse_data(data: &str) -> Vec<Vec<NumKeyPad>> {
    data.lines()
        .map(|line| {
            line.chars()
                .map(|c| match c {
                    '0' => NumKeyPad::N0,
                    '1' => NumKeyPad::N1,
                    '2' => NumKeyPad::N2,
                    '3' => NumKeyPad::N3,
                    '4' => NumKeyPad::N4,
                    '5' => NumKeyPad::N5,
                    '6' => NumKeyPad::N6,
                    '7' => NumKeyPad::N7,
                    '8' => NumKeyPad::N8,
                    '9' => NumKeyPad::N9,
                    'A' => NumKeyPad::A,
                    _ => panic!(),
                })
                .collect()
        })
        .collect()
}

#[derive(Debug, PartialEq, Eq, Clone, Copy)]
enum NumKeyPad {
    N0,
    N1,
    N2,
    N3,
    N4,
    N5,
    N6,
    N7,
    N8,
    N9,
    A,
}

#[derive(Debug, PartialEq, Eq, Clone, Copy)]
enum DirKeyPad {
    Up,
    Down,
    Left,
    Right,
    A,
}
impl DirKeyPad {
    fn path(self, other: Self) -> Vec<Direction> {
        let start @ (start_x, start_y) = self.to_loc();
        let end @ (end_x, end_y) = other.to_loc();
        dbg!(start);
        dbg!(end);

        let x = end_x - start_x;
        let y = end_y - start_y;

        use Direction as D;
        let res = match (x, y) {
            (-2, -1) => vec![D::Down, D::Left, D::Left],
            (-1, -1) => vec![D::Down, D::Left],
            (0, -1) => vec![D::Down],
            (1, -1) => vec![D::Right, D::Down],
            (2, -1) => vec![D::Right, D::Right, D::Down],
            (-2, 0) => vec![D::Left; 2],
            (-1, 0) => vec![D::Left],
            (0, 0) => vec![],
            (1, 0) => vec![D::Right],
            (2, 0) => vec![D::Right; 2],
            (-2, 1) => vec![D::Up, D::Left, D::Left],
            (-1, 1) => vec![D::Up, D::Left],
            (0, 1) => vec![D::Up],
            (1, 1) => vec![D::Right, D::Up],
            (2, 1) => vec![D::Right, D::Right, D::Up],
            _ => unreachable!(),
        };
        assert_eq!(
            res.iter()
                .fold(Some(self), |acc, dir| acc.and_then(|loc| loc.step(*dir))),
            Some(other)
        );
        res
    }
    fn to_loc(self) -> (i32, i32) {
        match self {
            Self::Up => (0, 1),
            Self::Down => (0, 0),
            Self::Left => (-1, 0),
            Self::Right => (1, 0),
            Self::A => (1, 1),
        }
    }
    fn step(self, dir: Direction) -> Option<Self> {
        use Direction as D;
        Some(match (self, dir) {
            (Self::Up, D::Down) => Self::Down,
            (Self::Up, D::Right) => Self::A,
            (Self::Down, D::Up) => Self::Up,
            (Self::Down, D::Left) => Self::Left,
            (Self::Down, D::Right) => Self::Right,
            (Self::Left, D::Right) => Self::Down,
            (Self::Right, D::Up) => Self::A,
            (Self::Right, D::Left) => Self::Down,
            (Self::A, D::Down) => Self::Right,
            (Self::A, D::Left) => Self::Up,
            _ => None?,
        })
    }
}

#[derive(Debug, PartialEq, Eq, Clone, Copy)]
enum Direction {
    Up,
    Down,
    Left,
    Right,
}

const _DATA: &str = "029A
980A
179A
456A
379A";
