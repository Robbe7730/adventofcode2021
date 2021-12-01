SYS_READ = 0
SYS_WRITE = 1
SYS_EXIT = 60

STDIN_FILENO = 0
STDOUT_FILENO = 1

.data
.global start
write_buffer:   .quad '0'
read_buffer:    .quad '0'
count:          .quad 0
first_window:   .quad 0
second_window:  .quad 0
third_window:   .quad 0

.text
start:
    call read_number
    mov %rax, first_window

    call read_number
    add %rax, first_window
    add %rax, second_window

    call read_number
    add %rax, first_window
    add %rax, second_window
    add %rax, third_window

    .start_loop:
    call read_number
    cmp $0, %rax
    je .start_end

    add %rax, second_window
    add %rax, third_window

    mov second_window, %rdx
    cmp first_window, %rdx

    jle .not_increased
    incq count
    .not_increased:

    mov second_window, %rdx
    mov %rdx, first_window

    mov third_window, %rdx
    mov %rdx, second_window

    mov %rax, third_window

    cmp $0, %rax
    jne .start_loop

    .start_end:
    mov count, %rax
    call print_number

    mov $SYS_EXIT, %eax
    mov $0, %edi
    syscall

read_number:
    mov $0, %r8

    .read_number_loop:
    mov $SYS_READ, %rax
    mov $STDIN_FILENO, %rdi
    mov $read_buffer, %rsi
    mov $1, %rdx
    syscall

    mov read_buffer, %al
    cmp $10, %al
    je .read_number_end

    mov $10, %rax
    mul %r8
    mov %rax, %r8

    mov $0, %rax
    mov read_buffer, %al
    sub $'0', %al
    add %rax, %r8

    jmp .read_number_loop

    .read_number_end:
    mov %r8, %rax
    ret

print_number:
    cmp $0, %rax
    jne not_zero

    mov $'0', %al
    mov %eax, write_buffer
    mov $SYS_WRITE, %eax
    mov $STDOUT_FILENO, %edi
    mov $write_buffer, %esi
    mov $1, %edx
    syscall
    jmp print_number_exit

    not_zero:

    mov %rax, %r8

    mov $0, %rdx
    mov $1000000, %rax

    leading_zeros_loop:
        mov $0, %rdx
        mov $10, %ecx
        idiv %ecx

        cmp %rax, %r8
        jge leading_zeros_exit
        jmp leading_zeros_loop

    leading_zeros_exit:

    mov %rax, %r9

    print_loop:
        mov $0, %rdx
        mov %r8, %rax
        idiv %r9

        mov %rdx, %r8

        addb $'0', %al
        mov %eax, write_buffer

        mov $SYS_WRITE, %eax
        mov $STDOUT_FILENO, %edi
        mov $write_buffer, %esi
        mov $1, %edx
        syscall

        mov $0, %edx
        mov %r9, %rax
        mov $10, %ecx
        idiv %ecx
        mov %rax, %r9

        cmp $1, %r9
        jge print_loop

    print_number_exit:
    mov $'\n', %al
    mov %eax, write_buffer
    mov $SYS_WRITE, %eax
    mov $STDOUT_FILENO, %edi
    mov $write_buffer, %esi
    mov $1, %edx
    syscall
    ret

