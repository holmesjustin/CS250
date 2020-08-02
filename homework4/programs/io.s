.text
#test input, output instructions.
addi $r4, $r0, 0
addi $r4, $r4, 3

loop:
input $r1
addi $r2, $r1, -32
output $r2
addi $r4, $r4, -1
bne $r4, $r0, loop #run loop 3 times

halt
