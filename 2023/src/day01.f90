submodule(aoc) aoc_day1
    use, intrinsic :: iso_fortran_env, only: iostat_end
    implicit none
contains
    subroutine day1(data, part1, part2)
        character(len=*), intent(in) :: data
        character(len=:), allocatable, intent(out) :: part1, part2
        character(len=:), allocatable :: line
        integer :: istat, first_num, last_num, combined_num, ipart1, ipart2
        integer :: ldx, rdx, ldv, rdv, lwx, rwx, lwv, rwv
        integer :: data_begin, data_end
        integer :: i
        ipart1 = 0
        ipart2 = 0
        data_end = 0

        do while (data_end < len(data))
            data_begin = data_end + 1
            data_end = data_end + scan(data(data_begin:), new_line(''))
            line = data(data_begin:data_end-1)

            ldx = scan(line, '123456789')
            if (ldx /= 0) read(line(ldx:ldx),*) ldv
            rdx = scan(line, '123456789', back=.true.)
            if (rdx /= 0) read(line(rdx:rdx),*) rdv
            call find_number_word(line, lwx, rwx, lwv, rwv)

            if (ldx /= 0 .and. ldx < lwx) then
                first_num = ldv
            else
                first_num = lwv
            end if

            if (rdx > rwx) then
                last_num = rdv
            else
                last_num = rwv
            end if

            ipart1 = ipart1 + concat_ints(ldv, rdv)
            ipart2 = ipart2 + concat_ints(first_num, last_num)
        end do

        allocate(character(len=64)::part1)
        allocate(character(len=64)::part2)
        write(part1,'(i0)') ipart1
        write(part2,'(i0)') ipart2
        part1 = trim(part1)
        part2 = trim(part2)
    end subroutine

    subroutine find_number_word(str, lx, rx, lnum, rnum)
        character(len=*), intent(in) :: str
        integer, intent(out) :: lx, rx, lnum, rnum
        integer :: lidx(9), ridx(9), i, lnuma(1), rnuma(1)
        character(5), parameter :: numbers(9) = &
            ['one  ', 'two  ', 'three', 'four ', 'five ', 'six  ', 'seven', 'eight', 'nine ']
        do i = 1, 9
            lidx(i) = index(str, trim(numbers(i)))
            ridx(i) = index(str, trim(numbers(i)), back=.true.)
        end do

        lx = minval(lidx, mask=lidx .gt. 0)
        rx = maxval(ridx)
        lnuma = minloc(lidx, mask=lidx .gt. 0)
        rnuma = maxloc(ridx)
        lnum = lnuma(1)
        rnum = rnuma(1)

    end subroutine

    function concat_ints(num1, num2) result(output_num)
        integer, intent(in) :: num1, num2
        character(99) :: char1, char2, output_string
        integer :: output_num

        write(char1,*) num1
        write(char2,*) num2
        output_string = trim(adjustl(char1))//trim(adjustl(char2))
        read(output_string,*) output_num
    end function
end submodule
