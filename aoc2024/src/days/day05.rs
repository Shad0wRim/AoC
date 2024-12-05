pub fn day5() {
    let data = std::fs::read_to_string("res/day05.txt").unwrap();

    let mut rules: Vec<OrderingRule> = vec![];
    let mut lines = data.lines();
    while let Some(rule) = lines.next().and_then(|line| line.parse().ok()) {
        rules.push(rule);
    }

    let mut total_1 = 0;
    let mut total_2 = 0;
    for line in lines {
        let mut page_nums: Vec<u32> = line.split(',').map(|n| n.parse().unwrap()).collect();
        if validate(&page_nums, &rules) {
            total_1 += page_nums[page_nums.len() / 2];
        } else {
            reorder(&mut page_nums, &rules);
            total_2 += page_nums[page_nums.len() / 2];
        }
    }

    println!("Part 1: {total_1}");
    println!("Part 2: {total_2}");
}

fn validate(nums: &[u32], rules: &[OrderingRule]) -> bool {
    let mut valid = true;
    for i in 0..nums.len() {
        let spl = nums.split_at(i);
        valid = match spl {
            ([], [before, right @ ..]) => right
                .iter()
                .all(|after| rules.iter().any(|rule| rule.matches_rule(*before, *after))),

            (left, [after]) => left
                .iter()
                .all(|before| rules.iter().any(|rule| rule.matches_rule(*before, *after))),

            (left, [curr, right @ ..]) => {
                left.iter()
                    .all(|before| rules.iter().any(|rule| rule.matches_rule(*before, *curr)))
                    && right
                        .iter()
                        .all(|after| rules.iter().any(|rule| rule.matches_rule(*curr, *after)))
            }
            _ => unreachable!(),
        };
        if !valid {
            break;
        }
    }
    valid
}

fn reorder(nums: &mut [u32], rules: &[OrderingRule]) {
    nums.sort_by(|l, r| {
        for rule in rules {
            if rule.matches_rule(*l, *r) {
                return std::cmp::Ordering::Less;
            } else if rule.matches_rule(*r, *l) {
                return std::cmp::Ordering::Greater;
            }
        }
        std::cmp::Ordering::Equal
    });
    assert!(validate(nums, rules));
}

struct OrderingRule {
    before: u32,
    after: u32,
}

impl OrderingRule {
    fn matches_rule(&self, before: u32, after: u32) -> bool {
        self.before == before && self.after == after
    }
}

impl std::str::FromStr for OrderingRule {
    type Err = ();
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let (b, l) = s.split_once('|').ok_or(())?;
        Ok(OrderingRule {
            before: b.parse().map_err(|_| ())?,
            after: l.parse().map_err(|_| ())?,
        })
    }
}
