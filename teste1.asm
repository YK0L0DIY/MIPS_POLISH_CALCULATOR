.data
	stack: .space 84 #array will hold 20 integers
	prompt: .asciiz "Postfix (input) : "
	error: .asciiz "Too many tokens"
	error2: .asciiz "Invalid postfix"
	error3: .asciiz "Divide by zero"
	result: .asciiz "Postfix Evaluation (output): "
	errorPostfix: .asciiz "Invalid Postfix \n Stack: "
	newLine: .asciiz "\n"
.text
	#final static int MAX = 20
	addi $s0, $zero, 20 #s0 = MAX
	#static int i=0
	addi $s1, $zero, 0

  	#Print prompt
	li $v0, 4
	la $a0, prompt
	syscall
	
	
   do_while:
   	# Get next char
   	jal charGetter
   	nop
   	
   	bne $t0, 32 , notSpace
   	nop
   	j do_while
   	nop
   	
   notSpace:
   	addi $t2, $zero ,0 # number($t2) =0
   	
   while:
   	blt $t0, 48, exitWhile #Conditions
   	nop
   	bgt $t0, 57, exitWhile
   	nop
   	
   	
   	mul $t2, $t2, 10 # number = 10*number + (ch-48)
   	sub $t0, $t0, 48
   	add $t2, $t2, $t0
   	
  	jal charGetter
  	nop
  	j while
  	nop
   exitWhile:
   	
   	beq $t0, 43, if_body # if  ((ch == '+') 
   	nop
   	beq $t0, 45, if_body # || (ch == '-')
   	nop
   	beq $t0, 42, if_body # ||(ch == '*')
   	nop
   	beq $t0, 47, if_body # ||(ch == '/')) 
   	nop
   	b else_if #go to else_if
   	nop
   	
   if_body:
   	jal pop #call pop() function 
   	move $t4, $v0 # move the return value stored in $v0 to $t4=x2
   	jal pop #pop()
   	move $t3, $v0 # move the return value stored in $v0 to $t3=x1
   	jal calc # calc()
   	move $t2, $v0
   	jal push
   	
   	j do_while
   	
   else_if:
   	#(ch != '=')
   	bne $t0, 61, push_method_accessor
   	b continue_without_pushing
   push_method_accessor:
   	jal push
   continue_without_pushing:
   	beq $t0, 61, exit_doWhile
   	j do_while
   	

   
   	
   	
   exit_doWhile:
   	beq $s1, 1, printResult
   	
   	#Print else: " Invalid postfix" and "Stack: "
   	li $v0, 4
   	la $a0, errorPostfix
   	syscall
   	
   	addi $t7, $zero, 0
   	b printStackLoop
   
   exitProgram:
   	li $v0,10
   	syscall
   
   printStackLoop:
   	bgt $s2, 19, exitProgram
   		
   	addi $s2, $s2, 1
   	
   	li $v0, 4
   	la $a0, newLine
   	syscall
   	
   	lw $t6, stack($t7) #Retrieves stack elements
		addi $t7, $t7, 4 #Gets ready to retrieve the next stack element
	# Print Result
	li $v0, 1
   	addi $a0, $t6, 0
   	syscall
	
	j printStackLoop
	
	
   printResult:
   	#Print: Postfix Evaluation (output):
   	li $v0, 4
   	la $a0, result
   	syscall
   	
   	lw $t6, stack($zero) #retrieve first stack element
   	#Print Result
   	li $v0, 1
   	addi $a0, $t6, 0
   	syscall
   	
	b printStackLoop
    charGetter:
	#Get the users input(ch)
	li $v0, 12
	syscall
	
	#Store input in $t0
	move $t0, $v0
	
   	jr $ra	 
   	nop	 	 	 	
   	 	 	 	 	 	
   	 	 	 	 	 	 	
   	 	 	 	 	 	 	
   	 	 	 	 	 	 	 	 	 	
   push:
   	beq $s1, $s0, error_overflow
   	sw $t2 , stack($t7)#p[i] = result
   		addi $t7, $t7, 4  #go to space for next int
   	addi $s1, $s1, 1 # i++
   	
 
   	jr $ra
   pop:
   	addi $t7, $t7, -4
   	
   	beq $s1, $zero, error_underflow
   	lw $v0, stack($t7)
   		
   	addi $s1, $s1, -1 # i--
   
   	jr $ra
   calc:
   	addi $t5, $zero ,0
   	#Switch - cases :
   	beq $t0 ,43, c1_body
   	beq $t0, 45, c2_body
   	beq $t0, 42, c3_body
   	beq $t0, 47, c4_body
   
   exit:		
   	addi $v0, $t5, 0
   	
   	jr $ra			
   c1_body:		
   	#total($t5) = x1+x2; break;
	add $t5, $t3, $t4 
	j exit # change exit later on MArios
	
   c2_body:
   	#total= x1-x2; break;
   	sub $t5, $t3, $t4
   	j exit # change exit later on MArios
   
   c3_body:
   	#total= x1*x2; break;
   	mul $t5, $t3,$t4
	j exit # change exit later on MArios	
	
   c4_body:
   	#if (x2 != 0) total = x1/x2
	beq $t4 , $zero, error_divideByZero		
   	div $t5, $t3, $t4
   	j exit

   	
   error_overflow:
   	#Print error
   	li $v0, 4
   	la $a0, error
   	syscall
   	#System exit
   	li $v0,10
   	syscall
   		
   error_underflow:
   	#Print error
   	li $v0, 4
   	la $a0, error2
   	syscall
   	#System exit
   	li $v0,10
   	syscall

   error_divideByZero:
   	#Print error
   	li $v0, 4
   	la $a0, error3
   	syscall
   	#System exit
   	li $v0,10
   	syscall