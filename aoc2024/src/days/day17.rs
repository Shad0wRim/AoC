pub fn day17(data: String) -> (Box<dyn std::fmt::Display>, Box<dyn std::fmt::Display>) {
    let mut computer = Computer::parse(&data);

    let part1 = computer
        .run()
        .iter()
        .map(|x| x.to_string())
        .collect::<Vec<_>>()
        .join(",");

    let target_values: Vec<_> = computer.codes.iter().map(|x| x.to_number()).collect();
    let mut current_value = vec![0; target_values.len()];
    current_value[0] = 1;
    let mut idx = 0;
    let part2 = loop {
        let octal_val = current_value.iter().fold(0, |v, x| (v << 3) | x);

        let output = computer.run_with_a(octal_val);

        if output == target_values {
            break octal_val;
        } else if output
            .iter()
            .rev()
            .zip(target_values.iter().rev())
            .take(idx + 1)
            .all(|(a, b)| a == b)
        {
            idx += 1;
        } else {
            while current_value[idx] == 7 {
                current_value[idx] = 0;
                idx -= 1;
            }
            current_value[idx] += 1;
        };
    };

    (Box::new(part1), Box::new(part2))
}

#[derive(Debug)]
struct Computer {
    a: u64,
    b: u64,
    c: u64,
    i_ptr: usize,
    codes: Vec<OpCode>,
}
impl Computer {
    fn parse(data: &str) -> Self {
        let (regs, program) = data.split_once("\n\n").unwrap();
        let mut regs = regs.lines().map(|line| {
            line.chars()
                .skip(12)
                .fold(0, |acc, c| acc * 10 + c.to_digit(10).unwrap() as u64)
        });
        let [a, b, c] = [regs.next(), regs.next(), regs.next()].map(Option::unwrap);

        let codes = program
            .chars()
            .skip(8)
            .filter_map(|c| c.to_digit(10).map(|x| x as u8))
            .filter_map(OpCode::from_code)
            .collect();

        Self {
            a,
            b,
            c,
            i_ptr: 0,
            codes,
        }
    }
    fn run(&mut self) -> Vec<u8> {
        let mut output = Vec::new();
        while self.execute(&mut output) {}
        output
    }
    fn run_with_a(&mut self, a: u64) -> Vec<u8> {
        let mut output = Vec::new();
        self.a = a;
        self.b = 0;
        self.c = 0;
        self.i_ptr = 0;
        while self.execute(&mut output) {}
        output
    }
    /// returns false if the computer halted
    fn execute(&mut self, output: &mut Vec<u8>) -> bool {
        let instruction = match self.codes.get(self.i_ptr..=self.i_ptr + 1) {
            Some(&[i, o]) => match i.operator_kind() {
                OperatorKind::Combo => (i, o.into_combo().as_value(self)),
                OperatorKind::Literal => (i, o.into_literal().as_value(self)),
                OperatorKind::Ignore => (i, 0),
            },
            Some(_) => unreachable!(),
            None => return false,
        };

        match instruction {
            (OpCode::Adv, o) => self.a >>= o,
            (OpCode::Bxl, o) => self.b ^= o,
            (OpCode::Bst, o) => self.b = o % 8,
            (OpCode::Jnz, o) if self.a != 0 => self.i_ptr = o as usize,
            (OpCode::Bxc, _) => self.b ^= self.c,
            (OpCode::Out, o) => output.push(o as u8 % 8),
            (OpCode::Bdv, o) => self.b = self.a >> o,
            (OpCode::Cdv, o) => self.c = self.a >> o,
            _ => (),
        }

        if instruction.0 != OpCode::Jnz || self.a == 0 {
            self.i_ptr += 2;
        }

        true
    }
}

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
enum OpCode {
    Adv,
    Bxl,
    Bst,
    Jnz,
    Bxc,
    Out,
    Bdv,
    Cdv,
}

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
enum Operand {
    Literal(u8),
    RegA,
    RegB,
    RegC,
    Invalid,
}

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
enum OperatorKind {
    Combo,
    Literal,
    Ignore,
}

impl OpCode {
    fn operator_kind(self) -> OperatorKind {
        match self {
            OpCode::Adv => OperatorKind::Combo,
            OpCode::Bxl => OperatorKind::Literal,
            OpCode::Bst => OperatorKind::Combo,
            OpCode::Jnz => OperatorKind::Literal,
            OpCode::Bxc => OperatorKind::Ignore,
            OpCode::Out => OperatorKind::Combo,
            OpCode::Bdv => OperatorKind::Combo,
            OpCode::Cdv => OperatorKind::Combo,
        }
    }
    fn from_code(n: u8) -> Option<Self> {
        Some(match n {
            0 => Self::Adv,
            1 => Self::Bxl,
            2 => Self::Bst,
            3 => Self::Jnz,
            4 => Self::Bxc,
            5 => Self::Out,
            6 => Self::Bdv,
            7 => Self::Cdv,
            _ => None?,
        })
    }
    fn into_combo(self) -> Operand {
        match self {
            Self::Adv => Operand::Literal(0),
            Self::Bxl => Operand::Literal(1),
            Self::Bst => Operand::Literal(2),
            Self::Jnz => Operand::Literal(3),
            Self::Bxc => Operand::RegA,
            Self::Out => Operand::RegB,
            Self::Bdv => Operand::RegC,
            Self::Cdv => Operand::Invalid,
        }
    }
    fn into_literal(self) -> Operand {
        match self {
            Self::Adv => Operand::Literal(0),
            Self::Bxl => Operand::Literal(1),
            Self::Bst => Operand::Literal(2),
            Self::Jnz => Operand::Literal(3),
            Self::Bxc => Operand::Literal(4),
            Self::Out => Operand::Literal(5),
            Self::Bdv => Operand::Literal(6),
            Self::Cdv => Operand::Literal(7),
        }
    }
    fn to_number(self) -> u8 {
        match self {
            Self::Adv => 0,
            Self::Bxl => 1,
            Self::Bst => 2,
            Self::Jnz => 3,
            Self::Bxc => 4,
            Self::Out => 5,
            Self::Bdv => 6,
            Self::Cdv => 7,
        }
    }
}

impl Operand {
    fn as_value(self, registers: &Computer) -> u64 {
        match self {
            Operand::Literal(v) => v.into(),
            Operand::RegA => registers.a,
            Operand::RegB => registers.b,
            Operand::RegC => registers.c,
            Operand::Invalid => panic!(),
        }
    }
}

#[allow(dead_code)]
const PRACTICE_DATA: &str = "Register A: 2024
Register B: 0
Register C: 0

Program: 0,3,5,4,3,0";
