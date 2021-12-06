program part2
    use, intrinsic :: iso_fortran_env, only: sp=>int32, dp=>int64
    implicit none

    integer, allocatable :: inputs(:)
    integer(dp) :: num_zeros
    integer :: day = 0;
    integer :: i;
    integer :: j;
    integer(dp) :: ret;
    integer(dp) :: counts(9)

    inputs = [1,1,1,1,1,5,1,1,1,5,1,1,3,1,5,1,4,1,5,1,2,5,1,1,1,1,3,1,4,5,1,1,2, &
              1,1,1,2,4,3,2,1,1,2,1,5,4,4,1,4,1,1,1,4,1,3,1,1,1,2,1,1,1,1,1,1,1, &
              5,4,4,2,4,5,2,1,5,3,1,3,3,1,1,5,4,1,1,3,5,1,1,1,4,4,2,4,1,1,4,1,1, &
              2,1,1,1,2,1,5,2,5,1,1,1,4,1,2,1,1,1,2,2,1,3,1,4,4,1,1,3,1,4,1,1,1, &
              2,5,5,1,4,1,4,4,1,4,1,2,4,1,1,4,1,3,4,4,1,1,5,3,1,1,5,1,3,4,2,1,3, &
              1,3,1,1,1,1,1,1,1,1,1,4,5,1,1,1,1,3,1,1,5,1,1,4,1,1,3,1,1,5,2,1,4, &
              4,1,4,1,2,1,1,1,1,2,1,4,1,1,2,5,1,4,4,1,1,1,4,1,1,1,5,3,1,4,1,4,1, &
              1,3,5,3,5,5,5,1,5,1,1,1,1,1,1,1,1,2,3,3,3,3,4,2,1,1,4,5,3,1,1,5,5, &
              1,1,2,1,4,1,3,5,1,1,1,5,2,2,1,4,2,1,1,4,1,3,1,1,1,3,1,5,1,5,1,1,4, &
              1,2,1]
    !inputs = [3,4,3,1,2]

    i = 1
    do while (i <= 9)
        counts(i) = 0_dp
        i = i + 1
    end do

    i = 0
    do while (i < size(inputs))
        i = i + 1
        counts(inputs(i) + 1) = counts(inputs(i) + 1) + 1_dp
    end do

    day = 0
    do while (day < 256)
        num_zeros = counts(1)
        j = 1
        do while (j <= 9)
            counts(j) = counts(j + 1)
            j = j + 1
        end do
        counts(9) = num_zeros
        counts(7) = counts(7) + num_zeros
        day = day + 1
    end do

    ret = 0
    i = 1
    do while (i <= size(counts))
        ret = ret + counts(i)
        i = i + 1
    end do
    print *, ret
end program part2
