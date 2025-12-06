submodule(aoc) aoc_day
   use, intrinsic :: iso_fortran_env, only: iostat_end
   implicit none
   type crawler
      integer :: dist = 0, camefrom = 0
      integer :: loc(2), bounds(2)
   contains
      procedure :: up, down, left, right
      procedure :: val, numval
   end type

contains
   subroutine day10
      character(9) :: filename
      character, allocatable :: field(:, :)
      integer, allocatable :: distfield(:, :), infield(:, :)
      integer :: maxdist, numholes, enclosed

      write (*, *) "input file name"
      read (*, *) filename
      if (filename .eq. 't') filename = 'test.txt'
      if (filename .eq. 'm') filename = 'day10.txt'

      call fill_field(filename, field)

      call traverse_pipe(field, distfield)
      maxdist = maxval(distfield)
      where (field .eq. 'S') distfield = 0
      where (distfield .eq. 0 .and. field .ne. 'S') field = '.'

      print *, " 1 "
      print *, "2.3"
      print *, " 4 "

      printchar: block
         character(10) :: format, sz_str
         write (sz_str, '(i0)') size(field, dim=1)
         format = '('//trim(sz_str)//'a1)'
         print format, field
      end block printchar
      print *
      printdist: block
         character(10) :: format, sz_str
         write (sz_str, '(i0)') size(field, dim=1)
         format = '('//trim(sz_str)//'i3)'
         print format, distfield
      end block printdist
      print *
      call even_odd(field, distfield, infield)
      enclosed = sum(infield, mask=infield .gt. 0)
      print *
      printin: block
         character(10) :: format, sz_str
         write (sz_str, '(i0)') size(field, dim=1)
         format = '('//trim(sz_str)//'i3)'
         print format, infield
      end block printin

      write (*, '(a,i0)') "farthest position:  ", maxdist
      write (*, '(a,i0)') "number of enclosed: ", enclosed

   end subroutine

   subroutine even_odd(field, distfield, infield)
      character, intent(in) :: field(:, :)
      integer, allocatable, intent(out) :: infield(:, :)
      integer, intent(in) :: distfield(:, :)
      integer :: tmpdist(size(distfield, 1), size(distfield, 2))
      integer :: i, j, k, counter
      if (allocated(infield)) deallocate (infield)
      allocate (infield(size(field, 1), size(field, 2)))
      tmpdist = distfield
      where (tmpdist .ne. 0) tmpdist = tmpdist + 1
      where (field .eq. 'S') tmpdist = 1
      printdist: block
         character(10) :: format, sz_str
         write (sz_str, '(i0)') size(field, dim=1)
         format = '('//trim(sz_str)//'i3)'
         print format, tmpdist
      end block printdist

      do j = 1, size(field, 2)
         counter = 0
         do i = 1, size(field, 1)
            if (i .eq. 1) then
               if (tmpdist(i, j) .ne. 0) counter = counter + 1
            else
               if (tmpdist(i, j) .eq. 0) cycle
               if (abs(tmpdist(i, j) - tmpdist(i - 1, j)) .gt. 1) then
                  counter = counter + 1
               end if
            end if
            if (any(['S', '|', '-', 'F', 'J', '7', 'L'] .eq. field(i, j))) then
               infield(i, j) = 0
            else
               infield(i, j) = mod(counter, 2)
            end if
         end do
      end do

      !do concurrent (i=1:size(field,1), j=1:size(field,2))
      !    counter = 0
      !    if (any(['S','|','-','F','J','7','L'] == field(i,j))) then
      !        infield(i,j) = 0
      !    else
      !        do k=i,size(field,1)
      !            if (k == 1 .or. k > size(field,1)) cycle
      !            if (tmpdist(k,j) == 0) cycle
      !            if (abs(tmpdist(k,j) - tmpdist(k-1,j)) > 1) then
      !                counter = counter + 1
      !            else if (tmpdist(k-1,j) == 0) then
      !                cycle
      !            end if
      !        end do
      !        if (mod(counter,2) == 0) then
      !            infield(i,j) = 0
      !        else
      !            infield(i,j) = 1
      !        end if
      !    end if
      !end do
   end subroutine

   subroutine traverse_pipe(field, distfield)
      character, target, intent(in) :: field(:, :)
      integer, allocatable, target, intent(out) :: distfield(:, :)
      type(crawler) :: crwlr(2)
      character :: next
      integer :: error
      logical :: isvalid(4)
      integer :: i
      allocate (distfield(size(field, 1), size(field, 2)))
      distfield = 0
      crwlr(1)%bounds = shape(field)
      crwlr(2)%bounds = shape(field)
      crwlr(1)%loc = findloc(field, 'S')
      crwlr(2)%loc = findloc(field, 'S')
      ! .1.
      ! 2S3
      ! .4.

      ! find the connections to the start
      isvalid = .false.
      do i = 1, 4
         select case (i)
         case (1)
            error = crwlr(1)%up()
            if (error .ne. 0) cycle
            next = crwlr(1)%val(field)
            if (scan(next, 'F7|') .ne. 0) isvalid(i) = .true.
         case (2)
            error = crwlr(1)%left()
            if (error .ne. 0) cycle
            next = crwlr(1)%val(field)
            if (scan(next, 'FL-') .ne. 0) isvalid(i) = .true.
         case (3)
            error = crwlr(1)%right()
            if (error .ne. 0) cycle
            next = crwlr(1)%val(field)
            if (scan(next, '7J-') .ne. 0) isvalid(i) = .true.
         case (4)
            error = crwlr(1)%down()
            if (error .ne. 0) cycle
            next = crwlr(1)%val(field)
            if (scan(next, 'LJ|') .ne. 0) isvalid(i) = .true.
         end select
         print'(i0,x,a,x,l)', i, next, isvalid(i)
         crwlr(1)%loc = findloc(field, 'S')
      end do

      ! crawl
      select case (findloc(isvalid, .true., dim=1))
      case (1)
         error = crwlr(1)%up()
      case (2)
         error = crwlr(1)%left()
      case (3)
         error = crwlr(1)%right()
      case default
         write (*, *) "failed crawl"
         write (*, *) crwlr(1)%val(field)
      end select
      select case (findloc(isvalid, .true., dim=1, back=.true.))
      case (2)
         error = crwlr(2)%left()
      case (3)
         error = crwlr(2)%right()
      case (4)
         error = crwlr(2)%down()
      case default
         write (*, *) "failed crawl"
         write (*, *) crwlr(2)%val(field)
      end select
      do i = 1, 2
         crwlr(i)%dist = crwlr(i)%dist + 1
         distfield(crwlr(i)%loc(1), crwlr(i)%loc(2)) = crwlr(i)%dist
      end do

      crawl: do
      do i = 1, 2
         select case (crwlr(i)%camefrom)
         case (1)
            select case (crwlr(i)%val(field))
            case ('|')
               error = crwlr(i)%down()
            case ('L')
               error = crwlr(i)%right()
            case ('J')
               error = crwlr(i)%left()
            case default
               write (*, *) "failed crawl"
               write (*, *) crwlr(i)%val(field)
            end select
         case (2)
            select case (crwlr(i)%val(field))
            case ('-')
               error = crwlr(i)%right()
            case ('J')
               error = crwlr(i)%up()
            case ('7')
               error = crwlr(i)%down()
            case default
               write (*, *) "failed crawl"
               write (*, *) crwlr(i)%val(field)
            end select
         case (3)
            select case (crwlr(i)%val(field))
            case ('-')
               error = crwlr(i)%left()
            case ('L')
               error = crwlr(i)%up()
            case ('F')
               error = crwlr(i)%down()
            case default
               write (*, *) "failed crawl"
               write (*, *) crwlr(i)%val(field)
            end select
         case (4)
            select case (crwlr(i)%val(field))
            case ('|')
               error = crwlr(i)%up()
            case ('7')
               error = crwlr(i)%left()
            case ('F')
               error = crwlr(i)%right()
            case default
               write (*, *) "failed crawl"
               write (*, *) crwlr(i)%val(field)
            end select
         case default
            write (*, *) "failed crawl"
            write (*, *) crwlr(i)%val(field)
         end select

         if (error .ne. 0) then
            write (*, *) "failed crawl"
            write (*, *) crwlr(i)%val(field)
         else
            crwlr(i)%dist = crwlr(i)%dist + 1
            if (crwlr(i)%numval(distfield) .ne. 0) then
               print *, "exiting crawl"
               exit crawl
            end if
            distfield(crwlr(i)%loc(1), crwlr(i)%loc(2)) = crwlr(i)%dist
         end if
      end do
      end do crawl
   end subroutine

   subroutine fill_field(filename, field)
      character(9), intent(in) :: filename
      character, allocatable, intent(out) :: field(:, :)
      character(256) :: line
      integer :: error, num_lines, line_sz, i

      open (1, file=filename, status='old', iostat=error)
      if (error .ne. 0) stop

      num_lines = 0
      do
         read (1, '(a)', iostat=error) line
         if (error .ne. 0) exit
         num_lines = num_lines + 1
      end do
      line_sz = len_trim(line)

      allocate (field(line_sz, num_lines))

      rewind (1)

      do i = 1, num_lines
         read (1, '(*(a1))') field(:, i)
      end do

      close (1)

   end subroutine

   function val(self, arr) result(res)
      class(crawler), intent(in) :: self
      character, intent(in) :: arr(:, :)
      character :: res

      if (any(self%loc .lt. 1) .or. self%loc(1) .gt. size(arr, 1) .or. self%loc(2) .gt. size(arr, 2)) then
         res = 'X'
      else
         res = arr(self%loc(1), self%loc(2))
      end if
   end function
   function numval(self, arr) result(res)
      class(crawler), intent(in) :: self
      integer :: arr(:, :)
      integer :: res

      if (any(self%loc .lt. 1) .or. self%loc(1) .gt. size(arr, 1) .or. self%loc(2) .gt. size(arr, 2)) then
         res = -1
      else
         res = arr(self%loc(1), self%loc(2))
      end if
   end function
   function right(self) result(res)
      class(crawler), intent(inout) :: self
      integer :: res
      if (self%loc(1) .ge. self%bounds(1)) then
         self%camefrom = 0
         res = 1
      else
         self%loc(1) = self%loc(1) + 1
         self%camefrom = 2
         res = 0
      end if
   end function
   function left(self) result(res)
      class(crawler), intent(inout) :: self
      integer :: res
      if (self%loc(1) .le. 1) then
         self%camefrom = 0
         res = 1
      else
         self%camefrom = 3
         self%loc(1) = self%loc(1) - 1
         res = 0
      end if
   end function
   function down(self) result(res)
      class(crawler), intent(inout) :: self
      integer :: res
      if (self%loc(2) .ge. self%bounds(2)) then
         self%camefrom = 0
         res = 1
      else
         self%camefrom = 1
         self%loc(2) = self%loc(2) + 1
         res = 0
      end if
   end function
   function up(self) result(res)
      class(crawler), intent(inout) :: self
      integer :: res
      if (self%loc(2) .le. 1) then
         self%camefrom = 0
         res = 1
      else
         self%camefrom = 4
         self%loc(2) = self%loc(2) - 1
         res = 0
      end if
   end function

end submodule
