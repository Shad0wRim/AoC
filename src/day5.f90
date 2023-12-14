submodule ( aoc ) aoc_day5
    use, intrinsic :: iso_fortran_env, only : iostat_end, int64
    implicit none
     
    type map
        integer(int64) :: deststrt, srcstrt, rnglen
    end type
contains
    subroutine day5
        type(map), dimension(:), allocatable :: seedtosoil, soiltofert, ferttowat, wattolight, lighttotemp, temptohum, humtoloc
        integer(int64), dimension(:), allocatable :: seeds, transform
        type(map) :: test_map(2)
        integer(int64), allocatable :: test_list(:)
        integer(int64), allocatable :: transform_list(:)
        integer :: minlocnum, minlocnumlist, i, tmpmin
        character(6) :: test
        allocate( test_list(2) )

        print*, "test list"
        test_list = [0, 14]
        print'(2i5)', test_list
        print*, "test map"
        test_map = [map(deststrt=13, srcstrt=5, rnglen=8), map(deststrt=5, srcstrt=13, rnglen=8)]
        print'(3i5)', test_map

        call transform_seed_list(test_map, test_list)

        call populate_maps(seeds, seedtosoil, soiltofert, ferttowat, wattolight, lighttotemp, temptohum, humtoloc)
        print*, "seeds"
        print'(*(i15))', (seeds)
        print*, "SS" 
        call print_map(seedtosoil)
        print*, "SF"
        call print_map(soiltofert)
        print*, "FW"
        call print_map(ferttowat)
        print*, "WL"
        call print_map(wattolight)
        print*, "LT"
        call print_map(lighttotemp)
        print*, "TH"
        call print_map(temptohum)
        print*, "HL"
        call print_map(humtoloc)
        print*

        transform = seeds
        print*, "seeds"
        print'(*(i5))', seeds
        print*
        call transform_seeds(seedtosoil, transform)
        call transform_seeds(soiltofert, transform)
        call transform_seeds(ferttowat, transform)
        call transform_seeds(wattolight, transform)
        call transform_seeds(lighttotemp, transform)
        call transform_seeds(temptohum, transform)
        call transform_seeds(humtoloc, transform)
        minlocnum = minval(transform)

        transform_list = seeds

        print*, "list"
        print'(2(i5))', transform_list
        print*
        call transform_seed_list(seedtosoil, transform_list)
        call transform_seed_list(soiltofert, transform_list)
        call transform_seed_list(ferttowat, transform_list)
        call transform_seed_list(wattolight, transform_list)
        call transform_seed_list(lighttotemp, transform_list)
        call transform_seed_list(temptohum, transform_list)
        call transform_seed_list(humtoloc, transform_list)

        ! expand list approach, doesn't work for huge lists 
       ! print'(i0)', size(seeds)/2
       ! do i=1,size(seeds)/2
       ! call expand_seeds(seeds(i*2-1:i*2), expseeds)
       ! call transform_seeds(seedtosoil, expseeds)
       ! call transform_seeds(soiltofert, expseeds)
       ! call transform_seeds(ferttowat, expseeds)
       ! call transform_seeds(wattolight, expseeds)
       ! call transform_seeds(lighttotemp, expseeds)
       ! call transform_seeds(temptohum, expseeds)
       ! call transform_seeds(humtoloc, expseeds)
       ! tmpmin = minval(expseeds)
       ! if (i .eq. 1) minlocnumlist = tmpmin
       ! if (tmpmin .lt. minlocnumlist) minlocnumlist = tmpmin
       ! print'(i0)', i 
       ! end do
        minlocnumlist = minval(transform_list(::2))

        write(*,'(a,i0)') "lowest location number: ", minlocnum
        write(*,'(a,i0)') "lowest loc for list:    ", minlocnumlist
    end subroutine

    subroutine expand_seeds(seeds, expseeds)
        integer(int64), intent(in) :: seeds(:)
        integer(int64), allocatable, intent(out) :: expseeds(:)
        integer(int64), allocatable :: tmp(:,:), rng(:)
        integer :: il, ol, i
        allocate(expseeds(0))

        tmp = reshape(seeds,[2,size(seeds)/2])
        !write(*,*) tmp(:,1)
        
        do ol=1,size(tmp, dim=2)
        rng = [(i+tmp(1,ol) - 1, i=1,tmp(2,ol))]
        expseeds = [expseeds, rng]
        end do
    end subroutine

    subroutine transform_seeds(mapping, transform)
        type(map), intent(in) :: mapping(:)
        integer(int64), intent(inout) :: transform(:)
        integer :: i, j
        logical :: inrng

        do j=1,size(transform)
        !print'(i7)', transform(j)
        do i=1,size(mapping)
        inrng = (transform(j) .ge. mapping(i)%srcstrt)
        inrng = inrng .and. (transform(j) .le. mapping(i)%srcstrt + mapping(i)%rnglen - 1)
        if (inrng) then
            !print'(a,2(i5))', 'match', mapping(i)%srcstrt, mapping(i)%srcstrt + mapping(i)%rnglen - 1
            !print'(a,2(i5))', 'mapto', mapping(i)%deststrt, mapping(i)%deststrt + mapping(i)%rnglen - 1
            transform(j) = mapping(i)%deststrt + transform(j) - mapping(i)%srcstrt
            !print'(i4)', transform(j)
            exit
        end if
        end do
        end do
        !print'(*(i5))', transform
        !print*
    end subroutine

    subroutine transform_seed_list(mapping, transform)
        type(map), intent(in) :: mapping(:)
        integer(int64), allocatable, intent(inout) :: transform(:)
        integer(int64) :: nextval
        type(map) :: currmap
        integer :: ol, il, i, counter
        logical :: inrng, iscontained, innone

        print*, "enter"
        ol = 1
        do while (ol .lt. size(transform))
        innone = .true.
        do il=1,size(mapping)
        currmap = mapping(il)
        inrng = (transform(ol) .ge. currmap%srcstrt)
        inrng = inrng .and. (transform(ol) .le. currmap%srcstrt + currmap%rnglen - 1)

        ! in one of the maps
        if (inrng) then
            print*, "inrng"
            iscontained = transform(ol+1) .lt. currmap%rnglen - (transform(ol) - currmap%srcstrt)
            if (iscontained) then
            else
                transform(ol+1) = currmap%rnglen - (transform(ol) - currmap%srcstrt)
                if (currmap%rnglen - transform(ol+1) + 1 .gt. 0) &
                    transform = [transform, transform(ol) + transform(ol+1), currmap%rnglen - transform(ol+1) + 1]
                print'(2i5)', transform
            end if
            transform(ol) = currmap%deststrt + transform(ol) - currmap%srcstrt
            innone = .false.
            exit
        end if
        end do

        ! in none of the maps
        if (innone) then
            print*, "innone"
            nextval = minval(mapping(:)%srcstrt, mask=mapping(:)%srcstrt .gt. transform(ol))
            if (nextval - transform(ol) .lt. transform(ol+1)) then
                transform = [transform, nextval, transform(ol+1) - (nextval - transform(ol))]
                transform(ol+1) = nextval - transform(ol) 
            end if

            ! literally 1000 times slower
           ! print'(2i5)', transform
           ! do i=0,transform(ol+1)-1
           ! if (any(mapping(:)%srcstrt .eq. transform(ol) + i)) then
           !     transform = [transform, transform(ol) + i, transform(ol+1) - i]
           !     transform(ol+1) = i
           !     exit
           ! end if
           ! end do
        end if
        ol = ol + 2
        end do

        print*, "after transform"
        print'(2(i5))', transform
        print*
    end subroutine

    subroutine populate_maps(seeds, seedtosoil, soiltofert, ferttowat, wattolight, lighttotemp, temptohum, humtoloc)
        type(map), dimension(:), allocatable, target, intent(out) :: &
            seedtosoil, soiltofert, ferttowat, wattolight, &
            lighttotemp, temptohum, humtoloc
        integer(int64), dimension(:), allocatable, intent(out) :: seeds
        integer :: sizes(8)

        type(map), dimension(:), pointer :: currarray
        character(256) :: filename, line
        integer :: error, i, counter
        
        write(*,*) "input file name"
        read(*,*) filename
        if (trim(filename) .eq. 't') filename = 'test.txt'
        if (trim(filename) .eq. 'm') filename = 'day5.txt'
        call calc_map_sz(filename, sizes)

        allocate( seeds(sizes(1)) )
        allocate( seedtosoil(sizes(2)) )
        allocate( soiltofert(sizes(3)) )
        allocate( ferttowat(sizes(4)) )
        allocate( wattolight(sizes(5)) )
        allocate( lighttotemp(sizes(6)) )
        allocate( temptohum(sizes(7)) )
        allocate( humtoloc(sizes(8)) )

        open(1, file=filename, status='old', iostat=error)
        if (error .ne. 0) stop

        do
        read(1,'(a)',iostat=error) line
        select case (error)
        case(0)
            if (scan(line, ':') .ne. 0) then
                counter = 1
                if (index(line, 'seeds:') .ne. 0) read(line(7:),*) seeds
                if (index(line, 'seed-to-soil') .ne. 0) currarray => seedtosoil
                if (index(line, 'soil-to-fert') .ne. 0) currarray => soiltofert
                if (index(line, 'fertilizer-t') .ne. 0) currarray => ferttowat
                if (index(line, 'water-to-lig') .ne. 0) currarray => wattolight
                if (index(line, 'light-to-tem') .ne. 0) currarray => lighttotemp
                if (index(line, 'temperature-') .ne. 0) currarray => temptohum
                if (index(line, 'humidity-to-') .ne. 0) currarray => humtoloc
            else if (scan(line, '1234567890') .ne. 0) then
                read(line,*) currarray(counter)
                counter = counter + 1
            end if
        case(iostat_end)
            exit
        case default
            write(*,*) "error reading file"
            stop
        end select
        end do
        close(1)
    end subroutine

    subroutine calc_map_sz(filename, sizes)
        character(256), intent(in) :: filename
        integer, intent(out) :: sizes(8)
        character(256) :: line
        integer :: error, ii, jj
        sizes = 0
        ii = 0
        open(1, file=filename, status='old', iostat=error)
        if (error .ne. 0) stop
        do
        read(1,'(a)', iostat=error) line
        select case (error)
        case(0)
            if (scan(line, ':') .ne. 0) ii = ii + 1
            if (index(line, 'seeds:') .ne. 0) then
                do jj=1,len_trim(line)
                if (line(jj:jj) .eq. ' ') sizes(1) = sizes(1) + 1
                end do
            else if (scan(line, '1234567890') .ne. 0) then
                sizes(ii) = sizes(ii) + 1
            end if
            
        case(iostat_end)
            exit
        case default
            write(*,*) "error reading file"
            stop
        end select
        end do
        close(1)
    end subroutine

    subroutine print_map(arr)
        type(map), intent(in) :: arr(:)
        integer :: ii

        do ii=1,size(arr)
        write(*,'(3i5)') arr(ii)
        end do
    end subroutine
end submodule aoc_day5

