! Exponential growth? I barely know her
program part1
    implicit none

    integer, allocatable :: inputs(:)
    integer :: num_zeros
    integer :: day = 0;
    integer :: i;

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
    ! inputs = [3,4,3,1,2]

    do while (day < 80)
        i = 1
        num_zeros = 0
        do while (i <= size(inputs))
            inputs(i) = inputs(i) - 1

            if (inputs(i) < 0) then
                num_zeros = num_zeros + 1
                inputs(i) = 6
            end if
            i = i + 1
        end do

        do while (num_zeros > 0)
            inputs = [inputs, 8]
            num_zeros = num_zeros - 1
        end do
        day = day + 1
        print *, day
    end do

    print *, size(inputs)
end program part1
