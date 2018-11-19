.data
	layout: .asciiz "Calculadora em notacao polaca inversa\nAutores: Yaroslav Kolodiy (39859) e Eduardo Medeiros (39873)\nASC1 2017/2018\n"
	
	index: .asciiz "\n-> "
	newLine: .asciiz "\n"
	space: .asciiz " "
	
	textPilha: .asciiz "\nPilha:\n"
	pilha: .space 256
	empty: .asciiz "(vazio)\n"
	
	input: .space 256
	
.text
.globl main

####################################################

print_pilha:
	move $t0,$s1 #tamanho
	la $t1,pilha
	
	li $v0,4
	la $a0,textPilha
	syscall
	
	bne $t0,$zero,NOT_EMPTY
	nop
	la $a0,empty
	syscall
	
	jr $ra
	nop
	
	NOT_EMPTY:
		li $t2,0 #contador de elemntos impressos
	
	printNum:
		li $v0,1
		lb $a0,0($t1) #print do numero
		syscall
	
		addi $t2,$t2,1 #contador mais 1
		addi $t1,$t1,2 #proximo elemnto do array
	
		li $v0,4
		la $a0,newLine
		syscall
	
		bne $t2,$t0,printNum
	
	jr $ra
	nop
	
##########################################################

makeInput:
	li $v0,4
	la $a0,index #pritn do cursor
	syscall
	
	li $v0,8
	la $a0, input #recebe o input do utilizador e guarda em "input"
	li $a1,64
	syscall
	
	jr $ra
	nop
	
##################################################################
# adiciona $a0 e $a1 e devolve em v0
# guardando o rsultado no ulttimo lugar da pilha
sum:
	addi $s0,$s0,-4 #decrementa a pilha num endereço
	add $v0,$a0,$a1
	addi $s1,$s1,-1 #decrementa o numero de elentos na pilha
	sb $v0,0($s0)
	addi $s0,$s0,2
	jr $ra
	nop
##################################################################
# é a puta da pilha é decrementada na puta do jal
subt:
	addi $s0,$s0,-4 #decrementa a pilha num endereço
	sub $v0,$a0,$a1
	addi $s1,$s1,-1 #decrementa o numero de elentos na pilha
	sb $v0,0($s0)
	addi $s0,$s0,2
	jr $ra
	nop
##################################################################

runInput:
	addi $sp,$sp,-4
	sw $ra,0($sp) #guardar o endreço de retorno
	la $t0,input #recebe o enderesso do input
	#s1 continua a ser o numero de elementos na pilha
	
	inputLoop:
		lb $t1,0($t0) #recebe o char da posicao $t1 do input
		
		beq $t1,$zero,END
		nop
		
		beq $t1,0xa,END
#se for so a ent duplica 3#######E#E#D#ED ex se for 10 e depois o 0 ele duplica se input for igual so nel e space dup
		nop
		
		beq $t1,' ',inputLoop
		addi $t0,$t0,1
		
		#testar se e numero ou expereçao
		bne $t1,'+',case2
		nop
			
			lb $a0,-4($s0)#carrega o penultimo endereço da pilha
			lb $a1,-2($s0)#carrega o ultimo endereco da pilha
			
			jal sum
			nop
			
			j inputLoop #volta para crrer o resto do input 
			nop
		case2:
		bne $t1,'-',case3
		nop
			lb $a0,-4($s0)#carrega o penultimo endereço da pilha
			lb $a1,-2($s0)#carrega o ultimo endereco da pilha
			
			jal subt
			nop
			
			j inputLoop #volta para crrer o resto do input 
			nop
		
		case3:
		
		
		subi $t1,$t1,0x30 #converte para numero real(decimal)
		
		lb $t8,0($t0)
		beq $t8,0,save
		nop
		beq $t8,10,save
		nop
		bne $t8,' ',mult10
		nop
		
		save:
		sb $t1,0($s0)
		addi $s1,$s1,1
		addi $s0,$s0,2
		
		j inputLoop
		nop
		
		mult10: #converte o numero se for superio a 1 unidade
			subi $t8,$t8,0x30
			mulo $t9,$t1,10
			addu $t1,$t9,$t8
			addi $t0,$t0,1
			lb $t8,0($t0)
			beq $t8,0,SAVE
			nop
			beq $t8,10,SAVE
			nop
			bne $t8,' ',mult10
			nop
			
			SAVE:
				sb $t1,0($s0)
				addi $s1,$s1,1
				addi $s0,$s0,2
				
				j inputLoop
				nop
		
		sb $t1,0($s0)
		addi $s1,$s1,1
		addi $s0,$s0,2
				
		j inputLoop
		nop
			
	END:
	lw $ra,0($sp)
	addi $sp,$sp,4
	jr $ra
	nop
		
##################################################################

main:
	li $v0,4
	la $a0,layout #escricao inicial
	syscall
	
	la $s0,pilha #endereço da pilha
	move $s1,$zero #contador de elemntos da pilha
	
	mainLoop: #estar sempre a correr
	
	#chama print da piulha
	jal print_pilha
	nop
	
	#chama funcao de input
	jal makeInput
	nop
	
	#correr o input do utilizador 
	jal runInput
	nop
	
	j mainLoop
	nop
