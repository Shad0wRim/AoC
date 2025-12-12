submodule(aoc) aoc_day2
    use, intrinsic :: iso_fortran_env, only: iostat_end
    implicit none
contains
    subroutine day2(data, part1, part2)
        character(len=*), intent(in) :: data
        character(len=:), allocatable, intent(out) :: part1, part2
        integer :: data_begin, data_end
        integer :: id, num, sum_ids, sum_powers, i
        integer, dimension(3) :: rgb, minrgb
        integer, parameter :: MAX_RGB(3) = [12, 13, 14]
        character(len=256) :: line, game
        character(len=5) :: color
        character(len=1) :: skip

        sum_ids = 0
        sum_powers = 0

        data_end = 0
        do while (data_end < len(data))
            data_begin = data_end + 1
            data_end = data_end + scan(data(data_begin:), new_line(''))
            line = data(data_begin:data_end-1)

            line = trim(line)//';'
            read(line(:scan(line, ':')-1),*) skip, id
            line = line(scan(line, ':')+1:)

            ! parse the line
            minrgb = 0
            do while(scan(line, ';') /= 0)
                read (line(:scan(line, ';')), '(a)') game
                ! print*, 'GAME:', trim(game)

                ! parse the game
                rgb = 0
                do while(scan(game, ',;') /= 0)
                    read(game(:scan(game, ',;')-1),*) num, color

                    select case (color)
                    case('red');   i = 1
                    case('green'); i = 2
                    case('blue');  i = 3
                    end select

                    if (num > minrgb(i)) minrgb(i) = num

                    game = game(scan(game, ',;')+1:)
                end do

                line = line(scan(line, ';')+1:)
            end do

            sum_powers = sum_powers + product(minrgb)
            if (all(minrgb <= MAX_RGB)) sum_ids = sum_ids + id
        end do

        allocate(character(len=64)::part1)
        allocate(character(len=64)::part2)
        write(part1,'(i0)') sum_ids
        write(part2,'(i0)') sum_powers
        part1 = trim(part1)
        part2 = trim(part2)
    end subroutine
end submodule aoc_day2

