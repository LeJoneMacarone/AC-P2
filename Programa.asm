;------ CONSTANTES ------;
DisplayInicio equ 4100h
DisplayFim equ 416fh
Opcao equ 4180h
PasswordInput equ 4186h
TamanhoNomeRegisto equ 11
TamanhoRegisto equ 16
CaracterVazio equ 20h
ItemsPorPag equ 5
TotalRegistos equ 16
Conversoes equ 4200h ; endereço onde vai ficar os numeros a serem convertidos para ASCII

;------ PASSWORD ------;
place 2ff0h
Password:
string "p4S$"

;------ PRODUTOS ------;
;   id - 1 byte 
;   nome - 11 bytes 
;   quantidade - 1 byte 
;   preço (em cent) - 1 byte
;   (total - 14 bytes)

place 2000h
Bebidas:
string 0
string "Brisa      "
word 53
word 100

string 1
string "Sumol      "
word 34
word 200

string 2
string "Compal     "
word 15
word 90

string 3
string "Pepsi      "
word 12
word 120

string 4
string "Coca-Cola  "
word 41
word 120

Snacks:
string 10
string "Kitkat     "
word 25
word 70

string 11
string "Kinder     "
word 17
word 90

string 12
string "M&Ms       "
word 18
word 80

string 13
string "Pringles   "
word 66
word 130

string 14
string "Snickers   "
word 6
word 120

Dinheiro:
string " 5euros     "
word 50
word 0

string " 2euros     "
word 41
word 0

string " 1euro      "
word 31
word 0

string " 50cent     "
word 68
word 0

string " 20cent     "
word 27
word 0

string " 10cent     "
word 12
word 0

;------ MENUS ------;
place 3000h
MenuInicio:
string "----------------"
string "MAQUINA MADEIRA "
string "   BEM-VINDO    "
string "----------------"
string "1) Produtos     "
string "2) Stock        "
string "----------------"

MenuCategoria:
string "----------------"
string "   Categoria    "
string "----------------"
string "1) Bebidas      "
string "2) Snacks       "
string "7) Cancelar     "
string "----------------"

MenuOpcaoInvalida:
string "----------------"
string "      OPCAO     "
string "    INVALIDA    "
string "----------------"
string "  PARA VOLTAR   "
string "   INTRODUZA    "
string "QUALQUER NUMERO "

MenuPassIncorreta:
string "----------------"
string "    PASSWORD    "
string "   INCORRETA    "
string "----------------"
string "  PARA VOLTAR   "
string "   INTRODUZA    "
string "QUALQUER NUMERO "

MenuStock:
string "     Stock      "
string "----------------"
string "  Introduza a   "
string "   Password     "
string "                "
string "1) Confirmar    "
string "2) Voltar       "

;------ PROGRAMA ------;
place 0000h
programa:
inicio:
	mov r0, MenuInicio			; r0 aponta para o menu inical guardado na memória
	call MostraDisplay			; imprime o menu inicial no display
	call LimpaPerifericos	
leOpcao:	
	mov r1, Opcao				; r1 aponta para o endereço do periférico para introduzir a opcao
	mov r2, [r1]				; r2 = opcao
	cmp r2, 0					
	jeq leOpcao					; salta para a leitura se o utilizador ainda não itroduziu nada (ocpao = 0)
	cmp r2, 1	
	jeq chamaRotinaProdutos		; salta para a rotina de venda de produtos se foi introduzido 1 (opcao = 1)
	cmp r2, 2	
	jeq chamaRotinaStock		; salta para a rotina de visualização do stock se foi introduzido 2 (ocpao = 2)
	call RotinaOpcaoInvalida	; se não saltou, então a opcao é inválida 
	jmp inicio					; volta ao inicio do programa
chamaRotinaStock:			
    call RotinaStock
	jmp inicio					; volta ao inicio do programa
chamaRotinaProdutos:
	jmp inicio					; volta ao inicio do programa

;------ ROTINAS/FUNCOES ------;
MostraDisplay:          ; escreve os menus no periférico de saída
    ; r0 = endereço do menu a ser mostrado
    push r1;= primeiro endereço do periférico de saida
    push r2;= último endereço do periférico de saida
    push r3;= caracter (em ASCII) no endereço r0
    mov r1, DisplayInicio
    mov r2, DisplayFim
ciclo:
    mov r3, [r0]
    mov [r1], r3
    add r0, 2               ; r0 = r0 + 2
    add r1, 2               ; r1 = r1 + 2
    cmp r1, r2
    jlt ciclo               ; r1 < DisplayFim?
    pop r3
    pop r2
    pop r1
    ret

LimpaPerifericos:
    push r0             ; r0 = endereço do periferico de entrada
    push r1
    mov r0, Opcao
    mov r1, 0
    mov [r0], r1        ; PER_EN = 0
    pop r1
    pop r0
    ret

RotinaPassIncorreta:; chamada em casos de password inválida por exemplo
    push r0             ; r0 = endereço do menu de erros
    push r1             ; r1 = endereço do periférico de entrada
    push r2             ; r2 = valor da opção
    mov r0, MenuPassIncorreta
    call MostraDisplay  ; mostra o menu de erros no display
    call LimpaPerifericos
    mov r1, Opcao
leitura_:
    mov r2, [r1]
    cmp r2, 0           ; opcao = 0?
    jeq leitura
    pop r2
    pop r1
    pop r0
    ret

RotinaOpcaoInvalida:; chamada em casos de opção inválida por exemplo
    push r0             ; r0 = endereço do menu de erros
    push r1             ; r1 = endereço do periférico de entrada
    push r2             ; r2 = valor da opção
    mov r0, MenuOpcaoInvalida
    call MostraDisplay  ; mostra o menu de erros no display
    call LimpaPerifericos
    mov r1, Opcao
leitura:
    mov r2, [r1]
    cmp r2, 0           ; opcao = 0?
    jeq leitura
    pop r2
    pop r1
    pop r0
    ret

RotinaStock:
    push r0
    push r1
    push r2
    push r5
inicioRotinaStock:
	mov r0, MenuStock			; r0 aponta para o menu do stock
	call MostraDisplay			; mostra no display o menu do stock
	call LimpaPerifericos		; limpa o periferico entrada da opcao
leOpcaoStock1: 	
	mov r1, Opcao	
	mov r2, [r1]				; r2 = opcao
	cmp r2, 0					; opcao = 0?
	jeq leOpcaoStock1	
	cmp r2, 4					; opcao = 4?
	jeq voltar	
	cmp r2, 1					; opcao = 1?
	jeq autenticacao
opcaoInvalida:	
	call RotinaOpcaoInvalida
	jmp inicioRotinaStock
autenticacao:
	call VerificaPassword		; r5 = 1 se a password é correta e 0 caso contrário
	cmp r5, 1 					; r5 = 1?
	jeq mostraStock
	call RotinaPassIncorreta
	jmp inicioRotinaStock
mostraStock: 
	mov r0, 0	
	call CalcTotalPaginas		; r0 = total_pag
	mov r5, 1					; r5 = pag_atual
	mov r7, Bebidas				; r7 aponta para a base da tabela de registos
mostraPagina:
	call RenderizaPagStock		; r7 passa a apontar para o próximo registo
	call LimpaPerifericos
leOpcaoStock2:
	; r1 = endereço da opção
	mov r2, [r1]				; r2 = opcao
	cmp r2, 1					; opcao = 1?
	jne leOpcaoStock2
	add r5, 1					; pag_atual = pag_atual + 1
	cmp r5, r0					; pag_atual > total_pag?
	jle mostraPagina
voltar:
    pop r5
    pop r2
    pop r1
    pop r0 
	ret

RenderizaPagStock:
	; r0 = total de páginas	
	; r5 = página atual
	; r7 = posição do item em memória
	push r1; = posiçao do display (usado na chamada a EscreveItemStock)
	push r2; = caracter
	push r3; = numero a converter para ASCII (usado na chamada a NumParaASCII)
	push r4; = numero de caracteres pretendidos na conversao (usado na chamada a NumParaASCII)
	push r6; = percorre os registos de items
	push r8; = constante (TamanhoRegisto)
	mov r1, DisplayInicio   ; pos_display = inicio do display
primeiraLinha:
	mov r2, 5374h           ; caracter = "St"
	mov [r1], r2            ; display = "St" 
	add r1, 2               ; pos_display = pos_display + 2
	mov r2, 6f63h           ; caracter = "oc"
	mov [r1], r2            ; display = "Stoc"
	add r1, 2               ; pos_display = pos_display + 2
	mov r2, 6b20h           ; caracter = "k "
	mov [r1], r2            ; display = "Stock "
	add r1, 2               ; pos_display = pos_display + 2
	mov r3, r5              ; num_a_converter = pag_atual
	mov r4, 4               ; num_char = 4
	call NumParaASCII       ; converte a página atual para ASCII e passa para a próxima posição do display
	mov r2, 2fh				; caracter = "/"
	movb [r1], r2			; display = "Stock <pag_atual>/"
	add r1, 1				; pos_display = pos_display + 1
	mov r3, r0				; num_a_converter = total 
	call NumParaASCII		; converte o total de páginas para ASCII e passa para a próxima posição do display
	mov r2, CaracterVazio	; caracter = " "
	movb [r1], r2			; display apresenta "Stock <pag_atual>/<total_pag> "
	add r1, 1				; r1 passa a apontar para próxima linha do display
	mov r8, TamanhoRegisto	; r8 = Tamanho dos 
	mov r6, 5				; r6 = 5
	mul r6, r8				; r6 = 5 * TamanhoRegisto	
	add r6, r7  			; r6 = 5 * TamanhoRegisto + BaseTabelaRegistos (aponta para o registo "limite" - não deve ser escrito no display)  
proximaLinha:
	call EscreveItemStock	; r1 aponta para a próxima linha do display
	add r7, r8				; r7 = endereço do próximo item 
	cmp r7, r6				; r7 < limite? (verifica se ultrapassámos os 5 registos a serem impressos)
	jlt proximaLinha
ultimaLinha:
	mov r2, 3129h           ; caracter = "1)"
	mov [r1], r2            ; Display = "1)"
	add r1, 2               ; r1 = r1 + 2
	mov r2, 2053h           ; caracter = " S"
	mov [r1], r2            ; Display = "1) S"
	add r1, 2               ; r1 = r1 + 2
	mov r2, 6567h           ; caracter = "eg"
	mov [r1], r2            ; Display = "1) Seg"
	add r1, 2               ; r1 = r1 + 2
	mov r2, 7569h           ; caracter = "ui"
	mov [r1], r2            ; Display = "1) Segui"
	add r1, 2               ; r1 = r1 + 2
	mov r2, 6e74h           ; caracter = "nt"
	mov [r1], r2            ; Display = "1) Seguint"
	add r1, 2               ; r1 = r1 + 2
	mov r2, 6520h           ; caracter = "e "
	mov [r1], r2            ; Display = "1) Seguinte "
	add r1, 2               ; r1 = r1 + 2
	mov r2, 2020h           ; caracter = "  "
	mov [r1], r2            ; Display = "1) Seguinte   "
	add r1, 2               ; r1 = r1 + 2
	mov [r1], r2            ; Display = "1) Seguinte     "
	pop r8
	pop r6
	pop r4
	pop r3
	pop r2
	pop r1
	ret

EscreveItemStock:
	;r1 = posição atual do display
	;r7 = posição do registo
	push r0; = posição da quantidade no registo do item
	push r2; = iterador (vai percorrer o registo)
	push r3; = valor da quantidade do item do stock (a converter para ASCII)
	push r4; = número de digitos pretendidos para a conversão
	push r5; = caracter na posição apontada por r2
	mov r0, TamanhoNomeRegisto
	add r0, r7			; r0 aponta para a última letra do nome
	add r0, 1			; r0 aponta para a quantidade do item
	mov r2, r7			; i = pos_registo
	add r2, 1			; i = pos_registo + 1 = posição da 1ª letra
escreveNome:
	movb r5, [r2]		; obtêm o valor em memória na posição pos_letra + i 
	movb [r1], r5		; acrescenta esse valor ao display
	add r1, 1			; pos_display = pos_display + 1
	add r2, 1			; i = i + 1
	cmp r2, r0			; i < posição da quantidade?
	jlt escreveNome
escreveQtd:
	mov r3, [r0]		; r3 fica com o valor da quantidade do items
	mov r4, 5			; r4 fica com o número de dígitos pretendidos para a conversão em ASCII
	call NumParaASCII	; r1 aponta para a próxima linha do display
	pop r5
	pop r4
	pop r3
	pop r2
	pop r0
	ret

NumParaASCII:
	; r1 = posição do display 
	; r3 = número a converter para ASCII
	; r4 = número de caracteres pretendidos na conversão
	push r0; = i (vai iterar no display)
	push r2; = guarda os digitos do número a converter
	push r5; = constantes (10 e 48)
	mov r0, r1			; i = pos_display
	add r0, r4			; i = pos_display + num_caracteres
	sub r0, 1			; i = pos_display + num_caracteres - 1
proximoDigito:	
	mov r2, r3			; copia n para r2
	mov r5, 10			; r5 = 10
	mod r2, r5			; r2 fica com o digito (r2 = r2 mod 10)
	div r3, r5			; n = n/10
	mov r5, 48			; r5 = 48
	add r2, r5			; r2 fica com o digito em código ASCII
	movb [r0], r2		; escreve o digito no display
	sub r0, 1			; passa para a próxima posição (posição anterior)
	cmp r0, r1			; i >= pos_display?
	jge proximoDigito
	add r1, r4			; depois de a conversão acabar, passa para a próxima posição do display 
	pop r5
	pop r2
	pop r0
	ret

CalcTotalPaginas:
; r0 = resultado
push r1
push r2
push r3                    
mov r0, TotalRegistos 
mov r1, 5                   ; r1 = 5
jmp inicioCalc                 
cicloCalc:
add r0, 1                   ; n = n + 1
inicioCalc:
mov r3, r0                  ; copia n para r3
mod r3, r1                  ; r3 = r3 % 5
cmp r3, 0                   ; r3 % 5 = 0?
jnz cicloCalc
div r0, r1                  ; n = n/5  
pop r3
pop r2
pop r1
ret

VerificaPassword:
push r0
push r1
push r2
push r3
push r4
mov r0, Password        
mov r1, PasswordInput
mov r2, 0               ; r2 = i = incremento
mov r5, 0               ; r5 = registo de retorno = 0 (inicialmente)
proximaLetra:
mov r3, [r0]            ; r3 = 2 letras nas posições i e i + 1 da passe correta
mov r4, [r1]            ; r4 = 2 letras nas posições i e i + 1 da passe introduzida
cmp r4, r3
jne diferentes          ; Password[i] != PasswordInput[i] ?
add r2, 2               ; i = i + 2
cmp r2, 4               
jne proximaLetra        ; i != 4 ?
add r5, 1               ; se o ciclo acabou e nao saltou para "diferentes", então são iguais (r5 = 1)
diferentes:             ; salta para aqui se o ciclo encontrou letras diferentes (r5 = 0)
pop r4
pop r3
pop r2
pop r1
pop r0
ret 