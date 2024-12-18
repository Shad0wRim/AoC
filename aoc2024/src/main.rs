mod days;
use days::*;

const INTERACTIVE: bool = false;
const DAY: u32 = 15;

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

    let data_path = format!("res/day{:02}.txt", day);
    if !std::fs::exists(&data_path).unwrap_or(false) {
        println!("fetching puzzle data");
        let input = get_aoc_input(day).unwrap();
        std::fs::write(&data_path, &input).unwrap();
    }
    let data = std::fs::read_to_string(&data_path).unwrap();

    let (part1, part2) = match day {
        1 => day1(data),
        2 => day2(data),
        3 => day3(data),
        4 => day4(data),
        5 => day5(data),
        6 => day6(data),
        7 => day7(data),
        8 => day8(data),
        9 => day9(data),
        10 => day10(data),
        11 => day11(data),
        12 => day12(data),
        13 => day13(data),
        14 => day14(data),
        15 => day15(data),
        16 => day16(data),
        17 => day17(data),
        18 => day18(data),
        19 => day19(data),
        20 => day20(data),
        21 => day21(data),
        22 => day22(data),
        23 => day23(data),
        24 => day24(data),
        25 => day25(data),
        _ => panic!(),
    };
    println!("Day {day}:");
    println!("Part 1: {part1}");
    println!("Part 2: {part2}");
}

fn get_aoc_input(day: u32) -> Result<String, &'static str> {
    use reqwest::{
        blocking::Client,
        header::{HeaderMap, HeaderValue, CONTENT_TYPE, COOKIE},
        redirect::Policy,
    };
    let cookie = std::env!("AOC_TOKEN");
    let cookie_header = HeaderValue::from_str(&format!("session={}", cookie.trim()))
        .map_err(|_| "invalid session cookie")?;
    let content_header = HeaderValue::from_str("text/plain").map_err(|_| "invalid content type")?;

    let mut headers = HeaderMap::new();
    headers.insert(COOKIE, cookie_header);
    headers.insert(CONTENT_TYPE, content_header);

    let client = Client::builder()
        .default_headers(headers)
        .redirect(Policy::none())
        .build()
        .map_err(|_| "failed to build client")?;

    let url = format!("https://adventofcode.com/2024/day/{}/input", day);
    client
        .get(url)
        .send()
        .and_then(|response| response.error_for_status())
        .and_then(|response| response.text())
        .map_err(|_| "failed to receive response")
}
