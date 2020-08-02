
.text                           # Code segment
.align 2                        # ensure data segment items align to 2^2 = 4 bytes

.globl main                     # indicate that 'main' label is a function and not just an private inner label


main:                           # MAIN procedure Entrance

    subu $sp, $sp, 8
	sw $ra, 0($sp)

    # Printing out the text
    li $v0, 4
    la $a0, input
    syscall

    # Getting user input
    li $v0, 5
    syscall

    # Moving the integer input to register a0
    move $a0, $v0

    jal fun

    move $a0, $v0    # move result of fun to $a0

    # print final value
    li  $v0, 1
    syscall

    lw $ra, ($sp)
	addu $sp, $sp, 8

    jr $ra

#---------------------------------------------------------------------

fun:

    subu $sp, $sp, 8  # prepare stack for 2 values
    sw $ra, ($sp)  # store the return address 

    # Base case
    li $v0, 2  # return 2 if the argument passed is zero (n = 0)
    beq $a0, $zero, fun_return  # branch to return if N is equal to zero.

    sw $a0, 4($sp)     # save the value of n
    subu $a0, $a0, 1   # set n to n-1
    
    jal fun  # jump and link to function

    addu $v0, $v0, 1    # add one to output

    lw $t0, 4($sp)   # get the value of n
    subu $t1, $t0, 1   # save the value of n-1 in t1

    mul $t2, $t1, 3   # calculate the value of 3(n-1) and store it in t2

    addu $v0, $t2, $v0  # add 3*n-1 to $v0

    b fun_return
    

fun_return:

    lw $ra ($sp)   # load return address
    addu $sp, $sp, 8   # clear stack
    jr $ra


.data                           # Start of data segment


input:  .asciiz "Enter a number greater than zero:"
number: .word 0
answer: .word 0

