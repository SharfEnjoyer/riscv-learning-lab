.text
.global _start


_start:
	addi x5, x0, 100
	addi x6, x0, 50
	sub  x7, x5, x6
    beq  x6, x7, _start
    sw x5, 0(x0)
    addi x5, x0, 70
    lw x5, 0(x0) 
    add x7, x6, x5
    jal x6, _start
	
	
    
