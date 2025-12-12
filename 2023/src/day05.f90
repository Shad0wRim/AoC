submodule(aoc) aoc_day5
    use, intrinsic :: iso_fortran_env, only: iostat_end, int64
    implicit none

    type map
        integer(int64) :: deststrt, srcstrt, rnglen
    end type
contains
    subroutine day5(data, part1, part2)
        character(len=*), intent(in) :: data
        character(len=:), allocatable, intent(out) :: part1, part2
        type(map), dimension(:), allocatable :: seedtosoil, soiltofert, ferttowat, wattolight, lighttotemp, temptohum, humtoloc
        integer(int64), dimension(:), allocatable :: seeds, transform
        integer(int64), allocatable :: transform_list(:)
        integer :: minlocnum, minlocnumlist, i

        call populate_maps(data, seeds, seedtosoil, soiltofert, ferttowat, wattolight, lighttotemp, temptohum, humtoloc)

        transform = seeds
        call transform_seeds(seedtosoil, transform)
        call transform_seeds(soiltofert, transform)
        call transform_seeds(ferttowat, transform)
        call transform_seeds(wattolight, transform)
        call transform_seeds(lighttotemp, transform)
        call transform_seeds(temptohum, transform)
        call transform_seeds(humtoloc, transform)
        minlocnum = minval(transform)

        transform_list = seeds
        call transform_seed_list(seedtosoil, transform_list)
        call transform_seed_list(soiltofert, transform_list)
        call transform_seed_list(ferttowat, transform_list)
        call transform_seed_list(wattolight, transform_list)
        call transform_seed_list(lighttotemp, transform_list)
        call transform_seed_list(temptohum, transform_list)
        call transform_seed_list(humtoloc, transform_list)

        minlocnumlist = minval(transform_list(::2))

        allocate(character(len=64)::part1)
        allocate(character(len=64)::part2)
        write(part1,'(i0)') minlocnum
        write(part2,'(i0)') minlocnumlist
        part1 = trim(part1)
        part2 = trim(part2)
    end subroutine

    subroutine expand_seeds(seeds, expseeds)
        integer(int64), intent(in) :: seeds(:)
        integer(int64), allocatable, intent(out) :: expseeds(:)
        integer(int64), allocatable :: tmp(:, :), rng(:)
        integer :: il, ol, i
        allocate (expseeds(0))

        tmp = reshape(seeds, [2, size(seeds) / 2])

        do ol = 1, size(tmp, dim=2)
            rng = [(i + tmp(1, ol) - 1, i = 1,tmp(2, ol))]
            expseeds = [expseeds, rng]
        end do
    end subroutine

    subroutine transform_seeds(mapping, transform)
        type(map), intent(in) :: mapping(:)
        integer(int64), intent(inout) :: transform(:)
        integer :: i, j
        logical :: inrng

        do j = 1, size(transform)
            do i = 1, size(mapping)
                inrng = (transform(j) >= mapping(i)%srcstrt)
                inrng = inrng .and. (transform(j) <= mapping(i)%srcstrt + mapping(i)%rnglen - 1)
                if (inrng) then
                    transform(j) = mapping(i)%deststrt + transform(j) - mapping(i)%srcstrt
                    exit
                end if
            end do
        end do
    end subroutine

    subroutine transform_seed_list(mapping, transform)
        type(map), intent(in) :: mapping(:)
        integer(int64), allocatable, intent(inout) :: transform(:)
        integer(int64) :: nextval
        type(map) :: currmap
        integer :: ol, il, i, counter
        logical :: inrng, iscontained, innone

        ol = 1
        do while (ol .lt. size(transform))
        innone = .true.
        do il = 1, size(mapping)
        currmap = mapping(il)
        inrng = (transform(ol) .ge. currmap%srcstrt)
        inrng = inrng .and. (transform(ol) .le. currmap%srcstrt + currmap%rnglen - 1)

        ! in one of the maps
        if (inrng) then
            iscontained = transform(ol + 1) .lt. currmap%rnglen - (transform(ol) - currmap%srcstrt)
            if (.not. iscontained) then
                transform(ol + 1) = currmap%rnglen - (transform(ol) - currmap%srcstrt)
                if (currmap%rnglen - transform(ol + 1) + 1 > 0) then
                    transform = [transform, transform(ol) + transform(ol + 1), currmap%rnglen - transform(ol + 1) + 1]
                end if
            end if
            transform(ol) = currmap%deststrt + transform(ol) - currmap%srcstrt
            innone = .false.
            exit
        end if
        end do

        ! in none of the maps
        if (innone) then
            nextval = minval(mapping(:)%srcstrt, mask=mapping(:)%srcstrt .gt. transform(ol))
            if (nextval - transform(ol) .lt. transform(ol + 1)) then
                transform = [transform, nextval, transform(ol + 1) - (nextval - transform(ol))]
                transform(ol + 1) = nextval - transform(ol)
            end if
        end if
        ol = ol + 2
        end do

    end subroutine

    subroutine populate_maps(data, seeds, seedtosoil, soiltofert, ferttowat, wattolight, lighttotemp, temptohum, humtoloc)
        character(len=*), intent(in) :: data
        type(map), dimension(:), allocatable, target, intent(out) :: &
            seedtosoil, soiltofert, ferttowat, wattolight, &
            lighttotemp, temptohum, humtoloc
        integer(int64), dimension(:), allocatable, intent(out) :: seeds
        integer :: sizes(8)

        type(map), dimension(:), pointer :: currarray
        character(256) :: line
        integer :: i, counter
        integer :: data_begin, data_end
        data_end = 0

        call calc_map_sz(data, sizes)

        allocate (seeds(sizes(1)))
        allocate (seedtosoil(sizes(2)))
        allocate (soiltofert(sizes(3)))
        allocate (ferttowat(sizes(4)))
        allocate (wattolight(sizes(5)))
        allocate (lighttotemp(sizes(6)))
        allocate (temptohum(sizes(7)))
        allocate (humtoloc(sizes(8)))

        do while (data_end < len(data))
            data_begin = data_end + 1
            data_end = data_begin + scan(data(data_begin:), new_line('')) - 1
            line = data(data_begin:data_end-1)

            if (scan(line, ':') .ne. 0) then
                counter = 1
                if (index(line, 'seeds:') .ne. 0) read (line(7:), *) seeds
                if (index(line, 'seed-to-soil') .ne. 0) currarray => seedtosoil
                if (index(line, 'soil-to-fert') .ne. 0) currarray => soiltofert
                if (index(line, 'fertilizer-t') .ne. 0) currarray => ferttowat
                if (index(line, 'water-to-lig') .ne. 0) currarray => wattolight
                if (index(line, 'light-to-tem') .ne. 0) currarray => lighttotemp
                if (index(line, 'temperature-') .ne. 0) currarray => temptohum
                if (index(line, 'humidity-to-') .ne. 0) currarray => humtoloc
            else if (scan(line, '1234567890') .ne. 0) then
                read (line, *) currarray(counter)
                counter = counter + 1
            end if
        end do
    end subroutine

    subroutine calc_map_sz(data, sizes)
        character(len=*), intent(in) :: data
        integer, intent(out) :: sizes(8)
        character(256) :: line
        integer :: ii, jj
        integer :: data_begin, data_end
        data_end = 0
        sizes = 0
        ii = 0
        do while (data_end < len(data))
            data_begin = data_end + 1
            data_end = data_begin + scan(data(data_begin:), new_line('')) - 1
            line = data(data_begin:data_end-1)
            if (scan(line, ':') .ne. 0) ii = ii + 1
            if (index(line, 'seeds:') .ne. 0) then
                do jj = 1, len_trim(line)
                    if (line(jj:jj) .eq. ' ') sizes(1) = sizes(1) + 1
                end do
            else if (scan(line, '1234567890') .ne. 0) then
                sizes(ii) = sizes(ii) + 1
            end if
        end do
    end subroutine

    subroutine print_map(arr)
        type(map), intent(in) :: arr(:)
        integer :: ii

        do ii = 1, size(arr)
            write (*, '(3i5)') arr(ii)
        end do
    end subroutine
end submodule aoc_day5

