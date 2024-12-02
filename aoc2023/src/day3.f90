submodule(aoc) aoc_day3
   use, intrinsic :: iso_fortran_env, only: iostat_end
   implicit none
contains
   subroutine day3
      character, allocatable :: schematic(:, :)
      character(256) :: line, prevline, nextline, format
      character(3) :: gearline
      character(8) :: filename
      integer :: numstart, numend, gearloc, totalgear_rat = 0, total = 0
      integer :: num_lines, line_size, addnum, ratio, partnums(20), numadj, i
      logical :: is_valid

      write (*, *) "input file name"
      read (*, *) filename
      if (filename .eq. 't') filename = 'test.txt'
      if (filename .eq. 'm') filename = 'day3.txt'
      call calc_schematic_size(filename, num_lines, line_size)
      write (*, *) num_lines, line_size
      allocate (schematic(num_lines, line_size))
      call fill_schematic(filename, schematic)
      where (scan(schematic, '01234567890.*') .eq. 0) schematic = '-'
      call print_schematic(schematic)

      write (line, '(i0)') line_size
      format = '('//trim(line)//'a1)'

      ! part 1
      do i = 1, num_lines
         write (line, format) schematic(:, i)
         write (*, *) char(9), trim(line)
         numstart = scan(line, '0123456789')
         numend = verify(line(numstart:), '0123456789') + numstart - 2
         write (*, '(a4)', advance='no') line(numstart:numend)

         do while (numstart .ne. 0)
            is_valid = (line(numstart - 1:numstart - 1) .eq. '*')
            is_valid = is_valid .or. (line(numstart - 1:numstart - 1) .eq. '-')
            is_valid = is_valid .or. (line(numend + 1:numend + 1) .eq. '*')
            is_valid = is_valid .or. (line(numend + 1:numend + 1) .eq. '-')
            is_valid = is_valid .or. (any(schematic(numstart - 1:numend + 1, i - 1) .eq. '*'))
            is_valid = is_valid .or. (any(schematic(numstart - 1:numend + 1, i - 1) .eq. '-'))
            is_valid = is_valid .or. (any(schematic(numstart - 1:numend + 1, i + 1) .eq. '*'))
            is_valid = is_valid .or. (any(schematic(numstart - 1:numend + 1, i + 1) .eq. '-'))

            if (is_valid) then
               read (line(numstart:numend), *) addnum
               total = total + addnum
            end if

            line(numstart:numend) = '.'
            numstart = scan(line, '0123456789')
            numend = verify(line(numstart:), '0123456789') + numstart - 2
            write (*, '(a4)', advance='no') line(numstart:numend)
         end do
         write (*, *)
      end do

      write (*, *)
      ! part 2
      do i = 1, num_lines
         write (line, format) schematic(:, i)
         if (i .ne. 1) then
            write (prevline, format) schematic(:, i - 1)
         else
            prevline = ''
         end if
         if (i .ne. num_lines) then
            write (nextline, format) schematic(:, i + 1)
         else
            nextline = ''
         end if

         do while (scan(line, '*') .ne. 0)
            gearloc = scan(line, '*')
            numadj = 0
            if (gearloc .eq. 0) cycle
            if (scan(line(gearloc - 1:gearloc - 1), '0123456789') .ne. 0) then
               numadj = numadj + 1
               numend = gearloc - 1
               numstart = verify(line(:gearloc - 1), '0123456789', back=.true.) + 1
               read (line(numstart:numend), *) partnums(numadj)
            end if
            if (scan(line(gearloc + 1:gearloc + 1), '0123456789') .ne. 0) then
               numadj = numadj + 1
               numstart = gearloc + 1
               numend = verify(line(gearloc + 1:), '0123456789') + numstart - 2
               read (line(numstart:numend), *) partnums(numadj)
            end if

            gearline = prevline(gearloc - 1:gearloc + 1)
            if (verify(gearline, '0123456789') .eq. 0) then
               numadj = numadj + 1
               numstart = gearloc - 1
               numend = gearloc + 1
               read (prevline(numstart:numend), *) partnums(numadj)
            end if
            if (scan(gearline, '0123456789', back=.true.) .eq. 1) then
               numadj = numadj + 1
               numend = gearloc - 1
               numstart = verify(prevline(:gearloc - 1), '0123456789', back=.true.) + 1
               read (prevline(numstart:numend), *) partnums(numadj)
            end if
            if (scan(gearline, '0123456789') .eq. 1 .and. &
                scan(gearline, '0123456789', back=.true.) .eq. 2) then
               numadj = numadj + 1
               numend = gearloc
               numstart = verify(prevline(:gearloc), '0123456789', back=.true.) + 1
               read (prevline(numstart:numend), *) partnums(numadj)
            end if
            if (scan(gearline, '0123456789') .eq. 2) then
               numadj = numadj + 1
               numstart = gearloc
               numend = verify(prevline(numstart:), '0123456789') + numstart - 2
               read (prevline(numstart:numend), *) partnums(numadj)
            end if
            if (scan(gearline, '0123456789') .eq. 3) then
               numadj = numadj + 1
               numstart = gearloc + 1
               numend = verify(prevline(numstart:), '0123456789') + numstart - 2
               read (prevline(numstart:numend), *) partnums(numadj)
            end if
            if (scan(gearline, '0123456789') .eq. 1 .and. &
                scan(gearline, '0123456789', back=.true.) .eq. 3 .and. &
                scan(gearline(2:2), '0123456789') .eq. 0) then
               numadj = numadj + 2
               numstart = gearloc + 1
               numend = verify(prevline(numstart:), '0123456789') + numstart - 2
               read (prevline(numstart:numend), *) partnums(numadj)
               numend = gearloc - 1
               numstart = verify(prevline(:numend), '0123456789', back=.true.) + 1
               read (prevline(numstart:numend), *) partnums(numadj - 1)
            end if

            gearline = nextline(gearloc - 1:gearloc + 1)
            if (verify(gearline, '0123456789') .eq. 0) then
               numadj = numadj + 1
               numstart = gearloc - 1
               numend = gearloc + 1
               read (nextline(numstart:numend), *) partnums(numadj)
            end if
            if (scan(gearline, '0123456789', back=.true.) .eq. 1) then
               numadj = numadj + 1
               numend = gearloc - 1
               numstart = verify(nextline(:gearloc - 1), '0123456789', back=.true.) + 1
               read (nextline(numstart:numend), *) partnums(numadj)
            end if
            if (scan(gearline, '0123456789') .eq. 1 .and. &
                scan(gearline, '0123456789', back=.true.) .eq. 2) then
               numadj = numadj + 1
               numend = gearloc
               numstart = verify(nextline(:gearloc), '0123456789', back=.true.) + 1
               read (nextline(numstart:numend), *) partnums(numadj)
            end if
            if (scan(gearline, '0123456789') .eq. 2) then
               numadj = numadj + 1
               numstart = gearloc
               numend = verify(nextline(numstart:), '0123456789') + numstart - 2
               read (nextline(numstart:numend), *) partnums(numadj)
            end if
            if (scan(gearline, '0123456789') .eq. 3) then
               numadj = numadj + 1
               numstart = gearloc + 1
               numend = verify(nextline(numstart:), '0123456789') + numstart - 2
               read (nextline(numstart:numend), *) partnums(numadj)
            end if
            if (scan(gearline, '0123456789') .eq. 1 .and. &
                scan(gearline, '0123456789', back=.true.) .eq. 3 .and. &
                scan(gearline(2:2), '0123456789') .eq. 0) then
               numadj = numadj + 2
               numstart = gearloc + 1
               numend = verify(nextline(numstart:), '0123456789') + numstart - 2
               read (nextline(numstart:numend), *) partnums(numadj)
               numend = gearloc - 1
               numstart = verify(nextline(:numend), '0123456789', back=.true.) + 1
               read (nextline(numstart:numend), *) partnums(numadj - 1)
            end if

            if (numadj .eq. 2) then
               write (*, *) trim(prevline)
               write (*, *) trim(line)
               write (*, *) trim(nextline)
               write (*, *) partnums(1), partnums(2)
               ratio = partnums(1) * partnums(2)
               totalgear_rat = totalgear_rat + ratio
            end if
            line(gearloc:gearloc) = '.'
         end do
      end do

      write (*, '(a,i0)') "total: ", total
      write (*, '(a,i0)') "total gear ratios: ", totalgear_rat
   end subroutine

   subroutine print_schematic(array)
      character, intent(in) :: array(:, :)
      character(10) :: format, arrszstr
      integer :: i, j, arrsize

      arrsize = size(array, dim=1)
      write (arrszstr, '(i0)') arrsize
      format = '('//trim(arrszstr)//'a1)'

      write (*, format) array
   end subroutine

   subroutine calc_schematic_size(filename, num_lines, line_size)
      character(256), intent(in) :: filename
      integer, intent(out) :: num_lines, line_size
      character(256) :: line
      integer :: error

      line_size = 0
      num_lines = 0
      open (unit=1, file=filename, iostat=error, status='old')
      if (error .ne. 0) stop

      do
         read (1, '(a)', iostat=error) line
         select case (error)
         case (0)
            line_size = line_size + 1
         case (iostat_end)
            exit
         case default
            write (*, *) "error reading file"
         end select
      end do
      num_lines = len_trim(line)
      close (1)
   end subroutine

   subroutine fill_schematic(filename, array)
      use, intrinsic :: iso_fortran_env, only: iostat_end
      character(256), intent(in) :: filename
      character, intent(inout) :: array(:, :)
      integer :: error, i

      open (1, file=filename, iostat=error)
      if (error .ne. 0) stop

      do i = 1, size(array, dim=1)
         read (1, '(256a1)', iostat=error) array(:, i)
         if (error .eq. iostat_end) exit
      end do
   end subroutine
end submodule aoc_day3

