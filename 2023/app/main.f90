program main
    use aoc
    implicit none
    integer :: istat, iday
    character(len=128) :: arg
    character(len=:), allocatable :: data, part1, part2

    call get_command_argument(1, arg, status=istat)
    if (istat .ne. 0) then
        write(*,*) 'Failed to parse day argument'
        error stop 1
    end if
    read(arg,*) iday

    call get_command_argument(2, arg, status=istat)
    if (istat > 0) then
        write(arg, '(a,i2.2,a)') 'res/day', iday , '.txt'
    else if (istat < 0) then
        error stop 1
    end if
    if (arg == 'practice') then
        arg = 'res/example.txt'
    end if

    call read_file(arg, data, status=istat)
    if (istat /= 0) error stop 2

    select case (iday)
    case (1)
        call day1(data, part1, part2)
    case (2)
        call day2(data, part1, part2)
    case (3)
        call day3(data, part1, part2)
    case (4)
        call day4(data, part1, part2)
    case (5)
        call day5(data, part1, part2)
    case (6)
        call day6(data, part1, part2)
    case (7)
        call day7(data, part1, part2)
    case (8)
        call day8(data, part1, part2)
    case (9)
        call day9(data, part1, part2)
    case (10)
        call day10(data, part1, part2)
    case (11)
        call day11(data, part1, part2)
    case default
        print*, 'not implemented : ', iday
        error stop 3
    end select

    write(*,'(a,i0,a)') '-----------< Day ', iday, ' >-----------'
    if (allocated(part1)) write(*,'(a)') 'Part 1: ' // trim(part1)
    if (allocated(part2)) write(*,'(a)') 'Part 2: ' // trim(part2)

contains
    subroutine read_file(filename, str, status)
        use iso_fortran_env, only: stderr => error_unit
        implicit none
        character(len=*),intent(in) :: filename
        character(len=:),allocatable,intent(out) :: str
        integer,intent(out),optional :: status

        !local variables:
        integer :: iunit,istat,filesize
        character(len=1) :: c
        if (present(status)) status = 0

        open(newunit=iunit,file=filename,status='OLD',&
            form='UNFORMATTED',access='STREAM',iostat=istat)
        if (istat /= 0) then
            write(stderr,*) 'Error opening file'
            if (present(status)) status = istat
            return
        endif

        !how many characters are in the file:
        inquire(file=filename, size=filesize)
        if (filesize < 0) then
            write(stderr,*) 'Error getting file size'
            if (present(status)) status = -1
            return
        else if (filesize == 0) then
            write(stderr,*) 'File is empty'
            if (present(status)) status = -1
            return
        endif

        !read the file all at once:
        if (allocated(str)) deallocate(str)
        allocate(character(len=filesize) :: str)
        read(iunit,pos=1,iostat=istat) str

        if (istat==0) then
            !make sure it was all read by trying to read more:
            read(iunit,pos=filesize+1,iostat=istat) c
            if (.not. is_iostat_end(istat)) then
                write(stderr,*) 'Error: file was not completely read.'
                if (present(status)) status = istat
            endif
        else
            write(stderr,*) 'Error reading file.'
            if (present(status)) status = istat
        endif

        close(iunit, iostat=istat)
    end subroutine
end program main
