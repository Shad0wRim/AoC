submodule(aoc) aoc_day9
    use, intrinsic :: iso_fortran_env, only : iostat_end
    implicit none
contains
    subroutine day9
        character(8) :: filename
        character(256) :: line
        integer :: error, numelems, totnext = 0, totprev = 0
        integer, allocatable :: oasis(:)

        write (*, *) "input file name"
        read (*, *) filename
        if (filename == 't') filename = 'test.txt'
        if (filename == 'm') filename = 'day9.txt'

        ! find number of elements per line
        numelems = calc_elems(filename)

        allocate( oasis(numelems) )

        open (1, file=filename, status='old', iostat=error)
        do
        read(1,'(a)',iostat=error) line
        select case (error)
        case(0)
            read(line,*) oasis
            print'(*(i0,x))', oasis
            totnext = totnext + calc_next(oasis)
            totprev = totprev + calc_prev(oasis)
        case(iostat_end)
            exit
        case default
            write(*,*) "error reading file"
        end select

        end do
        close (1)

        write (*, '(a,i0)') "total of next history: ", totnext
        write (*, '(a,i0)') "total of prev history: ", totprev

    end subroutine

    recursive function calc_prev(arr) result(prev)
        integer, intent(in) :: arr(:)
        integer :: prev
        integer :: difflist(size(arr)-1)

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
        integer :: difflist(size(arr)-1)

        difflist = diff(arr)
        if (all(difflist == 0)) then
            next = arr(1)
        else
            next = arr(size(arr)) + calc_next(difflist)
        end if

    end function

    function diff(arr) result(diff_)
        integer, intent(in) :: arr(:)
        integer :: diff_(size(arr)-1)
        integer :: i, delta

        do i=1,size(arr)-1
        diff_(i) = arr(i+1) - arr(i)
        end do
    end function

    function calc_elems(filename) result(numelems)
        character(8), intent(in) :: filename
        integer :: numelems, error, i
        character(256) :: line
        numelems = 1
        open(5,file=filename,status='old',iostat=error)
        if (error .ne. 0) stop

        read(5,'(a)') line
        do i=1,len_trim(line)
        if (line(i:i) == ' ') numelems = numelems + 1
        end do
        close(5)
    end function

end submodule
