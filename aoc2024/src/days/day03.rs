pub fn day3() {
    let data = std::fs::read_to_string("res/day03.txt").unwrap();
    let mut scanner = Scanner::new(&data);

    print!("Part 1: ");

    let mut total = 0;
    while !scanner.is_done() {
        scanner.take_until(&'m');
        if let Some(n) = match_mul(&mut scanner) {
            total += n;
        } else {
            scanner.pop();
        }
    }
    println!("{total}");

    print!("Part 2: ");
    total = 0;
    scanner.reset();
    let mut active = true;
    while !scanner.is_done() {
        if active {
            scanner.take_until_either(&['m', 'd']);
            if match_str(&mut scanner, "don't()") {
                active = false;
                continue;
            }

            if let Some(n) = match_mul(&mut scanner) {
                total += n;
            } else {
                scanner.pop();
            }
        } else {
            scanner.take_until(&'d');
            if match_str(&mut scanner, "do()") {
                active = true;
                continue;
            } else {
                scanner.pop();
            }
        }
    }
    println!("{total}");
}

fn match_mul(scanner: &mut Scanner) -> Option<u32> {
    if match_str(scanner, "mul(") {
        let num1 = match_num(scanner)?;
        if !scanner.take(&',') {
            return None;
        };
        let num2 = match_num(scanner)?;
        if !scanner.take(&')') {
            return None;
        }
        Some(num1 * num2)
    } else {
        None
    }
}

fn match_str(scanner: &mut Scanner, str: &str) -> bool {
    for (i, c) in str.chars().enumerate() {
        let Some(&next_c) = scanner.peek_n(i) else {
            return false;
        };
        if next_c != c {
            return false;
        }
    }
    for _ in 0..str.len() {
        scanner.pop();
    }
    return true;
}

fn match_num(scanner: &mut Scanner) -> Option<u32> {
    let &c = scanner.peek()?;
    if !c.is_ascii_digit() {
        return None;
    }
    scanner.pop();

    let mut digits = String::from(c);

    let &c = scanner.peek()?;
    if !c.is_ascii_digit() {
        return Some(digits.parse().unwrap());
    }
    scanner.pop();
    digits.push(c);

    let &c = scanner.peek()?;
    if !c.is_ascii_digit() {
        return Some(digits.parse().unwrap());
    }
    scanner.pop();
    digits.push(c);

    Some(digits.parse().unwrap())
}

struct Scanner {
    cursor: usize,
    characters: Vec<char>,
}

impl Scanner {
    fn new(str: &str) -> Self {
        Self {
            cursor: 0,
            characters: str.chars().collect(),
        }
    }

    fn reset(&mut self) {
        self.cursor = 0;
    }

    fn peek(&self) -> Option<&char> {
        self.characters.get(self.cursor)
    }

    fn peek_n(&self, n: usize) -> Option<&char> {
        self.characters.get(self.cursor + n)
    }

    fn is_done(&self) -> bool {
        self.cursor == self.characters.len()
    }

    fn pop(&mut self) -> Option<&char> {
        match self.characters.get(self.cursor) {
            Some(c) => {
                self.cursor += 1;
                Some(c)
            }
            None => None,
        }
    }

    fn take(&mut self, target: &char) -> bool {
        match self.characters.get(self.cursor) {
            Some(c) if target == c => {
                self.cursor += 1;
                true
            }
            _ => false,
        }
    }

    fn take_until_either(&mut self, targets: &[char]) -> bool {
        while let Some(c) = self.characters.get(self.cursor) {
            if targets.contains(c) {
                return true;
            } else {
                self.pop();
            }
        }
        return false;
    }

    fn take_until(&mut self, target: &char) -> bool {
        while let Some(c) = self.characters.get(self.cursor) {
            if c == target {
                return true;
            } else {
                self.pop();
            }
        }
        return false;
    }
}
