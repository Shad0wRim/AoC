submodule(aoc) aoc_day7
    use, intrinsic :: iso_fortran_env, only: iostat_end
    implicit none
    type hand
        character(5) :: hand
    end type

contains

    subroutine day7
        type(hand), allocatable :: hands(:)
        integer, allocatable :: bids(:)
        character(256) :: filename, line
        integer :: error, i
        type(hand) :: temphand
        integer :: tempbid, totalwinnings = 0, totalwinnings_j = 0
        allocate (hands(0), bids(0))

        write (*, *) "input filename"
        read (*, *) filename
        if (filename == 't') filename = 'test.txt'
        if (filename == 'm') filename = 'day7.txt'

        do
            open (1, file=filename, status='old', iostat=error)
            if (error /= 0) stop

            read (1, '(a)', iostat=error) line
            select case (error)
            case (0)
                temphand%hand = line(1:5)
                read (line(7:), *) tempbid
                hands = [hands, temphand]
                bids = [bids, tempbid]
            case (iostat_end)
                exit
            case default
                print *, "error reading file"
                stop
            end select
        end do

        do i = 1, size(hands)
            print'(a,2x,i3,i2)', hands(i), bids(i), handtype(hands(i))
        end do

        print *, "regular"
        call sort_hands(hands, bids)

        do i = 1, size(hands)
            print'(a,2x,i3,i2)', hands(i), bids(i), handtype(hands(i))
        end do

        do i = 1, size(hands)
            totalwinnings = totalwinnings + i * bids(i)
        end do

        print *, "jokers"
        call sort_hands_j(hands, bids)

        do i = 1, size(hands)
            print'(a,2x,i3,i2)', hands(i), bids(i), handtype_j(hands(i))
        end do

        do i = 1, size(hands)
            totalwinnings_j = totalwinnings_j + i * bids(i)
        end do

        write (*, '(a,i0)') "total winnings:       ", totalwinnings
        write (*, '(a,i0)') "total joker winnings: ", totalwinnings_j

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
        character :: handarr(5)
        ! 1 : high card
        ! 2 : one pair
        ! 3 : two pair
        ! 4 : three of a kind
        ! 5 : full house
        ! 6 : four of a kind
        ! 7 : five of a kind
        do i = 1, 5
            handarr(i) = self%hand(i:i)
        end do

        do i = 1, 5
            matches(i) = count(handarr == handarr(i))
        end do

        ! 5 of a kind
        if (any(matches == 5)) then
            handtype = 7
            return
        end if

        ! 4 of a kind
        if (any(matches == 4)) then
            handtype = 6
            return
        end if

        ! full house
        if (count(matches == 3) == 3 .and. count(matches == 2) == 2) then
            handtype = 5
            return
        end if

        ! three of a kind
        if (count(matches == 3) == 3) then
            handtype = 4
            return
        end if

        ! two pair
        if (count(matches == 2) == 4) then
            handtype = 3
            return
        end if

        ! one pair
        if (count(matches == 2) == 2) then
            handtype = 2
            return
        end if

        ! high card
        if (all(matches == 1)) then
            handtype = 1
            return
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
            print *, self, "  ", other
            do i = 1, 5
                selfrank = scan(order, self%hand(i:i))
                otherrank = scan(order, other%hand(i:i))
                print *, selfrank, otherrank
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
        character(12), parameter :: order = '23456789TQKA'
        ! 1 : high card
        ! 2 : one pair
        ! 3 : two pair
        ! 4 : three of a kind
        ! 5 : full house
        ! 6 : four of a kind
        ! 7 : five of a kind

        do i = 1, 5
            handarr(i) = self%hand(i:i)
        end do

        handtype_j = handtype(self)

        select case (count(handarr == 'J'))
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
            print *, self, "  ", other
            do i = 1, 5
                selfrank = scan(order, self%hand(i:i))
                otherrank = scan(order, other%hand(i:i))
                print *, selfrank, otherrank
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
