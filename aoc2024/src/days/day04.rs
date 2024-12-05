pub fn day4() {
    let data = std::fs::read_to_string("res/day04.txt").unwrap();
    let arr: CharArr = data
        .lines()
        .map(str::chars)
        .map(std::str::Chars::collect)
        .collect();
    let mut searcher = Searcher { r: 0, c: 0, arr };

    print!("Part 1: ");

    let mut total = 0;
    loop {
        loop {
            total += check_xmas(&searcher);
            if !searcher.move_next_col() {
                break;
            }
        }
        if !searcher.move_next_row() {
            break;
        }
    }
    println!("{total}");

    print!("Part 2: ");
    searcher.reset();
    total = 0;
    loop {
        loop {
            total += check_mas(&searcher) as u32;
            if !searcher.move_next_col() {
                break;
            }
        }
        if !searcher.move_next_row() {
            break;
        }
    }
    println!("{total}");
}

fn check_mas(searcher: &Searcher) -> bool {
    matches!(searcher.peek_offset(0, 0), Some('A'))
        && (matches!(
            (searcher.peek_offset(1, 1), searcher.peek_offset(-1, -1)),
            (Some('M'), Some('S'))
        ) || matches!(
            (searcher.peek_offset(1, 1), searcher.peek_offset(-1, -1)),
            (Some('S'), Some('M'))
        ))
        && (matches!(
            (searcher.peek_offset(-1, 1), searcher.peek_offset(1, -1)),
            (Some('M'), Some('S'))
        ) || matches!(
            (searcher.peek_offset(-1, 1), searcher.peek_offset(1, -1)),
            (Some('S'), Some('M'))
        ))
}

fn check_xmas(searcher: &Searcher) -> u32 {
    // check that current char is X
    if !matches!(searcher.peek_offset(0, 0), Some('X')) {
        return 0;
    };
    let mut total = 0;
    total += check_xmas_dir(searcher, 1, 1) as u32;
    total += check_xmas_dir(searcher, 1, -1) as u32;
    total += check_xmas_dir(searcher, 1, 0) as u32;
    total += check_xmas_dir(searcher, -1, 1) as u32;
    total += check_xmas_dir(searcher, -1, -1) as u32;
    total += check_xmas_dir(searcher, -1, 0) as u32;
    total += check_xmas_dir(searcher, 0, 1) as u32;
    total += check_xmas_dir(searcher, 0, -1) as u32;
    total
}

type CharArr = Vec<Vec<char>>;
struct Searcher {
    r: usize,
    c: usize,
    arr: CharArr,
}

fn check_xmas_dir(searcher: &Searcher, r: isize, c: isize) -> bool {
    matches!(searcher.peek_offset(r, c), Some('M'))
        && matches!(searcher.peek_offset(r * 2, c * 2), Some('A'))
        && matches!(searcher.peek_offset(r * 3, c * 3), Some('S'))
}

impl Searcher {
    fn reset(&mut self) {
        self.r = 0;
        self.c = 0;
    }
    fn peek_offset(&self, r: isize, c: isize) -> Option<char> {
        self.arr
            .get(self.r.checked_add_signed(r)?)?
            .get(self.c.checked_add_signed(c)?)
            .copied()
    }
    fn move_next_col(&mut self) -> bool {
        match self.arr.get(self.r) {
            Some(row) if self.c < row.len() => {
                self.c += 1;
                true
            }
            _ => false,
        }
    }
    fn move_next_row(&mut self) -> bool {
        if self.r < self.arr.len() {
            self.r += 1;
            self.c = 0;
            true
        } else {
            false
        }
    }
}
