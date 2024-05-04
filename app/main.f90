program main
  use aoc
  implicit none
  integer :: runfile


  write(*,*) "input day to run"
  read(*,*) runfile
  call chdir('res')

  select case ( runfile )
  case(1)
      call day1
  case(2)
      call day2
  case(3)
      call day3
  case(4)
      call day4
  case(5)
      call day5
  case(6)
      call day6
  case(7)
      call day7
  case(8)
      call day8
  case(9)
      call day9
  case(10)
      call day10
  case(11)
      call day11
  case default
      write(*,*) "day isn't implemented"
  end select
end program main
