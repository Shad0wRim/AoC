submodule ( aoc ) aoc_day6
    implicit none
contains
    subroutine day6
        character(256) :: filename, line
        integer, dimension(:), allocatable :: timedata, distdata, windata
        integer :: error, length, i
        integer(8) :: cattime, catdist, holdtime, dist, win
        
        write(*,*) "input file name"
        read(*,*) filename
        if (filename .eq. 't') filename = "test.txt"
        if (filename .eq. 'm') filename = "day6.txt"

        call calc_length(filename, length)
        allocate( timedata(length), distdata(length), windata(length) )
        open(1, file=filename, status='old', iostat=error)
        if (error .ne. 0) stop

        read(1,'(a)', iostat=error) line
        read(line(10:), *) timedata
        read(1,'(a)', iostat=error) line
        read(line(10:), *) distdata
        close(1)

        ! part 1
        windata = 0
        do i=1,length
        do holdtime=0,timedata(i)
        dist = (holdtime) * (timedata(i) - holdtime)
        if (dist .gt. distdata(i)) then
            windata(i) = windata(i) + 1
        end if
        end do
        end do

        ! part 2
        win = 0
        cattime = concat_array(timedata)
        catdist = concat_array(distdata)
        print*, cattime
        print*, catdist
        do holdtime=0,cattime
        dist = (holdtime) * (cattime - holdtime)
        if (dist .gt. catdist) then
            win = win + 1
        end if
        end do

        write(*,'(a,i0)') "product of ways to beat: ", product(windata)
        write(*,'(a,i0)') "ways to win final game:  ", win
        
    end subroutine

    subroutine calc_length(filename, length)
        character(256), intent(in) :: filename
        integer, intent(out) :: length
        character(256) :: line
        integer :: error, counter, i, numloc
        
        open(1, file=filename, status='old', iostat=error)
        if (error .ne. 0) stop

        read(1,'(a)', iostat=error) line

        counter = 0
        numloc = scan(line,'1234567890')
        do while (numloc .ne. 0)
        counter = counter + 1
        line(numloc:numloc+verify(line(numloc:),'1234567890')-1) = ' '
        numloc = scan(line,'1234567890')
        end do
        length = counter
        close(1)

    end subroutine

    function concat_array(arr) result(num)
        integer, intent(in) :: arr(:)
        integer(8) :: num
        integer :: i
        character(128) :: numstr
        character(32) :: tempnum

        numstr = ''
        do i=1,size(arr)
        write(tempnum,'(i0)') arr(i)
        numstr = trim(numstr)//trim(tempnum)
        print*, trim(numstr)
        end do
        
        read(numstr,*) num

    end function
end submodule
