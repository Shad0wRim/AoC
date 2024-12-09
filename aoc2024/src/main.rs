mod days;
use days::*;

const INTERACTIVE: bool = false;
const DAY: i32 = 9;

fn main() {
    println!("Advent of Code 2024");

    let day = if INTERACTIVE {
        let mut buf = String::new();
        print!("Input day to run: ");
        std::io::stdin().read_line(&mut buf).unwrap();
        buf.trim_end().parse().unwrap_or(DAY)
    } else {
        DAY
    };

    println!("Day {day}:");
    match day {
        1 => day1(),
        2 => day2(),
        3 => day3(),
        4 => day4(),
        5 => day5(),
        6 => day6(),
        7 => day7(),
        8 => day8(),
        9 => day9(),
        10 => day10(),
        11 => day11(),
        12 => day12(),
        13 => day13(),
        14 => day14(),
        15 => day15(),
        16 => day16(),
        17 => day17(),
        18 => day18(),
        19 => day19(),
        20 => day20(),
        21 => day21(),
        22 => day22(),
        23 => day23(),
        24 => day24(),
        _ => panic!(),
    }
}
