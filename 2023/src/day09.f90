submodule(aoc) aoc_day9
    use, intrinsic :: iso_fortran_env, only: iostat_end
    implicit none
contains
    subroutine day9(data, part1, part2)
        character(len=*), intent(in) :: data
        character(len=:), allocatable, intent(out) :: part1, part2
        character(256) :: line
        integer, allocatable :: oasis(:)
        integer :: numelems, totnext, totprev
        integer :: data_begin, data_end

        totnext = 0
        totprev = 0

        allocate(oasis(calc_elems(data)))

        data_end = 0
        do while (data_end < len(data))
            data_begin = data_end + 1
            data_end = data_begin + scan(data(data_begin:),new_line('')) - 1
            line = data(data_begin:data_end-1)

            read(line,*) oasis
            totnext = totnext + calc_next(oasis)
            totprev = totprev + calc_prev(oasis)
        end do

        allocate(character(len=64)::part1,part2)
        write(part1,'(i0)') totnext
        write(part2,'(i0)') totprev

    end subroutine

    recursive function calc_prev(arr) result(prev)
        integer, intent(in) :: arr(:)
        integer :: prev
        integer :: difflist(size(arr) - 1)

        difflist = diff(arr)
        if (all(difflist == 0)) then
            prev = arr(1)
        else
            prev = arr(1) - calc_prev(difflist)
        end if

    end function

    recursive function calc_next(arr) result(next)
        integer, intent(in) :: arr(:)
        integer :: next
        integer :: difflist(size(arr) - 1)

        difflist = diff(arr)
        if (all(difflist == 0)) then
            next = arr(1)
        else
            next = arr(size(arr)) + calc_next(difflist)
        end if

    end function

    function diff(arr) result(diff_)
        integer, intent(in) :: arr(:)
        integer :: diff_(size(arr) - 1), i

        do i = 1, size(arr) - 1
            diff_(i) = arr(i + 1) - arr(i)
        end do
    end function

    function calc_elems(data) result(numelems)
        character(len=*), intent(in) :: data
        integer :: numelems, i
        character(256) :: line

        line = data(:scan(data,new_line(''))-1)
        numelems = 1
        do i = 1, len_trim(line)
            if (line(i:i) == ' ') numelems = numelems + 1
        end do
    end function

end submodule
