.text
# test not, xor instrctions

#not
addi $r1, $r0, 15		# 0x000f
addi $r2, $r0, 12		# 0x000c
not $r3, $r1            # ~0x000f == 0xfff0
not $r4, $r3            # ~0xfff0 == 0x000f
not $r5, $r2            # ~0x000c == 0xfff3
 
#xor
xor $r6, $r2, $r1       # 0xf ^ 0xc == 0x3

halt

.data
