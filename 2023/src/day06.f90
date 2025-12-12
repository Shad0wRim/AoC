submodule(aoc) aoc_day6
    implicit none
contains
    subroutine day6(data, part1, part2)
        character(len=*), intent(in) :: data
        character(len=:), allocatable, intent(out) :: part1, part2
        character(len=256) :: line
        character(len=20) :: filename
        integer, dimension(:), allocatable :: timedata, distdata, windata
        integer :: error, length, i
        integer(8) :: cattime, catdist, holdtime, dist, win

        call calc_length(data, length)
        allocate (timedata(length), distdata(length), windata(length))

        read(data(:scan(data,new_line(''))-1),'(a)') line
        read(line(10:),*) timedata
        read(data(scan(data,new_line(''))+1:),'(a)') line
        read(line(10:),*) distdata

        ! part 1
        windata = 0
        do i = 1, length
            do holdtime = 0, timedata(i)
                dist = (holdtime) * (timedata(i) - holdtime)
                if (dist > distdata(i)) windata(i) = windata(i) + 1
            end do
        end do

        ! part 2
        win = 0
        cattime = concat_array(timedata)
        catdist = concat_array(distdata)
        do holdtime = 0, cattime
            dist = (holdtime) * (cattime - holdtime)
            if (dist > catdist) win = win + 1
        end do

        allocate(character(len=64)::part1)
        allocate(character(len=64)::part2)
        write(part1,'(i0)') product(windata)
        write(part2,'(i0)') win
        part1 = trim(part1)
        part2 = trim(part2)

    end subroutine

    subroutine calc_length(data, length)
        character(len=*), intent(in) :: data
        integer, intent(out) :: length
        character(256) :: line
        integer :: numloc

        line = data(:scan(data, new_line(''))-1)
        length = 0
        numloc = scan(line, '1234567890')
        do while (numloc .ne. 0)
            length = length + 1
            line(numloc:numloc + verify(line(numloc:), '1234567890') - 1) = ' '
            numloc = scan(line, '1234567890')
        end do

    end subroutine

    function concat_array(arr) result(num)
        integer, intent(in) :: arr(:)
        integer(8) :: num
        integer :: i
        character(128) :: numstr
        character(32) :: tempnum

        numstr = ''
        do i = 1, size(arr)
            write(tempnum,'(i0)') arr(i)
            numstr = trim(numstr)//trim(tempnum)
        end do

        read(numstr,*) num
    end function
end submodule
