submodule(aoc) aoc_day8
    use, intrinsic :: iso_fortran_env, only: iostat_end
    implicit none
    type node
        character(len=3) :: node
        character(len=3) :: left
        character(len=3) :: right
    end type
contains
    subroutine day8(data, part1, part2)
        character(len=*), intent(in) :: data
        character(len=:), allocatable, intent(out) :: part1, part2
        character(len=270) :: instructions
        character(len=16) :: line
        type(node) :: newnode
        type(node), allocatable :: nodes(:)
        integer :: numsteps
        integer(8) :: numghoststeps
        allocate (nodes(0))

        block
            integer :: data_begin, data_end

            data_end = scan(data, new_line(' '))
            instructions = data(:data_end-1)

            ! skip the empty line
            data_end = data_end + 1
            do while (data_end < len(data))
                data_begin = data_end + 1
                data_end = data_begin + scan(data(data_begin:), new_line('')) - 1
                line = data(data_begin:data_end-1)

                newnode = node(line(1:3), line(8:10), line(13:15))
                nodes = [nodes, newnode]
            end do
        end block

        call follow_path(instructions, nodes, numsteps)
        call follow_ghosts(instructions, nodes, numghoststeps)

        allocate(character(len=64)::part1, part2)
        write(part1,'(i0)') numsteps
        write(part2,'(i0)') numghoststeps

    end subroutine

    subroutine follow_path(instructions, nodes, numsteps)
        character(270), intent(in) :: instructions
        type(node), intent(in) :: nodes(:)
        integer, intent(out) :: numsteps
        integer :: instridx
        character :: currinstr
        type(node) :: currnode
        character(3) :: nextnode, nodenames(size(nodes))

        numsteps = 0
        nodenames = nodes%node

        if (findloc(nodenames, 'AAA', dim=1) /= 0) then
            currnode = nodes(findloc(nodenames, 'AAA', dim=1))
        else
            print *, "can't follow ghost path"
            return
        end if

        do
            instridx = mod(numsteps, len_trim(instructions)) + 1
            currinstr = instructions(instridx:instridx)

            select case (currinstr)
            case ('L')
                nextnode = currnode%left
            case ('R')
                nextnode = currnode%right
            case default
                print *, "invalid direction"
                stop
            end select

            currnode = nodes(findloc(nodenames, nextnode, dim=1))
            numsteps = numsteps + 1
            if (currnode%node .eq. 'ZZZ') exit
        end do

    end subroutine

    subroutine follow_ghosts(instructions, nodes, numsteps)
        character(270), intent(in) :: instructions
        type(node), intent(in) :: nodes(:)
        integer(8), intent(out) :: numsteps
        type(node), allocatable :: currnodes(:)
        integer, allocatable :: Alocs(:), steps(:, :)
        character(3), allocatable :: nextnodes(:)
        integer :: instridx, i, j
        integer(8) :: lcmsteps
        integer(8), allocatable :: hpsteps(:)
        character :: currinstr
        character(3) :: nodenames(size(nodes))
        integer, parameter :: NUM_ITERS = 9

        numsteps = 0
        nodenames = nodes%node
        Alocs = findAlocs(nodenames)
        currnodes = nodes(Alocs)
        allocate (steps(NUM_ITERS, size(currnodes)), nextnodes(size(currnodes)))
        steps = 0

        do i = 1, size(currnodes, dim=1)
            numsteps = 0
            j = 1
            do while (j <= NUM_ITERS)
                instridx = mod(numsteps, len_trim(instructions)) + 1
                currinstr = instructions(instridx:instridx)

                if (currinstr == 'L') then
                    nextnodes(i) = currnodes(i)%left
                else if (currinstr == 'R') then
                    nextnodes(i) = currnodes(i)%right
                end if

                currnodes(i) = nodes(findloc(nodenames, nextnodes(i), dim=1))

                steps(j, i) = steps(j, i) + 1
                numsteps = numsteps + 1
                if (currnodes(i)%node(3:3) == 'Z') j = j + 1
            end do
        end do

        hpsteps = steps(1, :)
        numsteps = lcm_arr(hpsteps)
    end subroutine

    function findAlocs(names) result(idxs)
        character(3), intent(in) :: names(:)
        integer, allocatable :: idxs(:)
        integer :: i
        allocate (idxs(0))

        do i = 1, size(names)
        if (names(i) (3:3) .eq. 'A') idxs = [idxs, i]
        end do

    end function

    function lcm_arr(arr) result(lcm_)
        integer(8), intent(in) :: arr(:)
        integer(8) :: lcm_, i

        lcm_ = arr(1)
        do i = 2, size(arr)
        lcm_ = lcm(lcm_, arr(i))
        end do
    end function

    function lcm(a, b)
        integer(8), intent(in) :: a, b
        integer(8) :: lcm

        lcm = abs(a * b) / gcd(a, b)
    end function

    recursive function gcd(a, b) result(gcd_)
        integer(8), intent(in) :: a, b
        integer(8) :: gcd_

        if (b == 0) then
            gcd_ = a
        else
            gcd_ = gcd(b, mod(a, b))
        end if
    end function
end submodule
