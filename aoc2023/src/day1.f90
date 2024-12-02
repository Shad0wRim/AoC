submodule(aoc) aoc_day1
   use, intrinsic :: iso_fortran_env, only: iostat_end
   implicit none
contains
   subroutine day1
      character(256) :: line, path
      character(8) :: filename
      integer :: error, first_num, last_num, combined_num, total = 0
      integer :: ldx, rdx, lwx, rwx, lwv, rwv

      write (*, *) "input file name"
      read (*, *) filename
      if (trim(filename) .eq. 't') filename = 'test.txt'
      if (trim(filename) .eq. 'm') filename = 'day1.txt'
      open (unit=1, file=filename, status='old', iostat=error)
      if (error .ne. 0) then
         write (*, *) "invalid file name"
         stop
      end if

      do
         read (1, *, iostat=error) line

         select case (error)
         case (0)
            ldx = scan(line, '123456789')
            rdx = scan(line, '123456789', back=.true.)
            call find_number_word(line, lwx, rwx, lwv, rwv)
            if (ldx .lt. lwx .and. ldx .ne. 0) then
               read (line(ldx:ldx), *) first_num
            else
               first_num = lwv
            end if
            if (rdx .gt. rwx) then
               read (line(rdx:rdx), *) last_num
            else
               last_num = rwv
            end if
            total = total + concat_ints(first_num, last_num)
            write (*, *) first_num, last_num

         case (iostat_end)
            exit

         case default
            write (*, *) "error reading file"
            stop

         end select
      end do

      write (*, *) total
      close (unit=1)
   end subroutine

   subroutine find_number_word(str, lx, rx, lnum, rnum)
      character(99), intent(in) :: str
      integer, intent(out) :: lx, rx, lnum, rnum
      integer :: lidx(9), ridx(9), i, lnuma(1), rnuma(1)
      character(5), parameter :: numbers(9) = &
                                 (/'one  ', 'two  ', 'three', 'four ', 'five ', 'six  ', 'seven', 'eight', 'nine '/)
      do i = 1, 9
         lidx(i) = index(str, trim(numbers(i)))
         ridx(i) = index(str, trim(numbers(i)), back=.true.)
      end do

      lx = minval(lidx, mask=lidx .gt. 0)
      rx = maxval(ridx)
      lnuma = minloc(lidx, mask=lidx .gt. 0)
      rnuma = maxloc(ridx)
      lnum = lnuma(1)
      rnum = rnuma(1)

   end subroutine

   function concat_ints(num1, num2) result(output_num)
      integer, intent(in) :: num1, num2
      character(99) :: char1, char2, output_string
      integer :: output_num

      write (char1, *) num1
      write (char2, *) num2
      output_string = trim(adjustl(char1))//trim(adjustl(char2))
      read (output_string, *) output_num
   end function
end submodule
