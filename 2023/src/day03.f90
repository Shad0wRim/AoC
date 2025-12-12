submodule(aoc) aoc_day3
    use, intrinsic :: iso_fortran_env, only: iostat_end
    implicit none
contains
    subroutine day3(data, part1, part2)
        character(len=*), intent(in) :: data
        character(len=:), allocatable, intent(out) :: part1, part2
        character, allocatable :: schematic(:, :)
        character(256) :: line, prevline, nextline, format
        character(3) :: gearline
        integer :: numstart, numend, gearloc, totalgear_rat = 0, total = 0
        integer :: num_lines, line_size, addnum, ratio, partnums(20), numadj, i
        logical :: is_valid

        call calc_schematic_size(data, num_lines, line_size)
        allocate(schematic(num_lines+2, line_size+2))
        call fill_schematic(data, schematic)
        where (scan(schematic, '01234567890.*') == 0) schematic = '-'
        ! call print_schematic(schematic)

        write(line,'(i0)') line_size + 2
        format = '('//trim(line)//'a1)'

        ! part 1
        do i = 2, num_lines+1
            write(line,format) schematic(:, i)
            numstart = scan(line, '0123456789')
            if (numstart == 0) cycle
            numend = verify(line(numstart:), '0123456789') + numstart - 2

            do while (numstart .ne. 0)
                is_valid = scan(line(numstart-1:numstart-1), '-*') /= 0
                is_valid = is_valid .or. scan(line(numend+1:numend+1), '-*') /= 0
                is_valid = is_valid .or. any(scan(schematic(numstart-1:numend+1, i-1), '-*') /= 0)
                is_valid = is_valid .or. any(scan(schematic(numstart-1:numend+1, i+1), '-*') /= 0)

                if (is_valid) then
                    read(line(numstart:numend),*) addnum
                    total = total + addnum
                end if

                numstart = scan(line(numend+1:), '0123456789') + numend
                if (numstart == numend) exit
                numend = verify(line(numstart:), '0123456789') + numstart - 2
            end do
        end do

        ! part 2
        do i = 2, num_lines
            write(line,format) schematic(:, i)
            write(prevline,format) schematic(:, i - 1)
            write(nextline,format) schematic(:, i + 1)

            do while (scan(line, '*') .ne. 0)
                gearloc = scan(line, '*')
                numadj = 0
                if (gearloc .eq. 0) cycle
                if (scan(line(gearloc - 1:gearloc - 1), '0123456789') .ne. 0) then
                    numadj = numadj + 1
                    numend = gearloc - 1
                    numstart = verify(line(:gearloc - 1), '0123456789', back=.true.) + 1
                    read (line(numstart:numend), *) partnums(numadj)
                end if
                if (scan(line(gearloc + 1:gearloc + 1), '0123456789') .ne. 0) then
                    numadj = numadj + 1
                    numstart = gearloc + 1
                    numend = verify(line(gearloc + 1:), '0123456789') + numstart - 2
                    read (line(numstart:numend), *) partnums(numadj)
                end if

                gearline = prevline(gearloc - 1:gearloc + 1)
                if (verify(gearline, '0123456789') .eq. 0) then
                    numadj = numadj + 1
                    numstart = gearloc - 1
                    numend = gearloc + 1
                    read (prevline(numstart:numend), *) partnums(numadj)
                end if
                if (scan(gearline, '0123456789', back=.true.) .eq. 1) then
                    numadj = numadj + 1
                    numend = gearloc - 1
                    numstart = verify(prevline(:gearloc - 1), '0123456789', back=.true.) + 1
                    read (prevline(numstart:numend), *) partnums(numadj)
                end if
                if (scan(gearline, '0123456789') .eq. 1 .and. &
                    scan(gearline, '0123456789', back=.true.) .eq. 2) then
                    numadj = numadj + 1
                    numend = gearloc
                    numstart = verify(prevline(:gearloc), '0123456789', back=.true.) + 1
                    read (prevline(numstart:numend), *) partnums(numadj)
                end if
                if (scan(gearline, '0123456789') .eq. 2) then
                    numadj = numadj + 1
                    numstart = gearloc
                    numend = verify(prevline(numstart:), '0123456789') + numstart - 2
                    read (prevline(numstart:numend), *) partnums(numadj)
                end if
                if (scan(gearline, '0123456789') .eq. 3) then
                    numadj = numadj + 1
                    numstart = gearloc + 1
                    numend = verify(prevline(numstart:), '0123456789') + numstart - 2
                    read (prevline(numstart:numend), *) partnums(numadj)
                end if
                if (scan(gearline, '0123456789') .eq. 1 .and. &
                    scan(gearline, '0123456789', back=.true.) .eq. 3 .and. &
                    scan(gearline(2:2), '0123456789') .eq. 0) then
                    numadj = numadj + 2
                    numstart = gearloc + 1
                    numend = verify(prevline(numstart:), '0123456789') + numstart - 2
                    read (prevline(numstart:numend), *) partnums(numadj)
                    numend = gearloc - 1
                    numstart = verify(prevline(:numend), '0123456789', back=.true.) + 1
                    read (prevline(numstart:numend), *) partnums(numadj - 1)
                end if

                gearline = nextline(gearloc - 1:gearloc + 1)
                if (verify(gearline, '0123456789') .eq. 0) then
                    numadj = numadj + 1
                    numstart = gearloc - 1
                    numend = gearloc + 1
                    read (nextline(numstart:numend), *) partnums(numadj)
                end if
                if (scan(gearline, '0123456789', back=.true.) .eq. 1) then
                    numadj = numadj + 1
                    numend = gearloc - 1
                    numstart = verify(nextline(:gearloc - 1), '0123456789', back=.true.) + 1
                    read (nextline(numstart:numend), *) partnums(numadj)
                end if
                if (scan(gearline, '0123456789') .eq. 1 .and. &
                    scan(gearline, '0123456789', back=.true.) .eq. 2) then
                    numadj = numadj + 1
                    numend = gearloc
                    numstart = verify(nextline(:gearloc), '0123456789', back=.true.) + 1
                    read (nextline(numstart:numend), *) partnums(numadj)
                end if
                if (scan(gearline, '0123456789') .eq. 2) then
                    numadj = numadj + 1
                    numstart = gearloc
                    numend = verify(nextline(numstart:), '0123456789') + numstart - 2
                    read (nextline(numstart:numend), *) partnums(numadj)
                end if
                if (scan(gearline, '0123456789') .eq. 3) then
                    numadj = numadj + 1
                    numstart = gearloc + 1
                    numend = verify(nextline(numstart:), '0123456789') + numstart - 2
                    read (nextline(numstart:numend), *) partnums(numadj)
                end if
                if (scan(gearline, '0123456789') .eq. 1 .and. &
                    scan(gearline, '0123456789', back=.true.) .eq. 3 .and. &
                    scan(gearline(2:2), '0123456789') .eq. 0) then
                    numadj = numadj + 2
                    numstart = gearloc + 1
                    numend = verify(nextline(numstart:), '0123456789') + numstart - 2
                    read (nextline(numstart:numend), *) partnums(numadj)
                    numend = gearloc - 1
                    numstart = verify(nextline(:numend), '0123456789', back=.true.) + 1
                    read (nextline(numstart:numend), *) partnums(numadj - 1)
                end if

                if (numadj .eq. 2) then
                    ! print*, trim(prevline)
                    ! print*, trim(line)
                    ! print*, trim(nextline)
                    ! print*, partnums(1), partnums(2)
                    ratio = partnums(1) * partnums(2)
                    totalgear_rat = totalgear_rat + ratio
                end if
                line(gearloc:gearloc) = '.'
            end do
        end do

        allocate(character(len=64)::part1)
        allocate(character(len=64)::part2)
        write(part1,'(i0)') total
        write(part2,'(i0)') totalgear_rat
        part1 = trim(part1)
        part2 = trim(part2)
    end subroutine

    subroutine print_schematic(array)
        character, intent(in) :: array(:, :)
        character(10) :: format, arrszstr
        integer :: i, j, arrsize

        write(arrszstr,'(i0)') size(array, dim=1)
        format = '('//trim(arrszstr)//'a1)'

        write(*,format) array
    end subroutine

    subroutine calc_schematic_size(data, num_lines, line_size)
        character(len=*), intent(in) :: data
        integer, intent(out) :: num_lines, line_size
        integer :: start

        start = 1
        line_size = index(data, new_line('')) - 1
        num_lines = 0
        do while (index(data(start:), new_line('')) /= 0)
            num_lines = num_lines + 1
            start = start + line_size + 2
        end do

    end subroutine

    subroutine fill_schematic(data, array)
        use, intrinsic :: iso_fortran_env, only: iostat_end
        character(len=*), intent(in) :: data
        character, intent(inout) :: array(:, :)
        character(len=256) :: blanks = repeat('.',256)
        integer :: data_begin, data_end, i
        integer :: line_size, num_lines

        line_size = size(array, dim=2)
        num_lines = size(array, dim=1)
        read(blanks,'(256a1)') array(:,1)
        read(blanks,'(256a1)') array(1,:)
        read(blanks,'(256a1)') array(:, num_lines)
        read(blanks,'(256a1)') array(line_size,:)
        data_end = 0
        do i = 2, num_lines - 1
            data_begin = data_end+1
            data_end = data_begin + line_size - 2
            read(data(data_begin:data_end-1),'(256a1)') array(2:line_size-1, i)
        end do

    end subroutine
end submodule aoc_day3

