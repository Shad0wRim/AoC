submodule(aoc) aoc_day
    use, intrinsic :: iso_fortran_env, only: iostat_end
    implicit none
    type crawler
        integer :: dist = 0, camefrom = 0
        integer :: loc(2), bounds(2)
    contains
        procedure :: up, down, left, right
        procedure :: val, numval
    end type

contains
    subroutine day10(data, part1, part2)
        character(len=*), intent(in) :: data
        character(len=:), allocatable, intent(out) :: part1, part2
        character, allocatable :: field(:, :)
        integer, allocatable :: distfield(:, :), infield(:, :)
        integer :: maxdist, numholes, enclosed

        call fill_field(data, field)

        call traverse_pipe(field, distfield)
        maxdist = maxval(distfield)
        where (field == 'S') distfield = 0
        where (distfield == 0 .and. field /= 'S') field = '.'

        ! block
        !     character(10) :: format, sz_str
        !     write(sz_str,'(i0)') size(field, dim=1)
        !     format = '('//trim(sz_str)//'a1)'
        !     print format, field
        !     print *
        ! end block

        ! block
        !     character(10) :: format, sz_str
        !     write(sz_str,'(i0)') size(field, dim=1)
        !     format = '('//trim(sz_str)//'i3)'
        !     print format, distfield
        !     print *
        ! end block

        call even_odd(field, distfield, infield)
        enclosed = sum(infield, mask=infield > 0)

        ! block
        !     character(10) :: format, sz_str
        !     write(sz_str,'(i0)') size(field, dim=1)
        !     format = '('//trim(sz_str)//'i3)'
        !     print format, infield
        ! end block

        allocate(character(len=64)::part1,part2)
        write(part1,'(i0)') maxdist
        write(part2,'(i0)') enclosed

    end subroutine

    subroutine even_odd(field, distfield, infield)
        character, intent(in) :: field(:, :)
        integer, allocatable, intent(out) :: infield(:, :)
        integer, intent(in) :: distfield(:, :)
        integer :: tmpdist(size(distfield, 1), size(distfield, 2))
        integer :: i, j, k, counter
        if (allocated(infield)) deallocate (infield)
        allocate (infield(size(field, 1), size(field, 2)))
        tmpdist = distfield
        where (tmpdist /= 0) tmpdist = tmpdist + 1
        where (field == 'S') tmpdist = 1
        ! printdist: block
        !     character(10) :: format, sz_str
        !     write (sz_str, '(i0)') size(field, dim=1)
        !     format = '('//trim(sz_str)//'i3)'
        !     print format, tmpdist
        ! end block printdist

        do j = 1, size(field, 2)
            counter = 0
            do i = 1, size(field, 1)
                if (i == 1) then
                    if (tmpdist(i, j) /= 0) counter = counter + 1
                else
                    if (tmpdist(i, j) == 0) cycle
                    if (abs(tmpdist(i, j) - tmpdist(i - 1, j)) > 1) then
                        counter = counter + 1
                    end if
                end if
                if (any(['S', '|', '-', 'F', 'J', '7', 'L'] == field(i, j))) then
                    infield(i, j) = 0
                else
                    infield(i, j) = mod(counter, 2)
                end if
            end do
        end do
    end subroutine

    subroutine traverse_pipe(field, distfield)
        character, target, intent(in) :: field(:, :)
        integer, allocatable, target, intent(out) :: distfield(:, :)
        type(crawler) :: crwlr(2)
        character :: next
        integer :: error
        logical :: isvalid(4)
        integer :: i
        allocate (distfield(size(field, 1), size(field, 2)))
        distfield = 0
        crwlr(1)%bounds = shape(field)
        crwlr(2)%bounds = shape(field)
        crwlr(1)%loc = findloc(field, 'S')
        crwlr(2)%loc = findloc(field, 'S')
        ! .1.
        ! 2S3
        ! .4.

        ! find the connections to the start
        isvalid = .false.
        do i = 1, 4
        select case (i)
        case (1)
            error = crwlr(1)%up()
            if (error /= 0) cycle
            next = crwlr(1)%val(field)
            if (scan(next, 'F7|') /= 0) isvalid(i) = .true.
        case (2)
            error = crwlr(1)%left()
            if (error /= 0) cycle
            next = crwlr(1)%val(field)
            if (scan(next, 'FL-') /= 0) isvalid(i) = .true.
        case (3)
            error = crwlr(1)%right()
            if (error /= 0) cycle
            next = crwlr(1)%val(field)
            if (scan(next, '7J-') /= 0) isvalid(i) = .true.
        case (4)
            error = crwlr(1)%down()
            if (error /= 0) cycle
            next = crwlr(1)%val(field)
            if (scan(next, 'LJ|') /= 0) isvalid(i) = .true.
        end select
        ! print'(i0,x,a,x,l)', i, next, isvalid(i)
        crwlr(1)%loc = findloc(field, 'S')
        end do

        ! crawl
        select case (findloc(isvalid, .true., dim=1))
        case (1)
            error = crwlr(1)%up()
        case (2)
            error = crwlr(1)%left()
        case (3)
            error = crwlr(1)%right()
        case default
            write (*, *) "failed crawl"
            write (*, *) crwlr(1)%val(field)
        end select
        select case (findloc(isvalid, .true., dim=1, back=.true.))
        case (2)
            error = crwlr(2)%left()
        case (3)
            error = crwlr(2)%right()
        case (4)
            error = crwlr(2)%down()
        case default
            write (*, *) "failed crawl"
            write (*, *) crwlr(2)%val(field)
        end select
        do i = 1, 2
        crwlr(i)%dist = crwlr(i)%dist + 1
        distfield(crwlr(i)%loc(1), crwlr(i)%loc(2)) = crwlr(i)%dist
        end do

        crawl: do
            do i = 1, 2
            select case (crwlr(i)%camefrom)
            case (1)
                select case (crwlr(i)%val(field))
                case ('|')
                    error = crwlr(i)%down()
                case ('L')
                    error = crwlr(i)%right()
                case ('J')
                    error = crwlr(i)%left()
                case default
                    write (*, *) "failed crawl"
                    write (*, *) crwlr(i)%val(field)
                end select
            case (2)
                select case (crwlr(i)%val(field))
                case ('-')
                    error = crwlr(i)%right()
                case ('J')
                    error = crwlr(i)%up()
                case ('7')
                    error = crwlr(i)%down()
                case default
                    write (*, *) "failed crawl"
                    write (*, *) crwlr(i)%val(field)
                end select
            case (3)
                select case (crwlr(i)%val(field))
                case ('-')
                    error = crwlr(i)%left()
                case ('L')
                    error = crwlr(i)%up()
                case ('F')
                    error = crwlr(i)%down()
                case default
                    write (*, *) "failed crawl"
                    write (*, *) crwlr(i)%val(field)
                end select
            case (4)
                select case (crwlr(i)%val(field))
                case ('|')
                    error = crwlr(i)%up()
                case ('7')
                    error = crwlr(i)%left()
                case ('F')
                    error = crwlr(i)%right()
                case default
                    write (*, *) "failed crawl"
                    write (*, *) crwlr(i)%val(field)
                end select
            case default
                write (*, *) "failed crawl"
                write (*, *) crwlr(i)%val(field)
            end select

            if (error /= 0) then
                write (*, *) "failed crawl"
                write (*, *) crwlr(i)%val(field)
            else
                crwlr(i)%dist = crwlr(i)%dist + 1
                if (crwlr(i)%numval(distfield) /= 0) then
                    ! print *, "exiting crawl"
                    exit crawl
                end if
                distfield(crwlr(i)%loc(1), crwlr(i)%loc(2)) = crwlr(i)%dist
            end if
            end do
        end do crawl
    end subroutine

    subroutine fill_field(data, field)
        character(len=*), intent(in) :: data
        character, allocatable, intent(out) :: field(:, :)
        character(256) :: line
        integer :: num_lines, line_sz, i
        integer :: data_begin, data_end

        num_lines = 0
        line = data(:scan(data,new_line(''))-1)
        num_lines = len(data) / (len_trim(line)+1)
        line_sz = len_trim(line)

        allocate (field(line_sz, num_lines))

        data_end = 0
        do i = 1, num_lines
            data_begin = (i-1) * (line_sz+1) + 1
            data_end = data_begin + line_sz - 1
            read(data(data_begin:data_end),'(*(a1))') field(:, i)
        end do

    end subroutine

    function val(self, arr) result(res)
        class(crawler), intent(in) :: self
        character, intent(in) :: arr(:, :)
        character :: res

        if (any(self%loc < 1) .or. self%loc(1) > size(arr, 1) .or. self%loc(2) > size(arr, 2)) then
            res = 'X'
        else
            res = arr(self%loc(1), self%loc(2))
        end if
    end function
    function numval(self, arr) result(res)
        class(crawler), intent(in) :: self
        integer :: arr(:, :)
        integer :: res

        if (any(self%loc < 1) .or. self%loc(1) > size(arr, 1) .or. self%loc(2) > size(arr, 2)) then
            res = -1
        else
            res = arr(self%loc(1), self%loc(2))
        end if
    end function
    function right(self) result(res)
        class(crawler), intent(inout) :: self
        integer :: res
        if (self%loc(1) >= self%bounds(1)) then
            self%camefrom = 0
            res = 1
        else
            self%loc(1) = self%loc(1) + 1
            self%camefrom = 2
            res = 0
        end if
    end function
    function left(self) result(res)
        class(crawler), intent(inout) :: self
        integer :: res
        if (self%loc(1) <= 1) then
            self%camefrom = 0
            res = 1
        else
            self%camefrom = 3
            self%loc(1) = self%loc(1) - 1
            res = 0
        end if
    end function
    function down(self) result(res)
        class(crawler), intent(inout) :: self
        integer :: res
        if (self%loc(2) >= self%bounds(2)) then
            self%camefrom = 0
            res = 1
        else
            self%camefrom = 1
            self%loc(2) = self%loc(2) + 1
            res = 0
        end if
    end function
    function up(self) result(res)
    class(crawler), intent(inout) :: self
    integer :: res
    if (self%loc(2) <= 1) then
        self%camefrom = 0
        res = 1
    else
        self%camefrom = 4
        self%loc(2) = self%loc(2) - 1
        res = 0
    end if
end function

end submodule
