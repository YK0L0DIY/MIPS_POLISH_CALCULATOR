.data

	layout: .asciiz "Calculadora em notacao polaca inversa\nAutores: Yaroslav Kolodiy (39859) e Eduardo Medeiros (39873)\nASC1 2017/2018\n"
	erro2: .asciiz "a pilha tem de ter pelo menos 2 elementos\n"
	erro1: .asciiz "a pilha tem de ter pelo menos 1 elementos\n"
	notnumber: .asciiz "o input do numero esta invalido\n"
	div0: .asciiz "nao pode dividir por 0\n"
	
	
	index: .asciiz "\n-> "
	newLine: .asciiz "\n"
	space: .asciiz " "
		
	textPilha: .asciiz "\nPilha:\n"
	pilha: .space 256
	empty: .asciiz "(vazio)\n"
		
	input: .space 256
	
	ret2:	.word 0

.text
.globl main

####################################################

print_pilha:
	move $t0,$a0 #tamanho
	la $t1,pilha #endereço do primeiro elemento da pilha
	
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
		lw $a0,0($t1) #print do numero
		syscall
	
		addi $t2,$t2,1 #contador mais 1
		addi $t1,$t1,4 #proximo elemnto do array
	
		li $v0,4
		la $a0,newLine
		syscall
	
		bne $t2,$t0,printNum
	
	jr $ra
	nop
	
	
##########################################################
#recebe o input do utilizador
makeInput:
	li $v0,4
	la $a0,index #print do cursor "->"
	syscall
	
	li $v0,8
	la $a0, input #recebe o input do utilizador e guarda em "input"
	li $a1,64
	syscall
	
	jr $ra
	nop
	
##################################################################
# adiciona $a0 e $a1 e devolve em v0
#a0 penultimo elemento da pilha
#a1 ultimo elemento da pilha
# guardando o resultado no ulttimo lugar da pilha
sum:
	add $v0,$a0,$a1
	jr $ra
	nop
################################################################### 
#subtrai $a0 e $a1 e devolve em v0
# guardando o resultado no ulttimo lugar da pilha
subt:
	sub $v0,$a0,$a1
	jr $ra
	nop
##################################################################
# multiplica $a0 e $a1 e devolve em v0
# guardando o resultado no ultimo lugar da pilha
multi:
	mult $a0,$a1
	mflo $v0
	jr $ra
	nop
##################################################################
# divide $a0 e $a1 e devolve em v0
# guardando o resultado no ultimo lugar da pilha
divi:
	div $a0,$a1
	mflo $v0
	jr $ra
	nop
##################################################################
# duplica o ultimento elemnto da pilha
dup:	
	
	lw $t1,-4($a0)
	sw $t1,0($a0)
	jr $ra
	nop

##################################################################
#desliga a calculadora
off:
	li $v0, 10
	syscall
	nop
	
##################################################################
#inverte o ultimo numero da pilha
negacao:
	lw $t1,-4($a0)
	sub $t1,$zero,$t1
	sw $t1,-4($a0)
	jr $ra
	nop
	
##################################################################
#troca os dois ultimos elementos da pilha de posicoes
swap:
	lw $t2,-8($a0)
	lw $t1,-4($a0)
	sw $t1,-8($a0)
	sw $t2,-4($a0)
	jr $ra
	nop

##################################################################
#nao permite a execucao de operacoes binarias caso o numero de
#elementos da pilha seja inferior a 2
ERROR2:
	la $a0,erro2
	li $v0,4
	syscall
	jr $ra
	nop

##################################################################
#nao permite a execucao de operacoes unarias caso o numero de
#elementos da pilha seja inferior a 1
ERROR1:
	la $a0,erro1
	li $v0,4
	syscall
	jr $ra
	nop

##################################################################
#nao guarda uma entrada que seja invalida
NOTVALIDENTRY:
	la $a0,notnumber
	li $v0,4
	syscall
	j END
	nop

##################################################################
#dividir por 0 e impossivel
ERRORDIV:
	la $a0,div0
	li $v0,4
	syscall
	j END
	nop

##################################################################
#percorre o input dado
runInput:
	addi $sp,$sp,-20
	sw $s0,16($sp)
	sw $s1,12($sp)
	sw $s2,8($sp) 
	sw $s3,4($sp)
	sw $ra,0($sp) #guardar o endreco de retorno
	
	move $s1,$a1 #numero de elemntos da pilha
	move $s0,$a0 #endereço do ultimo elemnto
	
	li $s2,2 #controlador de elementos 2
	li $s3,1 #controlador de elementos 1	
	
	#######################################	
	la $t0,input #recebe o enderesso do input
	lb $t2, 0($t0)
	
	bne $t2, 0xa, inputLoop
	nop
	
	lb $t2, 2($t0)
	
	bne $t2, 0x00, inputLoop
	nop
	
	#duplica
	move $a0,$s0
	jal dup
	nop
	addi $s0,$s0,4
	addi $s1,$s1,1
	
	j END
	nop
	
	inputLoop:
		lb $t1,0($t0) #recebe o char da posicao $t1 do input
		
		beq $t1,$zero,END
		nop
			
		beq $t1,0xa,END
		#se for so "a" ent duplica, ex se for 10 e depois o 0 ele duplica se input for igual so nel e space dup (BUGGED)
		nop
		
		beq $t1,' ',inputLoop
		addi $t0,$t0,1
		
		#testar se e numero ou experecao
		bne $t1,'+',case2
		nop
			bge $s1,$s2,NOTERROR2
			nop
				jal ERROR2
				nop
				j END
				nop
				
			NOTERROR2:
			lw $a0,-8($s0)#carrega o penultimo endereco da pilha
			lw $a1,-4($s0)#carrega o ultimo endereco da pilha
			
			
			jal sum
			nop
			
			addi $s0,$s0,-4
			addi $s1,$s1,-1
			
			sw $v0,-4($s0)
			
			j inputLoop #volta para correr o resto do input 
			nop
		case2:
		bne $t1,'-',case3
		nop
			bge $s1,$s2,NOT_ERROR2m
			nop
				jal ERROR2
				nop
				j END
				nop
				
			NOT_ERROR2m:
			lw $a0,-8($s0)#carrega o penultimo endereco da pilha
			lw $a1,-4($s0)#carrega o ultimo endereco da pilha
			
			#verificar se a pilha tem pelo menos 2 elementos
			jal subt
			nop
			
			addi $s0,$s0,-4
			addi $s1,$s1,-1
			
			sw $v0,-4($s0)
			
			j inputLoop #volta para correr o resto do input 
			nop
		
		case3:
		bne $t1,'*',case4
		nop
			bge $s1,$s2,NOTERROR2v
			nop
				jal ERROR2
				nop
				j END
				nop
				
			NOTERROR2v:
			lw $a0,-8($s0)#carrega o penultimo endereco da pilha
			lw $a1,-4($s0)#carrega o ultimo endereco da pilha
			
			#verificar se a pilha tem pelo menos 2 elementos
			jal multi
			nop
			
			addi $s0,$s0,-4
			addi $s1,$s1,-1
			
			sw $v0,-4($s0)
			
			j inputLoop #volta para crrer o resto do input 
			nop
		case4:
		bne $t1,'/',case5
		nop
			bge $s1,$s2,NOTERROR2d
			nop
				jal ERROR2
				nop
				j END
				nop
				
			NOTERROR2d:
			lw $a0,-8($s0)#carrega o penultimo endereco da pilha
			lw $a1,-4($s0)#carrega o ultimo endereco da pilha
			
			bne $a1, $zero, runDiv
			nop
				jal ERRORDIV
				nop
				
				j END
				nop
				
			runDiv:
			jal divi
			nop
			
			addi $s0,$s0,-4
			addi $s1,$s1,-1
			
			sw $v0,-4($s0)
			
			j inputLoop #volta para correr o resto do input 
			nop
		case5:
		#off
		bne $t1,'o',case6
		nop
			lb $t1,0($t0)
			bne $t1,'f',inputLoop
			nop
				addi $t0,$t0,1
				lb $t1,0($t0)
				bne $t1,'f',inputLoop
				nop
					j off
					nop		
		
		case6:
		#dup
		bne $t1,'d',case7
		nop
			lb $t1,0($t0)
			bne $t1,'u',caseE
			nop
				addi $t0,$t0,1
				lb $t1,0($t0)
				bne $t1,'p',inputLoop
				nop
				addi $t0,$t0,1
					bge $s1,$s3,NOTERROR1dup
					nop
						jal ERROR1
						nop
						j END
						nop
				
					NOTERROR1dup:
					move $a0,$s0
					jal dup
					nop
					
					addi $s0,$s0,4
					addi $s1,$s1,1
					
					j inputLoop #volta para correr o resto do input 
					nop
					
			caseE:
			bne $t1,'e',inputLoop
			nop
				addi $t0,$t0,1
				lb $t1,0($t0)
				bne $t1,'l',inputLoop
				nop
				addi $t0,$t0,1
					bge $s1,$s3,NOTERRORdel
					nop
						jal ERROR1
						nop
						j END
						nop
				
					NOTERRORdel:
				
					addi $s0,$s0,-4
					addi $s1,$s1,-1
					
					j inputLoop #volta para crrer o resto do input 
					nop
			
		case7:
		#clear
		bne $t1,'c',case8
		nop
			lb $t1,0($t0)
			bne $t1,'l',inputLoop
			nop
				addi $t0,$t0,1
				lb $t1,0($t0)
				bne $t1,'e',inputLoop
				nop
					addi $t0,$t0,1
					lb $t1,0($t0)
					bne $t1,'a',inputLoop
					nop
						addi $t0,$t0,1
						lb $t1,0($t0)
						bne $t1,'r',inputLoop
						nop
						addi $t0,$t0,1
						
						la $s0,pilha
						li $s1,0
												
						j inputLoop #volta para correr o resto do input 
						nop
		
		case8:	
		#negacao
		bne $t1,'n',case9
		nop
			lb $t1,0($t0)
			bne $t1,'e',inputLoop
			nop
				addi $t0,$t0,1
				lb $t1,0($t0)
				bne $t1,'g',inputLoop
				nop
				addi $t0,$t0,1
					bge $s1,$s3,NOTERROR1
					nop
						jal ERROR1
						nop
						j END
						nop
				
					NOTERROR1:
					
					jal negacao
					move $a0,$s0
					
					j inputLoop #volta para correr o resto do input 
					nop
		case9:
		#swap
		bne $t1,'s',case10
		nop
			lb $t1,0($t0)
			bne $t1,'w',inputLoop
			nop
				addi $t0,$t0,1
				lb $t1,0($t0)
				bne $t1,'a',inputLoop
				nop
					addi $t0,$t0,1
					lb $t1,0($t0)
					bne $t1,'p',inputLoop
					nop
					addi $t0,$t0,1
						
					bge $s1,$s2,NOTERROR2swap
					nop
						jal ERROR2
						nop
						j END
						nop
				
					NOTERROR2swap:
					jal swap
					move $a0, $s0
						
					j inputLoop #volta para correr o resto do input 
					nop
					
		case10:
		#verificar se e numero ou nao
		
		blt $t1,0x30,NOTVALIDENTRY
		nop
				
		bgt $t1,0x39,NOTVALIDENTRY
		nop
		
		subi $t1,$t1,0x30 #converte para numero real(decimal)
		
		lb $t8,0($t0)
		beq $t8,0,save
		nop
		beq $t8,10,save
		nop
		bne $t8,' ',mult10
		nop
		
		save:
		sw $t1,0($s0)
		addi $s1,$s1,1
		addi $s0,$s0,4
		
		j inputLoop
		nop
		
		mult10: #converte o numero se for superio a 1 unidade
			#verificar se e numero ou nao
			blt $t8,0x30,NOTVALIDENTRY
			nop
				
			bgt $t8,0x39,NOTVALIDENTRY
			nop
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
				sw $t1,0($s0)
				addi $s1,$s1,1
				addi $s0,$s0,4
				
				j inputLoop
				nop
		
		sw $t1,0($s0)
		addi $s1,$s1,1
		addi $s0,$s0,4
				
		j inputLoop
		nop
			
	END:
	move $v0,$s0
	la $t0,ret2
	sw $s1,0($t0)
	lw $s0,16($sp)
	lw $s1,12($sp)
	lw $s2,8($sp) 
	lw $s3,4($sp)
	lw $ra,0($sp)
	addi $sp,$sp,20
	jr $ra
	nop
		
##################################################################
#loop principal da calculadora
main:
	addi $sp,$sp,-8
	sw $s0,4($sp)
	sw $s1,0($sp)

#FIX IT- corrigir dup deposi de dup 
	li $v0,4
	la $a0,layout #escricao inicial
	syscall
	
	
	la $s0,pilha #endereco da pilha
	move $s1,$zero #contador de elemntos da pilha
	
mainLoop: #esta sempre a correr
	
	#chama print da pilha7
	move $a0,$s1
	jal print_pilha
	nop
	
	
	#chama funcao de input
	jal makeInput
	nop
	
	#correr o input do utilizador 
	move $a1,$s1
	move $a0,$s0
	
	jal runInput
	nop
	
	move $s0,$v0
	la $t0,ret2
	lw $s1,0($t0)
	
	j mainLoop
	nop
	
	lw $s0,4($sp)
	lw $s1,0($sp)
	jr $ra
	nop
