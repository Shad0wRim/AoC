submodule(aoc) aoc_day7
    use, intrinsic :: iso_fortran_env, only: iostat_end
    implicit none
    type hand
        character, dimension(5) :: hand
    end type

contains

    subroutine day7(data, part1, part2)
        character(len=*), intent(in) :: data
        character(len=:), allocatable, intent(out) :: part1, part2
        type(hand), allocatable :: hands(:)
        integer, allocatable :: bids(:)
        character(256) :: line
        character(20) :: filename
        type(hand) :: temphand
        integer :: tempbid, totalwinnings, totalwinnings_j, i
        allocate (hands(0), bids(0))
        totalwinnings = 0
        totalwinnings_j = 0

        block
            integer :: data_begin, data_end
            data_end = 0
            do while (data_end < len(data))
                data_begin = data_end + 1
                data_end = data_begin + scan(data(data_begin:), new_line('')) - 1
                line = data(data_begin:data_end-1)

                temphand%hand = [(line(i:i), i=1,5)]
                read (line(7:), *) tempbid
                hands = [hands, temphand]
                bids = [bids, tempbid]
            end do
        end block

        call sort_hands(hands, bids)
        totalwinnings = sum([(i * bids(i), i = 1,size(hands))])

        call sort_hands_j(hands, bids)
        totalwinnings_j = sum([(i * bids(i), i = 1,size(hands))])


        allocate(character(len=64)::part1)
        allocate(character(len=64)::part2)
        write(part1,'(i0)') totalwinnings
        write(part2,'(i0)') totalwinnings_j
        part1 = trim(part1)
        part2 = trim(part2)

    end subroutine

    subroutine sort_hands(hands, bids)
        type(hand), intent(inout) :: hands(:)
        integer, intent(inout) :: bids(:)
        type(hand) :: temphand
        integer :: tempbid
        integer :: i, j
        ! insertion sort of hands
        do i = 2, size(hands)
        do j = i, 2, -1
        if (ishigher(hands(j - 1), hands(j))) then
            temphand = hands(j)
            tempbid = bids(j)
            hands(j) = hands(j - 1)
            hands(j - 1) = temphand
            bids(j) = bids(j - 1)
            bids(j - 1) = tempbid
        end if
        end do
        end do
    end subroutine

    function handtype(self)
        type(hand), intent(in) :: self
        integer :: handtype
        integer :: i, matches(5)
        ! 1 : high card
        ! 2 : one pair
        ! 3 : two pair
        ! 4 : three of a kind
        ! 5 : full house
        ! 6 : four of a kind
        ! 7 : five of a kind

        matches = [(count(self%hand == self%hand(i)), i=1,5)]

        if (any(matches == 5)) then
            handtype = 7 ! 5 of a kind
        else if (any(matches == 4)) then
            handtype = 6 ! 4 of a kind
        else if (count(matches == 3) == 3 .and. count(matches == 2) == 2) then
            handtype = 5 ! full house
        else if (count(matches == 3) == 3) then
            handtype = 4 ! three of a kind
        else if (count(matches == 2) == 4) then
            handtype = 3 ! two pair
        else if (count(matches == 2) == 2) then
            handtype = 2 ! one pair
        else if (all(matches == 1)) then
            handtype = 1 ! high card
        end if

    end function

    function ishigher(self, other)
        type(hand), intent(in) :: self
        type(hand), intent(in) :: other
        logical :: ishigher
        integer :: i, selfrank, otherrank
        character(13), parameter :: order = '23456789TJQKA'
        ishigher = .false.
        ! type first, then highcard from first index
        if (handtype(self) > handtype(other)) then
            ishigher = .true.
        else if (handtype(self) < handtype(other)) then
            ishigher = .false.
        else
            do i = 1, 5
                selfrank = scan(order, self%hand(i))
                otherrank = scan(order, other%hand(i))
                if (selfrank > otherrank) then
                    ishigher = .true.
                    return
                else if (selfrank < otherrank) then
                    ishigher = .false.
                    return
                else
                    cycle
                end if
            end do
        end if
    end function

    subroutine sort_hands_j(hands, bids)
        type(hand), intent(inout) :: hands(:)
        integer, intent(inout) :: bids(:)
        type(hand) :: temphand
        integer :: tempbid
        integer :: i, j
        ! insertion sort of hands
        do i = 2, size(hands)
            do j = i, 2, -1
                if (ishigher_j(hands(j - 1), hands(j))) then
                    temphand = hands(j)
                    tempbid = bids(j)
                    hands(j) = hands(j - 1)
                    hands(j - 1) = temphand
                    bids(j) = bids(j - 1)
                    bids(j - 1) = tempbid
                end if
            end do
        end do
    end subroutine

    function handtype_j(self)
        type(hand), intent(in) :: self
        integer :: handtype_j, simplehandtype
        integer :: i, j, k, l, m
        character :: handarr(5)
        ! 1 : high card
        ! 2 : one pair
        ! 3 : two pair
        ! 4 : three of a kind
        ! 5 : full house
        ! 6 : four of a kind
        ! 7 : five of a kind

        handtype_j = handtype(self)

        select case (count(self%hand == 'J'))
        case (0)
            continue
        case (1)
            select case (handtype_j)
            case (1)
                handtype_j = 2
            case (2)
                handtype_j = 4
            case (3)
                handtype_j = 5
            case (4)
                handtype_j = 6
            case (5)
                print *, "not possible"
            case (6)
                handtype_j = 7
            case (7)
                print *, "not possible"
            end select
        case (2)
            select case (handtype_j)
            case (1)
                print *, "not possible"
            case (2)
                handtype_j = 4
            case (3)
                handtype_j = 6
            case (4)
                print *, "not possible"
            case (5)
                handtype_j = 7
            case (6)
                print *, "not possible"
            case (7)
                print *, "not possible"
            end select
        case (3)
            select case (handtype_j)
            case (1)
                print *, "not possible"
            case (2)
                print *, "not possible"
            case (3)
                print *, "not possible"
            case (4)
                handtype_j = 6
            case (5)
                handtype_j = 7
            case (6)
                print *, "not possible"
            case (7)
                print *, "not possible"
            end select
        case (4)
            select case (handtype_j)
            case (1)
                print *, "not possible"
            case (2)
                print *, "not possible"
            case (3)
                print *, "not possible"
            case (4)
                print *, "not possible"
            case (5)
                print *, "not possible"
            case (6)
                handtype_j = 7
            case (7)
                print *, "not possible"
            end select
        case (5)
            continue
        end select

    end function

    function ishigher_j(self, other)
        type(hand), intent(in) :: self
        type(hand), intent(in) :: other
        logical :: ishigher_j
        integer :: i, selfrank, otherrank
        character(13), parameter :: order = 'J23456789TQKA'
        ishigher_j = .false.
        ! type first, then highcard from first index
        if (handtype_j(self) > handtype_j(other)) then
            ishigher_j = .true.
        else if (handtype_j(self) < handtype_j(other)) then
            ishigher_j = .false.
        else
            do i = 1, 5
                selfrank = scan(order, self%hand(i))
                otherrank = scan(order, other%hand(i))
                if (selfrank > otherrank) then
                    ishigher_j = .true.
                    return
                else if (selfrank < otherrank) then
                    ishigher_j = .false.
                    return
                else
                    cycle
                end if
            end do
        end if

    end function
end submodule
