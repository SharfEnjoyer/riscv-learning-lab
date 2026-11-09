.text
.global _start


_start:
	addi x5, x0, 100
	addi x6, x0, 50
	sub  x7, x5, x6
    beq  x6, x7, _start
    #jal _start
	
	
    
