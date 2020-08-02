
.text                           # Code segment
.align 2                        # ensure data segment items align to 2^2 = 4 bytes

.globl main                     # indicate that 'main' label is a function and not just an private inner label
main:                           # MAIN procedure Entrance
    
    # Printing out the text
    li $v0, 4
    la $a0, input
    syscall

	# Getting user input
    li $v0, 5
    syscall

    # Moving the integer input to register t1
    move $t1, $v0

    # t0 is pointer that walks through list
    li $t0, 0

    # set t2 as seven because that is the first possible output
    li $t2, 7

    
loop:
    beq     $t0, $t1, exit # if t0 is equal to t1, go to exit

    li      $v0, 1  
    move    $a0, $t2
    syscall

    # print the value of t2 (which was moved into a0)

    li      $v0, 4 
    la      $a0, nln 
    syscall

    addi    $t0, $t0, 1 # add one to t0
    addi    $t2, $t2, 7 # add 7 to t2
    
    b       loop              # go to top of loop

exit:
    jr $ra
    
.end main                       #  end of main function


.data                           # Start of data segment


nln:    .asciiz "\n"
input:  .asciiz "Enter a number:"

