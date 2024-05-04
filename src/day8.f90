submodule(aoc) aoc_day8
   use, intrinsic :: iso_fortran_env, only: iostat_end
   implicit none
   type node
      character(3) :: node
      character(3) :: left
      character(3) :: right
   end type
contains
   subroutine day8
      character(270) :: instructions
      character(16) :: line
      character(8) :: filename
      type(node) :: newnode
      type(node), allocatable :: nodes(:)
      integer :: error, numsteps
      integer(8) :: numghoststeps
      allocate (nodes(0))

      write (*, *) "input file name"
      read (*, *) filename
      if (filename .eq. 't') filename = 'test.txt'
      if (filename .eq. 'm') filename = 'day8.txt'

      open (1, file=filename, status='old', iostat=error)
      if (error .ne. 0) stop

      read (1, '(a)') instructions
      read (1, '(a)') line
      do
         read (1, '(a)', iostat=error) line
         select case (error)
         case (0)
            newnode = node(line(1:3), line(8:10), line(13:15))
            nodes = [nodes, newnode]
         case (iostat_end)
            exit
         case default
            print *, "error reading file"
         end select
      end do

      print *, trim(instructions)
      print'(3(a3,x))', nodes
      print *, size(nodes)

      call follow_path(instructions, nodes, numsteps)
      call follow_ghosts(instructions, nodes, numghoststeps)

      write (*, '(a,i0)') "steps required: ", numsteps
      write (*, '(a,i0)') "steps for ghost:", numghoststeps

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
      if (findloc(nodenames, 'AAA', dim=1) .ne. 0) then
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
         print *, currnode%node
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
      character :: currinstr, iterformat
      character(10) :: format
      character(3) :: nodenames(size(nodes))
      integer(8), allocatable :: hpsteps(:)
      integer, parameter :: NUM_ITERS = 9
      numsteps = 0
      nodenames = nodes%node
      Alocs = findAlocs(nodenames)
      currnodes = nodes(Alocs)
      allocate (steps(NUM_ITERS, size(currnodes)), nextnodes(size(currnodes)))
      steps = 0

      print'(3(a3,x))', currnodes
      print *

      do i = 1, size(currnodes, dim=1)
         numsteps = 0
         j = 1
         do
            instridx = mod(numsteps, len_trim(instructions)) + 1
            currinstr = instructions(instridx:instridx)

            select case (currinstr)
            case ('L')
               nextnodes(i) = currnodes(i)%left
            case ('R')
               nextnodes(i) = currnodes(i)%right
            case default
               print *, "invalid direction"
               stop
            end select

            currnodes(i) = nodes(findloc(nodenames, nextnodes(i), dim=1))

            steps(j, i) = steps(j, i) + 1
            numsteps = numsteps + 1
            if (currnodes(i)%node(3:3) .eq. 'Z') j = j + 1
            if (j .gt. NUM_ITERS) exit
         end do
      end do

      write (iterformat, '(i1)') NUM_ITERS
      format = '('//iterformat//'(i0,x))'
      print format, steps
      print *, steps(1, :)
      hpsteps = steps(1, :)

      numsteps = lcm_arr(hpsteps)
      print *, "lcm", numsteps

      return

      ! inefficient, iterate all at once

!        do while (any(currnodes%node(3:3) /= 'Z'))
!            instridx = mod(numsteps, len_trim(instructions)) + 1
!            currinstr = instructions(instridx:instridx)
!
!            select case (currinstr)
!            case ('L')
!                nextnodes = currnodes%left
!            case ('R')
!                nextnodes = currnodes%right
!            case default
!                print *, "invalid direction"
!                stop
!            end select
!
!            do concurrent (i=1:size(nextnodes))
!            currnodes(i) = nodes(findloc(nodenames, nextnodes(i), dim=1))
!            end do
!
!            numsteps = numsteps + 1
!            print '((a3,x))', currnodes%node
!            print *, numsteps
!        end do
!
!        print'(a3,x))', currnodes%node

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

      if (b .eq. 0) then
         gcd_ = a
      else
         gcd_ = gcd(b, mod(a, b))
      end if
   end function
end submodule
