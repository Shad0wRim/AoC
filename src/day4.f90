submodule (aoc) aoc_day4
    use, intrinsic :: iso_fortran_env, only : iostat_end
    implicit none
contains
    subroutine day4
    integer :: error, totpnts = 0, totcards = 0
    integer :: copies(500), pnts, newcopies, i
    character(256) :: filename, line

    copies = 1
    write(*,*) "input file name"
    read(*,*) filename
    if (trim(filename) .eq. 't') filename = 'test.txt'
    if (trim(filename) .eq. 'm') filename = 'day4.txt'
    open(1,file=filename,status='old',iostat=error)
    if (error .ne. 0) stop

    do i=1,500
    read(1, '(A)', iostat=error) line
    select case(error)
    case(0)
        call calc_ans(line, pnts, newcopies)
        copies(i+1:i+newcopies) = copies(i+1:i+newcopies) + copies(i)
        
        totpnts = totpnts + pnts
    case(iostat_end)
        exit
    case default
        write(*,*) "error reading file"
        stop
    end select
    end do
    close(1)
    copies(i:) = 0

    write(*,'(a,i0)') "total cards: ", sum(copies)
    write(*,'(a,i0)') "sum of points: ", totpnts
    end subroutine

    subroutine calc_ans(line, pnts, newcopies)
        character(256), intent(in) :: line
        integer, intent(out) :: pnts, newcopies
        character(256) :: skip, cardline, winline, userline
        integer :: cardnum, winsize, usersize, i, j
        integer, allocatable :: matches(:), winnums(:), usernums(:)

        cardline = line(6:scan(line, ':')-1)
        read(cardline,*) cardnum
        write(*,'(100(i3,1x))') cardnum

        winline = line(scan(line, ':')+2:scan(line, '|')-2)
        winsize = len_trim(winline) / 3 + 1
        allocate( winnums(winsize) )

        read(winline,*) winnums
        write(*,'(100(i2,1x))') winnums
        userline = line(scan(line, '|')+2:)
        usersize = len_trim(userline) / 3 + 1
        allocate( usernums(usersize) )
        read(userline,*) usernums
        write(*,'(100(i2,1x))') usernums

        allocate( matches(usersize) )
        matches = 0
        do i=1,usersize
        do j=1,winsize
        if (usernums(i) .eq. winnums(j)) matches(i) = 1
        end do
        end do
        
        newcopies = sum(matches)
        
        pnts = 2**(sum(matches) - 1)

    end subroutine
end submodule aoc_day4

