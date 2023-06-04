;==========================================================================================
; Constantes
;==========================================================================================
; periféricos de saída
DisplayInicio equ 4100h		; localiza o início do display da máquina
DisplayFim equ 416fh		; localiza o fim do display da máquina
; periféricos de entrada
Opcao equ 4180h				; localiza o botão de opção da máquina
PasswordInput equ 4186h		; localiza onde será introduzida a password
; constantes simbólicas
TamanhoNomeRegisto equ 11	
TamanhoRegisto equ 16
TotalRegistos equ 16
TotalBebidas equ 5
TotalSnacks equ 5
TotalProd equ 10
; opções para o dinheiro introduzido
Odezcent equ 1
Ovintecent equ 2
Ocinquentacent equ 3
Ocemcent equ 4
Oduzentoscent equ 5
Oquinhentoscent equ 6

;==========================================================================================
; Password
;==========================================================================================
place 2ff0h
Password:
string "p4S$"

;==========================================================================================
; Produtos da máquina (16 bytes): 
;	. ID (1 byte) - identifca unicamente a opção pela qual o produto será selecionado
;	. nome (11 bytes) - nome do produto
;	. quantidade (2 bytes) - quantidade do produto em stock
;	. preço (2 bytes) - preço do produto em cêntimos
;==========================================================================================
place 2000h; início da zona onde está guardado o stock da máquina
Bebidas:; início da zona onde estão guardadas os dados das bebidas
string 1
string "Brisa      "
word 53
word 100

string 2
string "Sumol      "
word 34
word 200

string 3
string "Compal     "
word 15
word 90

string 4
string "Pepsi      "
word 12
word 120

string 5
string "Coca-Cola  "
word 41
word 120

Snacks:; início da zona onde estão guardadas os dados dos snacks
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

;==========================================================================================
; Dinheiro na máquina (16 bytes):
;	. nome (12 bytes) - identifica a moeda no menu do stock (o primeiro byte é sempre " ")
;	. quantidade (2 bytes) - quantidade do dinheiro em stock
;	. valor (2 bytes) - valor monetário do item em cêntimos
;==========================================================================================
Dinheiro:; início da zona onde estão guardados os dados do dinheiro
string " 5euros     "
word 50
word 500

string " 2euros     "
word 41
word 200

string " 1euro      "
word 31
word 100

string " 50cent     "
word 68
word 50

string " 20cent     "
word 27
word 20

string " 10cent     "
word 12
word 10

;==========================================================================================
; Menus predefinidos
;==========================================================================================
place 3000h; Início da zona onde estão guardados os menus
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

MenuPagamento:
string "Pagamento ------"
string "06)05$  03)0.50$"
string "05)02$  02)0.20$"
string "04)01$  01)0.10$"
string "----------------"
string "00.00$ | 7)Pagar"
string "----------------"

MenuIntroducaoID:
string "----------------"
string "Por favor insira"
string "o ID do produto "
string "correspondente  "
string "----------------"
string "   V   V   V    "
string "----------------"

Talao:
string "----------------"
string "     Talao      "
string "----------------"
string "                "
string "Inserido        " 
string "Troco           " 
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

PagStock:
string "Stock     /     "
string "                "
string "                "
string "                "
string "                "
string "                "
string "1) Seguinte     "

;==========================================================================================
; Pragrama principal - Máquina de vendas
;==========================================================================================
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
	call RotinaProdutos
	jmp inicio					; volta ao inicio do programa

;==========================================================================================
; Subrotinas
;==========================================================================================

;==========================================================================================
; MostraDisplay - imprime no display o menu localizado no endereço especificado
;==========================================================================================
; Input: 
;	r0 = endereço do menu a ser mostrado no display da máquina 
;==========================================================================================
MostraDisplay:
    push r1; = primeiro endereço do periférico de saida
    push r2; = último endereço do periférico de saida
    push r3; = caracter (em ASCII) no endereço r0
    mov r1, DisplayInicio
    mov r2, DisplayFim
ciclo:
    mov r3, [r0]
    mov [r1], r3
    add r0, 2               ; r0 = r0 + 2
    add r1, 2               ; r1 = r1 + 2
    cmp r1, r2
    jlt ciclo               ; r1 < DisplayFim? se sim, continua
    pop r3
    pop r2
    pop r1
    ret

;==========================================================================================
; LimpaPerifericos - apaga o valor inserido nos periféricos de entrada
;==========================================================================================
LimpaPerifericos:
    push r0
    push r1
    mov r0, Opcao
    mov r1, 0
    mov [r0], r1
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

;==========================================================================================
; RotinaProdutos - permite que o utilizador escolha que tipo de produtos pretende comprar 
;==========================================================================================
RotinaProdutos:
	push r0
	push r1
	push r2
	push r5
inicioRotProd:
	mov r0, MenuCategoria		; r0 aponta para o menu da categoria
	call MostraDisplay			; vai mostrar no display o menu da categoria
	call LimpaPerifericos
leOpcaoRotProd:
	mov r1, Opcao				; r1 = endereço do periférico de entrada 
	mov r2, [r1]				; r2 = valor da opção
	cmp r2, 0					
	jeq leOpcaoRotProd			; r2 = 0? se sim, então volta a ler a opção
	cmp r2, 1
	jeq mostraBebidas			; r2 = 1? se sim, então vai para a parte das bebidas
	cmp r2, 2
	jeq mostraSnacks			; r2 = 1? se sim, então vai para a parte dos snacks
	call RotinaOpcaoInvalida	; se não saltou, então a opção não é válida
	jmp inicioRotProd			; volta ao inicio
mostraBebidas:
	mov r5, Bebidas				; r5 = endereço a partir do qual vai começar a procura do item cujo id vai ser introduzido pelo utilizador (neste caso, a partir das bebidas)
	mov r9, 5					; r9 = quantos items existem na tabela de bebidas
	call ProcurarOpcao			; permite a introdução do valor pelo utilizador e a sua procura a partir do endereço r5
	jmp fimRotProd				; acaba
mostraSnacks:
	mov r5, Snacks				; r5 = endereço a partir do qual vai começar a procura do item cujo id vai ser introduzido pelo utilizador (neste caso, a partir das bebidas)
	mov r9, 5					; r9 = quantos items existem na tabela de bebidas
	call ProcurarOpcao			; permite a introdução do valor pelo utilizador e a sua procura a partir do endereço r5
	jmp fimRotProd				; acaba
fimRotProd:
	pop r5
	pop r2
	pop r1
	pop r0
	ret

;==========================================================================================
; RotinaStock - responsável pela verificação da password e por mostrar cada página do stock
; no display da máquina
;==========================================================================================
RotinaStock:
    push r0
    push r1
    push r2
    push r5
	push r7
inicioRotinaStock:
	mov r0, MenuStock			; r0 aponta para o menu do stock
	call MostraDisplay			; mostra no display o menu do stock
	call LimpaPerifericos		; limpa o periferico entrada da opcao
leOpcaoStock1: 	
	mov r1, Opcao	
	mov r2, [r1]				; r2 = opcao
	cmp r2, 0					; opcao = 0? se sim, volta a ler a opcao
	jeq leOpcaoStock1	
	cmp r2, 4					; opcao = 4? se sim "volta para o menu anterior" (isto é, acaba) 
	jeq voltar	
	cmp r2, 1					; opcao = 1? se sim, verifica a password
	jeq autenticacao
opcaoInvalida:					; se nao saltou em nenhuma das anteriores, entao a opcao é inválida
	call RotinaOpcaoInvalida	
	jmp inicioRotinaStock		; volta ao inicio
autenticacao:
	call VerificaPassword		; r5 = 1 se a password é correta e 0 caso contrário
	cmp r5, 1 					
	jeq mostraStock				; r5 = 1? (ou seja, a password é a correta?) se sim, mostra o stock
	call RotinaPassIncorreta	; se não, chama a rotina de erro correspondente... 
	jmp inicioRotinaStock		; ... e volta ao inicio
mostraStock: 
	mov r0, TotalRegistos		; r0 = numero total de registos
	call CalcTotalPaginas		; r0 = total de páginas
	mov r5, 1					; r5 = página atual
	mov r7, Bebidas				; r7 aponta para a base da tabela de registos
mostraPagina:
	call RenderizaPagStock		; imprime no display o stock para a pagina atual para os 5 primeiros items a contar de r7 (r7 passa a apontar para o próximo registo)
	call LimpaPerifericos
leOpcaoStock2:
	; r1 = endereço da opção
	mov r2, [r1]				; r2 = opcao
	cmp r2, 1					
	jne leOpcaoStock2			; opcao != 1? se sim, volta a ler a opcao
	add r5, 1					; se nao, vai para 
	cmp r5, r0					; pag_atual > total_pag?
	jle mostraPagina
voltar:
	pop r7
    pop r5
    pop r2
    pop r1
    pop r0 
	ret

;==========================================================================================
; RenderizaPagStock - mostra no display uma das páginas do stock
;==========================================================================================
; Input: 
;	r0 - total de páginas
;	r5 - página atual
;	r7 - aponta para o primeiro dos 5 items a serem mostrados na página do stock
; Output:
;	r7 - aponta para o próximo item depois dos 5 que foram impressos no display
;==========================================================================================
RenderizaPagStock:
	push r1
	push r2
	push r3
	push r4
	push r6
	push r8
; mostrar no display o template para a página do stock
	mov r2, r0				; copia o conteúdo de r0 (total de páginas) para r2 (r0 vai ser usado para a chamar MostraDisplay)
	mov r0, PagStock		; r0 aponta para o o template da página do stock
	call MostraDisplay		; é mostrado no display o template para a página do stock 
	mov r0, r2				; r0 volta a ter valor do total de páginas
; imprimir o número da página atual a partir da sexta posição da primeira linha do display
	mov r1, DisplayInicio	
	add r1, 6				; r1 aponta para a posição onde deve ser impressa a página atual
	mov r3, r5				; pretende-se converter o número da página atual
	mov r4, 4				; pretende-se que sejam convertidos 4 digitos
	call NumParaASCII		; o número da página atual é impresso no display (r1 aponta o caracter "/")
; imprimir o total de páginas a partir do caracter "/" da primeira linha do display
	add r1, 1				; r1 aponta para a posição onde deve ser impresso o total de páginas
	mov r3, r0				; pretende-se converter o total de páginas
	call NumParaASCII		; o total de páginas é impresso no display (r1 aponta para o fim da linha)
; mostrar os items do stock a partir da segunda linha
	add r1, 1				; r1 aponta para o início da próxima linha do display 
	mov r6, 5				; r6 = 5
	mov r8, TamanhoRegisto	; r8 = Tamanho dos registos
	mul r6, r8				; r6 = 5 * TamanhoRegisto	
	add r6, r7  			; r6 aponta para o registo "limite" - que não deve ser escrito no display (r6 = 5 * TamanhoRegisto + EndPrimeiroItem)
proximaLinha:
	call EscreveItemStock	; r1 aponta para a próxima linha do display
	add r7, r8				; r7 aponta para o próximo item a ser escito
	cmp r7, r6
	jlt proximaLinha		; verifica se ultrapassámos os 5 items a serem impressos e escreve na linha seguinte se não for o caso
	pop r8
	pop r6
	pop r4
	pop r3
	pop r2
	pop r1
	ret

;==========================================================================================
; EscreveItemStock - imprime no display o item do stock
;==========================================================================================
; Input: 
;	r1 - posição atual do display
; 	r7 - aponta para o item do stock a ser escrito no display
; Output:
;	r1 - aponta para o início da próxima linha do display
;==========================================================================================
EscreveItemStock:
	push r0; = posição da quantidade no registo do item
	push r2; = iterador (vai percorrer o registo)
	push r3; = valor da quantidade do item do stock (a converter para ASCII)
	push r4; = número de digitos pretendidos para a conversão
	push r5; = caracter na posição apontada por r2
; inicialização de variáveis
	mov r0, TamanhoNomeRegisto
	add r0, r7
	add r0, 1			; r0 aponta para a quantidade do item
	mov r2, r7
	add r2, 1			; r2 aponta para a 1ª letra do nomes
escreveNome:; escrever o nome do item
	movb r5, [r2]		; obtêm uma letra do nome (no posição r2)
	movb [r1], r5		; imprime a letra no display (na posição r1)
	add r1, 1			; incrementa a posição do display
	add r2, 1			; segue para a próxima letra do nome
	cmp r2, r0
	jlt escreveNome		; verifica se ainda não chegámos à quantidade (fim do nome) e, nesse caso, imprime a próxima letra
escreveQtd:; escrever a quantidade do item
	mov r3, [r0]		; r3 fica com o valor da quantidade do items
	mov r4, 5			; r4 fica com o número de dígitos pretendidos para a conversão em ASCII
	call NumParaASCII	; r1 aponta para a próxima linha do display
	pop r5
	pop r4
	pop r3
	pop r2
	pop r0
	ret

;==========================================================================================
; NumParaASCII - escreve um número no display
;==========================================================================================
; Input: 
;	r1 - posição atual do display
;	r3 - número a converter para ASCII
;	r4 - número de digitos pretendidos na conversão
; Output:
;	r1 - próxima posição do display
;==========================================================================================
NumParaASCII:
	push r0; = i (vai iterar no display)
	push r2; = guarda os dígitos do número a converter
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

;==========================================================================================
; CalcTotalPaginas - calcula o total de páginas necessárias para mostrar todo o stock
;==========================================================================================
; Input: 
;	r0 - número de items no stock
; Output:
;	r0 - total de páginas para o stock
;==========================================================================================
CalcTotalPaginas:
	push r1
	push r2
	push r3
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

;==========================================================================================
; VerificaPassword - verifica se a password introduzida é a password correta ou não
;==========================================================================================
; Output: 
;	r5 - 1 se a password introduzida é a correta e 0 caso contrário
;==========================================================================================
VerificaPassword:
	push r0
	push r1
	push r2
	push r3
	push r4
	mov r0, Password        
	mov r1, PasswordInput
	mov r2, 0               ; r2 = i = incremento
	mov r5, 0               ; r5 = registo de retorno (inicializado a 0)
proximaLetra:
	mov r3, [r0 + r2]		; r3 = 2 letras nas posições i e i + 1 da passe correta
	mov r4, [r1 + r2]		; r4 = 2 letras nas posições i e i + 1 da passe introduzida
	cmp r4, r3
	jne diferentes          ; Password[i] != PasswordInput[i] ?
	add r2, 2               ; i = i + 2
	cmp r2, 4               
	jne proximaLetra        ; i != 4 ?
	add r5, 1               ; se o ciclo acabou e nao saltou para "diferentes", então são iguais (r5 = 1)
diferentes:             	; salta para aqui se o ciclo encontrou letras diferentes (r5 = 0)
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	ret 


;==========================================================================================
; Coisas do Martim
;==========================================================================================
ProcurarOpcao:
	; r5 = inicio da tabela de registos da categoria escolhida
	; r9 = total de produtos da categoria selecionada
	push r0 ; endereço da opçao
	push r1 ; guarda o valor da opçao
	push r4 ; guarda o Tamanho do Registo
	push r7 ; id do produto 
	push r8 ; endereço do final (ou limite) 
	mov r4, TamanhoRegisto 
	mov r8, r4
	mul r8, r9					
	add r8, r5 					; r8 = base_tabela + total_prod * TamanhoRegisto
	mov r0, MenuIntroducaoID	; r0 aponta para o menu de inserção do id do produto
	call MostraDisplay			; é chamada MostraDisplay para imprimir o menu apontado por r0
	call LimpaPerifericos		; 
introduzirID:
	mov r0, Opcao				; r0 = posição de memória da opção
	mov r1, [r0]				; r1 = valor da opção
	cmp r1, 0
	jeq introduzirID			; r1 = 0? se sim, então o utilizador ainda nao introduziu nada (voltamos atrás)
cicloproc: 						; comparar o id dos produtos com a opçao escolhida
	movb r7, [r5]				; r7 = id do produto 
	cmp r1, r7
	jeq saiciclo 				; opcao = id? se sim, então produto encontrado  
	add r5, r4					; se não, vamos continuar a procurar (r5 aponta para o id do próximo produto da lista)
	cmp r5, r8
	jlt cicloproc				; r5 < r8 (ainda não cobrimos todos os items)? nesse caso, retorna ao ciclo
	call RotinaOpcaoInvalida	; se r5 = r8, então o id introduzido não foi encontrada e chamamos a rotina de erro
	jmp acabaproc				
saiciclo:
	call EscreverItemEscolhido	; r5 = item escolhido pelo utilizador
acabaproc:
	pop r8
	pop r7
	; r5 aponta para o item da tabela escolhido pelo utilizador
	pop r4
	pop r1
	pop r0
	ret

EscreverItemEscolhido:
	; r5 = endereço do item a escrever
	; r9 = soma das moedas que foram introduzidas na maquina
	push r0 ; aponta para o menu do talão
	push r1	; vai percorrer o display
	push r2 ; constante
	push r3 ; numero a converter (parâmetro do NumParaASCII)
	push r4 ; numero de carateres (parâmetro do NumParaASCII)
	push r6 ; valor guardado no endereço r5
	push r8
	push r9	; valor inserido na máquina 
	mov r9, 0
	call LimpaPerifericos
	call IncrementaDinheiro		; r9 = dinheiro introduzido pelo utilizador	
	mov r0, Talao	
	call MostraDisplay			
	mov r1, DisplayInicio		; r1 aponta para o inicio do display
	mov r2, 30h					; r2 = 30h
	add r1, r2 					; r1 = DisplayInicio + 30h = posição da 4º linha no Menu do Talão
	mov r4, TamanhoNomeRegisto	; r4 = TamanhoNomeRegisto
	add r4, r5					; r4 aponta para a última letra do produto a escrever
	add r4, 1					; r4 aponta para a quantidade do item
	add r5, 1					; i = pos_registo + 1 = posição da 1ª letra
escreveitemTalao:		
	movb r6, [r5]				; obtêm o valor em memória na posição pos_letra + i 
	movb [r1], r6				; acrescenta esse valor ao display
	add r1, 1					; pos_display = pos_display + 1
	add r5, 1					; i = i + 1
	cmp r5, r4					; i < posição da quantidade?
	jlt escreveitemTalao 		; no fim do ciclo, r5 aponta para a quantidade
	add r5, 2 					; r5 aponta para o preço
	mov r3, [r5]				
	mov r4, 4					
	call NumParaASCII			; converte o preço (em centimos) para ASCII (4 digitos)
	add r1, 7
	add r1, 5 					; r1 = r1 + 12
	; r9 = dinheiro inserido na máquina!
	mov r3, r9 	
	call NumParaASCII			; converte o dinheiro inserido (r9) em ASCII (4 digitos)
	add r1, 7
	add r1, 5 					; r1 = r1 + 12
	; r5 aponta para o preço do produto escolhido!
	call RetiraDinheiro			; r9 = troco
	pop r9						;
	pop r8						;
	pop r6
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	ret

;---------------------------------------------------------------------------------------------
IncrementaDinheiro:
	push r0 ; aponta para o menu com info de pagamento
	push r1 ; r1 = valor monetário que adicionou
	push r2 ; r2 irá guardar o valor da opção
	push r3 ; apoonta para a lista do dinheiro
	push r4 ; r4 = Tamanho do nome do registo 
	push r5 ; r5 = tamanho do registo 
	push r6
	push r8 ; variavel temporaria 
	;r9 = soma das moedas que foram introduzidas na maquina
	mov r0, MenuPagamento		;
	call MostraDisplay			;
	mov r9, 0 					; r9 inicia a 0
	mov r4,TamanhoNomeRegisto	; r4 = tamanho do nome dos registo
	add r4, 1 					; r4 aponta para a quantidade da nota/moeda
	mov r5,TamanhoRegisto		; r5 = tamanho do registo
ciclodinheiro:
	mov r3, Dinheiro 		; r3 aponta para o inicio da tabela do dinheiro (registo dos 5 euros)
	mov r1, Opcao
	mov r2, [r1] 			; r2 guarda o valor da opção (r0)
	cmp r2, 0
	jeq ciclodinheiro		; r2 = 0? se sim, volta a ler a opcão
	cmp r2, Oquinhentoscent
	jeq quantidadedinheiro	; r2 = opcão dos 5€? se sim, atualiza r9
	add r3,r5				; r3 passa a apontar para o registo dos 2€ 
	cmp r2, Oduzentoscent
	jeq quantidadedinheiro 	; r2 = opcão dos 2€? se sim, atualiza r9
	add r3,r5				; r3 passa a apontar para o registo de 1€ 
	cmp r2, Ocemcent		; ... 
	jeq quantidadedinheiro	; ... (vai repetindo) ...
	add r3,r5				; ...
	cmp r2, Ocinquentacent
	jeq quantidadedinheiro
	add r3,r5
	cmp r2, Ovintecent
	jeq quantidadedinheiro
	add r3,r5
	cmp r2, Odezcent
	jeq quantidadedinheiro
	cmp r2, 7				; opcção = 7? se sim, acaba o pagamento
	jeq acaba				
	call RotinaOpcaoInvalida; se nenhuma das opções foi selecionada, chama a rotina de erro
	jmp programa
quantidadedinheiro: 		; enderenço quantidade = DisplayInicio + 12 = enderenço + TamanhoNomeRegisto + 1
	add r3, r4     			; r3 aponta para a quantidade
	mov r6, [r3]   			; r6 = quantidade 
	add r6, 1      			; adicionou uma moeda ao stock
	mov [r3], r6 			; atualiza o registo da moeda
	add r3, 2 				; r3 aponta para o valor da moeda (em cent)
	mov r8, [r3]			; r8 = valor da moeda
	add r9, r8  			; r9 adicionou o valor da moeda 
	call LimpaPerifericos	; apaga a opção anterior no periférico de entrada
	jmp ciclodinheiro		; volta para o ciclo de leitura do dinheiro
acaba:
	pop r8
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	ret 
;---------------------------------------------------------------------------------------------------

RetiraDinheiro:
	push r0 ; r0 = valor do produto
	; r1 aponta para o Display
	push r2 ; r2 variavel temporaria
	push r3 ; variavel temporaria para guardar o valor da quantidade de moedas
	push r4 ; guarda o Tamanho do Nome do Registo
	;r5 = apontador do preço dos produtos
	push r6 ; aponta para a quantidade das moedas
	push r7 ; guarda o Tamanho do Registo
	push r8 ; aponta para o valor das moedas
	;r9 = valor inserido
	push r10 ; variavel utilizada para comparar o valor das moedas com o valor obtido como Troco 
	call LimpaPerifericos
	mov r7, TamanhoRegisto
	mov r6, Dinheiro
	mov r4, TamanhoNomeRegisto		
	add r4, 1 						; r4 = 12
	mov r0, [r5]					; r0 = preço
	sub r9, r0						; r9 = dinheiro_inserido - preço_produto = troco
	mov r3, r9	
	push r4							; guarda r4 na stack temporariamente
	mov r4, 4						; utiliza r4 para a chamada de NumParaASCII
	call NumParaASCII				; converte o troco para ASCII
	pop r4							; retira da stack
	cmp r9, 0 						; troco >= 0?
	jge retiraQtProd
	call RotinaOpcaoInvalida		; dinheiro insuficiente
	jmp acaba2
retiraQtProd:
	sub r5, 2    		; aponta para a quantidade do produto
	mov r2, [r5]   		; r2 = quantidade do produto
	sub r2 ,1    		; retira um produto do armazem (stock)
	mov [r5], r2 		; atualizaça o stock dos items 
	add r6, r4 			; r6 aponta para a quantidade das moedas
	mov r8, r6			; r8 = r6 = apontador para a quantidade das moedas
	add r8, 2 			; r8 aponta para o valor das moedas
ciclomoedas:
	mov r10, [r8] 		; r10 = valor da moeda (apontado por r8)
	cmp r9, 0
	jeq espera			; se o troco for nulo, acaba
	cmp r9, r10
	jge retiraQtMoedas	; troco >= 5€? se sim, retira 5€
	add r8, r7			; r8 aponta para a quantidade do próximo registo de notas/moedas
	mov r10, [r8]		; r10 = valor da moeda (apontado por r8)
	cmp r9, r10 		; 2
	jge retiraQtMoedas	; ...
	add r8, r7			; ... (vai repetindo) ...
	mov r10, [r8]		; ... 
	cmp r9, r10 		; 1
	jge retiraQtMoedas
	add r8, r7
	mov r10, [r8]
	cmp r9, r10 		; 0,5
	jge retiraQtMoedas
	add r8, r7
	mov r10, [r8]
	cmp r9, r10			; 0,2
	jge retiraQtMoedas
	add r8, r7
	mov r10, [r8]
	cmp r9, r10			; 0,1
retiraQtMoedas:
	sub r9, r10 		; utilizar as moedas maiores como troco 
	mov r3, [r6]		; r1 = quantidade da moeda 
	sub r3, 1			; decrementa a quantidade da moeda 
	mov [r6], r3		; atualiza a quantidade em memória
	jmp ciclomoedas
espera: ;vai esperar pelo input do utilizador para ter tempo de ver o talao
	mov r2, Opcao
	mov r3, [r2]
	cmp r3, 0
	jeq espera
acaba2: 
	pop r10
	pop r8
	pop r7
	pop r6
	pop r4
	pop r2
	pop r1
	pop r0
	ret