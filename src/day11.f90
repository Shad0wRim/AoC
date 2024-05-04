submodule(aoc) aoc_day11
    implicit none
contains
    subroutine day11
        character, allocatable :: image(:,:)
        call read_image(image)

    end subroutine

    subroutine read_image(image)
        character, allocatable, intent(out) :: image(:,:)
        character(9) :: filename
        character(256) :: line
        integer :: error, num_lines, line_sz, i

        write(*,*) "input filename"
        read(*,*) filename
        if (filename == 'm') filename = 'day11.txt'
        if (filename == 't') filename = 'test.txt'
        open(1, file=filename, status='old', iostat=error)
        if (error /= 0) stop

        num_lines = 0
        do
        read(1,'(a)', iostat=error) line
        if (error /= 0) exit
        num_lines = num_lines + 1
        end do
        line_sz = len_trim(line)
        
        if (allocated( image )) deallocate( image )
        allocate( image(line_sz, num_lines) )
        rewind(1)
        do i=1,num_lines
        read(1,'(*(a1))') image(:,i)
        end do

        close(1)
    end subroutine

    subroutine print_image(image)
        character, intent(in) :: image(:,:)

    end subroutine

    subroutine expand(image, expimage)
        character, intent(in) :: image(:,:)
        character, allocatable, intent(out) :: expimage(:,:)
    end subroutine
end submodule
