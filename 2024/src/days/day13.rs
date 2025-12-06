pub fn day13(data: String) -> (Box<dyn std::fmt::Display>, Box<dyn std::fmt::Display>) {
    let mut data = parse_data(&data);
    let part1 = data.iter().map(play_game).sum::<i64>();

    const C: i64 = 10000000000000;
    data.iter_mut().for_each(|g| g.p = (g.p.0 + C, g.p.1 + C));
    let part2 = data.iter().map(play_game).sum::<i64>();

    (Box::new(part1), Box::new(part2))
}

struct GameData {
    a: (i64, i64),
    b: (i64, i64),
    p: (i64, i64),
}

fn play_game(data: &GameData) -> i64 {
    let &GameData { a, b, p } = data;

    match a.0 * b.1 - a.1 * b.0 {
        0 => unimplemented!(), // multiple solutions
        det => {
            // cramer's rule for one solution
            let al = b.1 * p.0 - b.0 * p.1;
            let be = a.0 * p.1 - a.1 * p.0;

            // only integer solutions
            match (al % det, be % det) {
                (0, 0) => 3 * al / det + be / det,
                (_, _) => 0,
            }
        }
    }
}

fn parse_data(data: &str) -> Vec<GameData> {
    data.split("\n\n")
        .map(|section| {
            let mut lines = section.lines();

            let [a, b, p] = [
                lines.next().unwrap(),
                lines.next().unwrap(),
                lines.next().unwrap(),
            ]
            .map(|x| {
                (
                    x.chars()
                        .skip_while(|c| !c.is_ascii_digit())
                        .take_while(char::is_ascii_digit)
                        .fold(0, |acc, c| acc * 10 + c.to_digit(10).unwrap() as i64),
                    x.chars()
                        .skip_while(|c| *c != 'Y')
                        .skip_while(|c| !c.is_ascii_digit())
                        .take_while(char::is_ascii_digit)
                        .fold(0, |acc, c| acc * 10 + c.to_digit(10).unwrap() as i64),
                )
            });

            GameData { a, b, p }
        })
        .collect()
}

#[allow(dead_code)]
const PRACTICE_DATA: &str = "Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400

Button A: X+26, Y+66
Button B: X+67, Y+21
Prize: X=12748, Y=12176

Button A: X+17, Y+86
Button B: X+84, Y+37
Prize: X=7870, Y=6450

Button A: X+69, Y+23
Button B: X+27, Y+71
Prize: X=18641, Y=10279";
