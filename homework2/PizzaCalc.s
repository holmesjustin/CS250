
.text                           # Code segment
.align 2                        # ensure data segment items align to 2^2 = 4 bytes

.globl main                     # indicate that 'main' label is a function and not just an private inner label


main:                           # MAIN procedure Entrance


    li $t9, 0


_newPizza:

    subu $sp, $sp, 4
	sw	$ra, 0($sp)

    li $v0, 9           # allocate memory for new record
    li $a0, 72         
    syscall

    move $s0, $v0       # store the address of our allocated memory in $s0

    li.s $f1, 0.0       # set default PPD and print status values to zero
    s.s $f1, 64($s0)
    s.s $f1, 68($s0)


    # if s1 hasn't been set, set it to new record, otherwise do nothing (setting the header for the linked list pointer)
    bne $s1, $zero, _getInput
    move $s1, $s0


_getInput:

    # Printing out the name text
    li $v0, 4
    la $a0, name
    syscall

    li $v0, 8	        # read in the name from the user
	la $a0, ($s0) 	    # load address of newly allocated memory
    li $a1, 64
    move $s0, $a0       # save pizza name to s0
	syscall


    li $t1, 0xA         # Load in the new line character into t1
    move $t5, $s0

_checkNewLine:
    lb $t2, ($t5)        # Load character at index
    beq $t2, $t1, _removeNewLine
    addiu $t5, $t5, 1     # increment index
    j _checkNewLine 


_removeNewLine:
    sb $zero, ($t5)


_noNewLine:

    la $a1, done  # get address of done string

    li $t2, 0  # set index of t2 to zero for _checkIsDone


_checkIsDone:
    lb      $t2,($a0)                   # get next char from Input
    lb      $t3,($a1)                   # get next char from DONE
    bne     $t2,$t3, _notDone            # branch if input does not equal DONE

    beqz    $t2, _realPizza          # at the end of string (input is 'DONE')

    addi    $a0,$a0,1                   # point to next char
    addi    $a1,$a1,1                   # point to next char
    j       _checkIsDone


_notDone:

    # Diameter
    li $v0, 4   # Printing out the diameter text
    la $a0, diameter
    syscall

    li $v0, 6   # Getting diameter input
    syscall

    mov.s $f4, $f0   # Moving the diameter input to register f4

    # Price
    li $v0, 4    # Printing out the price text
    la $a0, price
    syscall
    
    li $v0, 6    # Getting price input
    syscall

    mov.s $f5, $f0    # Moving the price input to register f5


    # Calculate pizza per dollar

    li.s $f1, 0.0

    c.eq.s $f4, $f1
    bc1t skipPPD 

    c.eq.s $f5, $f1
    bc1t skipPPD 

    mul.s $f4, $f4, $f4  # calculate diameter squared and store in register f4
    
    l.s $f6, PI  # store pi in f6
    li.s $f7, 4.0  # store 4.0 in f7

    div.s $f6, $f6, $f7  # calculate Pi / 4 and store in register f6
    
    mul.s $f4, $f6, $f4  # calculate pizza area and store in register f4

    div.s $f4, $f4, $f5  # divide the area by the price and store in register f4

	s.s	$f4, 64($s0)	 # store pizza per dollar on stack

    # add	$s0, $s0, 4	     # increase by print float length

skipPPD:

    add $t9, $t9, 1      # increase counter by 1

    b _newPizza

    

_realPizza:

    sub $t9, $t9, 1     # pizza count minus one


_checkLoop:

    move $s2, $s1    # set s2 to head

    bltz $t0, exit   # if index is less than zero, exit

    li $t0, -1       # set index to -1

    li $t3, 0       # set I to zero

    li.s $f1, -1.0       # set min -1.0 and store in f1


checkCurrentPizza:

    bgt $t3, $t9, printRecord

    l.s $f2, 64($s2)

    c.lt.s $f2, $f1
    bc1t nextRecord 

    c.lt.s $f1, $f2
    bc1t isMaxValue 



    mul $t7, $t0, 72        # Beginning of index name
    mul $t8, $t3, 72        # Beginning of I name

    add $t7, $t7, $s1
    add $t8, $t8, $s1


strCmp:

    lb $t5,($t7)       # get next char from index pizza
    lb $t6,($t8)       # get next char from I record

    bgt $t6, $t5 nextRecord     # if character of I record is greater than index record, skip it.
    blt $t6, $t5 isMaxValue     # if character of I record is less than index record, set I record to max value.

    addi $t7, $t7,1          # point to next char
    addi $t8, $t8,1          # point to next char
    j strCmp


isMaxValue:

    l.s $f3, 68($s2)

    li.s $f5, 1.0

    c.eq.s $f3, $f5
    bc1t nextRecord 

    mov.s $f1, $f2

    move $t0, $t3


nextRecord:

    add $s2, $s2, 72     # offset to next pizza value

    add $t3, $t3, 1

    j checkCurrentPizza


printRecord:

    bltz $t0, exit

    move $s2, $s1

    mul $t0, $t0, 72

    add $s2, $s2, $t0
    
	li $v0, 4		# print pizza name
	la $a0, ($s2)	
	syscall	


    li $v0, 4		# print space after pizza name
	la $a0, space	
	syscall	
	
	li $v0, 2	# print pizza per dollar value
	l.s $f12, 64($s2)
	syscall

    li.s $f3, 1.0

    s.s $f3, 68($s2)


    li $v0, 4		# print new line after pizza/dollar value
	la $a0, nln	
	syscall	

    jr _checkLoop


exit:
    jr $ra


.data                           # Start of data segment

buffer: .space 64
name:  .asciiz "Pizza Name: "
diameter:  .asciiz "Pizza Diameter: "
price:  .asciiz "Pizza Price: "
done: .asciiz "DONE"
space: .asciiz " "
nln: .asciiz "\n"
PI: .float 3.14159265358979323846
zero: .float 0.0

