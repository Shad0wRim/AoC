# AoC
My advent of code projects

## Languages
| Year | Language |
| :--: | :------: |
| 2023 | Fortran  |
| 2024 | Rust     |
| 2025 | Julia    |

## Future Languages
Planning to write future and previous years in the following languages, one
language per year

### For sure
- C
- C++
- Typst (lol)
- Python 
- Bash
- Zig

### Tentative
- Nushell
- Roc
- Steel (Lisp)
- Perl
- Lua
- OCaml
- Haskell
- Gleam
- Go
- Octave/MATLAB

## Running
### General
All code reads from files in a `res/` directory in the corresponding year
folder. The data files have the format `day%02d.txt`, the number has length 2
and is 0 padded.
```
day01.txt
day02.txt
...
```

### 2023
The 2023 Fortran code uses the Fortran package manager (fpm) and GNU Fortran
(gfortran) to build and run the code. Install both programs and run the 
project using:
```bash
fpm run -- 1 # enter the day number
```
To not use fpm, run the following commands
```bash
gfortran -c src/days.f90 
gfortran -c src/*
gfortran -c app/main.f90
gfortran *.o -o main
./main 1 # enter the day number
```
To clean the directory of all compilation artifacts, run
```bash
rm *.*mod *.o
```

### 2024
The 2024 Rust code uses cargo as the build system. Run the project using:
```bash
cargo run -- 1 # enter the day number
```

### 2025
The 2025 Julia code has a `main.jl` script to run the program. Run the project
using:
```bash
./main.jl 1 # enter the day number
```

