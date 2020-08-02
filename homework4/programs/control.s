.text
# test blt, bne, jal, j, jr instructions
# if $r6 is ever non-zero, something screwed up. (other failure conditions are also possible, of course)
addi $r1, $r0, 15
addi $r2, $r0, 16
addi $r3, $r0, 10

blt $r2, $r1, fail          #branch is *NOT* taken
blt $r1, $r2, less_than     #branch is taken
addi $r6, $r0, 20           #shouldn't be executed
halt                        #shouldn't be executed

less_than:
jal my_func                 #procedure call
bne $r1, $r3, fail          #branch is *NOT* taken
bne $r1, $r0, unequal       #branch is taken
addi $r6, $r0, 21           #shouldn't be executed
halt                        #shouldn't be executed

my_func:
addi $r1, $r1, -5           #make $r1 equal to 10
jr $r7                      #return
addi $r6, $r0, 22           #shouldn't be executed
halt                        #shouldn't be executed

unequal:
j end                       #jump to end
addi $r6, $r0, 23           #shouldn't be executed

end:
halt

fail:
# should never reach here
addi $r6, $r0, 24           #shouldn't be executed
halt                        #shouldn't be executed

.data
