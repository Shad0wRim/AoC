submodule ( aoc ) aoc_day5
    use, intrinsic :: iso_fortran_env, only : iostat_end
    implicit none
contains
    subroutine day5
        character(256) :: filename, line
        integer :: error, minlocnum, i
        integer, dimension(3,100) :: seedtosoil, soiltofert, ferttowat, wattolight, lighttotemp, temptohum, humtoloc

        write(*,*) "input file name"
        read(*,*) filename
        if (trim(filename) .eq. 't') filename = 'test.txt'
        if (trim(filename) .eq. 'm') filename = 'day5.txt'
        open(1, file=filename, status='old', iostat=error)
        if (error .ne. 0) stop

        do i=1,100
        read(1,'(a)',iostat=error) line
        select case (error)
        case(0)

        case(iostat_end)
            exit
        case default
            write(*,*) "error reading file"
            stop
        end select
        end do

        write(*,'(a,i0)') "lowest location number: ", minlocnum
        close(1)
    end subroutine
end submodule aoc_day5

