.text
.global _start


_start:
	addi x5, x0, 100
	addi x6, x0, 50
	sub  x7, x5, x6
    jal _start  # jump to _start and save position to ra
    
