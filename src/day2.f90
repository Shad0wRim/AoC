submodule ( aoc ) aoc_day2
    use, intrinsic :: iso_fortran_env, only : iostat_end
    implicit none
contains
    subroutine day2
    integer, parameter :: NUM_RED = 12, NUM_GREEN = 13, NUM_BLUE = 14, MAX_GAMES = 15, MAX_COLORS = 3
    integer :: error, id, num, red, green, blue, min_red, min_green, min_blue, sum_ids=0, power, sum_powers = 0, i, j
    character(200) :: line, filename, game
    character(5) :: color
    character(1) :: skip
    logical :: is_possible

    write(*,*) "input file name"
    read(*, *) filename
    if (trim(filename) .eq. 't') filename = 'test.txt'
    if (trim(filename) .eq. 'm') filename = 'day2.txt'
    open(unit=1,file=filename,status='old',iostat=error)
    if (error .ne. 0) stop

    do
    read(1, '(A)', iostat=error) line

    select case(error)
    case(0)
        line = trim(line)//';'
        read(line(:scan(line,':')-1), *) skip, id 

        line = line(scan(line,':')+1:)
        write(*,*) 'LINE:', trim(line)

        ! parse the line
        is_possible = .true.
        min_red = 0
        min_green = 0
        min_blue = 0
        do j=1,MAX_GAMES
            if (scan(line,';') .eq. 0) exit
            read(line(:scan(line,';')), '(A)') game
            write(*,*) 'GAME: ', trim(game)

            ! parse the game
            red = 0
            green = 0
            blue = 0
            do i=1,MAX_COLORS
                if (scan(game,',;') .eq. 0) exit
                read(game(:scan(game,',;')), *) num, color
                write(*,*) num, color
                game = game(scan(game,',;')+1:)

                select case (color)
                case('red')
                    red = num
                    if (red .gt. min_red) min_red = red
                case('green')
                    green = num
                    if (green .gt. min_green) min_green = green
                case('blue')
                    blue = num
                    if (blue .gt. min_blue) min_blue = blue
                end select

                write(*,*) red, green, blue
                write(*,*) min_red, min_green, min_blue
            end do
            
            ! check for min vals

            ! check for valid game
            if (red .gt. NUM_RED .or. blue .gt. NUM_BLUE .or. green .gt. NUM_GREEN) then
                is_possible = .false.
                !exit
            end if

            line = line(scan(line,';')+1:)

        end do

        power = min_red * min_green * min_blue
        sum_powers = sum_powers + power
        if (is_possible) sum_ids = sum_ids + id

        write(*,*) min_red, min_green, min_blue
        write(*,*) "power", power
        write(*,*)

    case(iostat_end)
        exit
    case default
        write(*, *) "error reading file"
        stop
    end select
    end do
    close(unit=1)

    write(*,'(A,i0)') "sum of powers:    ", sum_powers
    write(*,'(A,i0)') "sum of valid ids: ", sum_ids
    end subroutine
end submodule aoc_day2

