#[allow(dead_code)]
const TEST_DATA: &str = "2333133121414131402";

pub fn day9() {
    let data: Vec<_> = std::fs::read("res/day09.txt")
        .unwrap()
        .into_iter()
        .map(|b| (b.wrapping_sub(b'0')))
        .filter(|b| (0..=9).contains(b))
        .collect();
    //let data: Vec<_> = TEST_DATA.bytes().map(|b| (b.wrapping_sub(b'0'))).collect();

    let mut disk = vec![];
    for pair in data.chunks(2).enumerate() {
        match pair {
            (i, &[file, free]) => {
                (0..file).for_each(|_| disk.push(Some(i)));
                (0..free).for_each(|_| disk.push(None));
            }
            (i, &[file]) => (0..file).for_each(|_| disk.push(Some(i))),
            _ => (),
        }
    }

    let checksum = {
        let mut disk = disk.clone();
        let mut end_idx = disk.len() - 1;
        for i in 0..disk.len() {
            match (disk[i], i < end_idx) {
                (None, true) => {
                    while disk[end_idx].is_none() {
                        end_idx -= 1;
                    }
                    (disk[i], disk[end_idx]) = (disk[end_idx], disk[i]);
                }
                (Some(_), true) => (),
                (_, false) => break,
            }
        }
        disk.iter()
            .filter_map(|id| *id)
            .enumerate()
            .map(|(i, id)| i * id)
            .sum::<usize>()
    };
    println!("Part 1: {checksum}");

    let checksum = {
        let mut skip_idxs = vec![];
        for chunk_end in (0..disk.len()).rev() {
            if skip_idxs.contains(&chunk_end) {
                continue;
            };
            let Some(id) = disk[chunk_end] else {
                continue;
            };

            let mut chunk_start = chunk_end;
            while chunk_start as isize > 0 && disk[chunk_start - 1] == Some(id) {
                chunk_start -= 1;
            }
            let chunk_len = chunk_end - chunk_start + 1;
            skip_idxs.clear();
            skip_idxs.extend(chunk_start..=chunk_end);

            let mut free_start = 0;
            while free_start < chunk_start {
                while disk[free_start].is_some() {
                    free_start += 1;
                }

                let mut free_end = free_start;
                while disk[free_end + 1].is_none() {
                    free_end += 1;
                }
                if free_start >= chunk_start {
                    break;
                }

                let free_len = free_end - free_start + 1;
                if free_len >= chunk_len {
                    for j in 0..chunk_len {
                        disk[free_start + j] = disk[chunk_start + j];
                        disk[chunk_start + j] = None;
                    }
                    break;
                } else {
                    free_start = free_end + 1;
                    continue;
                }
            }
        }
        disk.iter()
            .enumerate()
            .filter_map(|(i, &id)| Some((i, id?)))
            .map(|(i, id)| i * id)
            .sum::<usize>()
    };

    println!("Part 2: {checksum}");
}
