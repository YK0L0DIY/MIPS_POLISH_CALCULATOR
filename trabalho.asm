.data
	.p2align 2
	layout: .asciiz "Calculadora em notação polaca inversa\n"
	layout1: .asciiz "Autores: Yaroslav Kolodiy (39859) e Eduardo Medeiros (39873)\n"
	layout2: .asciiz "ASC1 2017/2018\n"
	
	textin: .asciiz "\n-> "
	vazio: .asciiz "(vazio)\n"
	newline: .asciiz "\n"
	space: .asciiz " "
	
	textPilha: .asciiz "\nPilha:\n"
	pilha: .space 220
	
	input: .space 220
	
.text
.globl main

# adiciona $a0 e $a1 e devolve em v0
# guardando o rsultado no ulttimo lugar da pilha
sum:
	add $v0,$a0,$a1
	addi $s6,$s6,-1
	jr $ra
	sw $v0,0($s7)

# multiplica $a0 e $a1 e devolve em v0
# guardando o resultado no ultimo lugar da pilha
multiplicacao:
	mult $a0,$a1
	mflo $v0
	jr $ra
	sw $v0,0($s7)

# divide $a0 e $a1 e devolve em v0
# guardando o resultado no ultimo lugar da pilha
divisao:
	div $a0,$a1
	mflo $v0
	jr $ra
	sw $v0,0($s7)

# recebe o ultimo valor da pilha e calcula o seu simetrico
# guardando o resultado no ultimo lugar da pilha
negacao:
	sub $v0,$zero,$a0
	jr $ra
	sw $v0,0($s7)

# é a puta da pilha é decrementada na puta do jal
subt:
	sub $v0, $a0, $a1
	addi $s6,$s6,-1
	jr $ra
	sw $v0, 0($s7)

# recebe o endereço do penultimo e ultimo endereço respetivamente em $a0 e $a1
swap:
	lw $t0,0($a0)
	lw $t1,0($a1)
	sw $t1,0($a0)
	jr $ra
	sw $t0,0($a1)


#logo a seguir ao jal del fica: addi $s1, $s1, -4
del:
	jr $ra
	nop


clear:
	jr $ra
	move $s1, $s0

# recebe o endereço do ultimo endereço
dup:
	lw $at,0($a0)
	addi $s1,$s1,1
	jr $ra
	sw $at,0($s1)


off:
	addi $v0, $zero, 10
	syscall
	
	#t0 = s0, t1 = s1
	
convert:
	addi $a0,$a0,-2
	add $t0, $zero, $zero
	
	move $t1,$a0
	
	li $t3, 0x20 
	li $t4, 0xa
	li $t5, 1
	
	#=====================================================#
	WHILE:
	lb $t2, 0($t1)
	
	beq $t2, $zero, END
	nop
	
	#=====================================================#
	NUM_SIZE:
	beq $t2, $t3, MULTIPLIERS
	addi $t1, $t1, 1
	addi $t0, $t0, 1
	
	j WHILE
	nop
	
	#=====================================================#
	MULTIPLIERS:
	sub $t6, $t0, $t5
	
	addi $sp, $sp, -4
	sw $t5, 0($sp)
	
	TAG:
	mult $t5, $t4
	mflo $t5
	
	addi $sp, $sp, -4
	sw $t5, 0($sp)
	
	addi $t6, $t6, -1
	bne $t2, $zero, TAG
	nop
	
	#=====================================================#
	sub $t1, $t1, $t0
	
	NUM:
	lb $t2, 0($t1)
	
	beq $t2, $t3, SUM
	addi $t1, $t1, 1
	subi $t2, $t2, 0x30
	
	lw $t7, 0($sp)
	mult $t2, $t7
	mflo $at
	sw $at, 0($sp)
	
	j NUM
	addi $sp, $sp, 1
	
	
	
	#=====================================================#
	SUM:
	add $sp, $sp, $t0
	beq $t0, $zero, END
	addi $t0, $t0, -1
	
	lw $t8, 0($sp)
	lw $t9, 4($sp)
	
	add $t8, $t8, $t9
	addi $sp, $sp, -4
	sw $t8, 0($sp)
	
	j SUM
	nop
	
	#=====================================================#
	END:
	jr $ra
	lw $v0,0($sp)
	
	
main:
	li $v0,4
	la $a0,layout
	syscall
	
	li $v0,4
	la $a0,layout1
	syscall
	
	li $v0,4
	la $a0,layout2
	syscall
	
	#contador de elemntos na pilha
	move $s7,$zero


loop:	
	#cursor
	li $v0,4
	la $a0,textin
	syscall
	
	#recebe input	
	li $v0,8
	la $a0, input
	li $a1,60
	syscall
	
	#adress da pilha
	la $s7,pilha
	#numero de elemntos na pilha
	move $s6,$zero
	
	#loop corer string input guardando o valor em t1
	
	la $t0,input
	la $s1,pilha
	
	correr_input:
	
	lb $t1,0($t0)
	#verificar se nao e null
	beq $t1,0x00,loop
	nop
	#verificar se nao e new line
	beq $t1,0x0a,loop
	addi $t0,$t0,1
	#verificar se nao e espaço
	beq $t1,32,correr_input
	nop
	
	
	#print do caracter
	li $v0,1
	move $a0,$t1
	syscall
	
	#verificar se e soma
	bne $t1,'+',L1
	nop
	lw $a0,-4($s7)
	lw $a1,0($s7)
	jal sum
	addi $s7,$s7,-4
	j correr_input #errado tem de dar print da pilha
	nop
	
L1:
	
	#verificar se e subtracao
	bne $t1,'-',L2
	nop
	lw $a0,-4($s7)
	lw $a1,0($s7)
	jal subt
	addi $s7,$s7,-4
	j correr_input #errado tem de dar print da pilha
	nop
	
L2:	
	#verificar se e multiplicaçao
	bne $t1,'*',L3
	nop
	lw $a0,-4($s7)
	lw $a1,0($s7)
	jal multiplicacao
	addi $s7,$s7,-4
	j correr_input #errado tem de dar print da pilha
	nop
	
L3:	
	#verificar se e divisao
	bne $t1,'/', L4
	nop
	lw $a0,-4($s7)
	lw $a1,0($s7)
	jal divisao #errado tem de dar print da pilha
	addi $s7,$s7,-4
	j correr_input
	nop
	
	
L4:
	#verificar se e negacao
	bne  $t1,'n',L5
	addi $t0,$t0,2
	#se««ir verificando se for etra certa ou nao se nao for decrementa se o contador la letra(endereço_) e vai para correr input
	
	
	
L5:
	#verificar se e swap
	bne  $t1,'s',L6
	addi $t0,$t0,3
	
	
	

L6:
	
	#verificar se e off
	bne  $t0,'o',L7
	nop
	
	
	
	
L7:
	#verificar se tem d
	#por fazer
	
	
	
	

L8:
	blt $t1,'0',correr_input
	nop
	bgt $t1,'9',correr_input
	nop
	
	subi $v0,$t1,30
	lb $t9,0($t2)
	bne $t9,' ',convert
	#envia o registro para a funcao
	move $a0,$t2
	
	#$v0 tem o valor a guardar na pilha
	
	sw $v0,0($s7)
	addi $s7,$s7,4
	addi $s6,$s6,1
	
	#criar funcao de dar print da pilha
	
	
	#print new line
	la $a0,newline
	li $v0,4
	syscall
	
	#voltar ao ciclo do input
	j correr_input
	nop
	
	
	
	
	
	
	
	
