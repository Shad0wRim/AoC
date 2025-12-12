submodule(aoc) aoc_day4
    use, intrinsic :: iso_fortran_env, only: iostat_end
    implicit none
contains
    subroutine day4(data, part1, part2)
        character(len=*),  intent(in) :: data
        character(len=:), allocatable, intent(out) :: part1, part2
        integer :: totpnts
        integer :: copies(500), pnts, newcopies, i
        integer :: data_begin, data_end
        character(256) :: line

        totpnts = 0
        data_end = 0
        copies = 1
        i = 1
        do while (data_end < len(data))
            data_begin = data_end + 1
            data_end = data_end + scan(data(data_begin:), new_line(''))
            line = data(data_begin:data_end-1)

            call calc_pnts_and_copies(line, pnts, newcopies)
            copies(i + 1:i + newcopies) = copies(i + 1:i + newcopies) + copies(i)

            totpnts = totpnts + pnts
            i = i + 1
        end do
        copies(i:) = 0

        allocate(character(len=64)::part1)
        allocate(character(len=64)::part2)
        write(part1,'(i0)') totpnts
        write(part2,'(i0)') sum(copies)
        part1 = trim(part1)
        part2 = trim(part2)
    end subroutine

    subroutine calc_pnts_and_copies(line, pnts, newcopies)
        character(256), intent(in) :: line
        integer, intent(out) :: pnts, newcopies
        character(256) :: skip, cardline, winline, userline
        integer :: cardnum, winsize, usersize, i, j
        integer, allocatable :: matches(:), winnums(:), usernums(:)

        ! cardline = line(6:scan(line, ':') - 1)
        ! read(cardline,*) cardnum

        winline = line(scan(line, ':') + 2:scan(line, '|') - 2)
        winsize = len_trim(winline) / 3 + 1
        allocate (winnums(winsize))
        read(winline,*) winnums

        userline = line(scan(line, '|') + 2:)
        usersize = len_trim(userline) / 3 + 1
        allocate (usernums(usersize))
        read(userline,*) usernums

        ! print'(i0)', cardnum
        ! print'(100(i2,1x))', winnums
        ! print'(100(i2,1x))', usernums

        allocate (matches(usersize))
        matches = 0
        do i = 1, usersize
            do j = 1, winsize
                if (usernums(i) == winnums(j)) matches(i) = 1
            end do
        end do

        newcopies = sum(matches)

        pnts = 2**(sum(matches) - 1)

    end subroutine
end submodule aoc_day4

