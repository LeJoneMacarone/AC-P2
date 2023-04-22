;------ CONSTANTES ------;
DisplayInicio equ 4100h
DisplayFim equ 416fh
Opcao equ 4200h
PasswordInput equ 4206h
TamanhoNomeProd equ 11
TamanhoRegistos equ 14
CaracterVazio equ 20h
ItemsPorPag equ 5
TotalRegistos equ 15
TotalPagStock equ 250h ; endereço onde vai ficar guardado o total de paginas do stock

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
string 53
string 100

string 1
string "Sumol      "
string 34
string 200

string 2
string "Compal     "
string 15
string 90

string 3
string "Pepsi      "
string 12
string 120

string 4
string "Coca-Cola  "
string 41
string 120

Snacks:
string 10
string "Kitkat     "
string 25
string 70

string 11
string "Kinder     "
string 17
string 90

string 12
string "M&Ms       "
string 18
string 80

string 13
string "Pringles   "
string 66
string 130

string 14
string "Snickers   "
string 6
string 120

Dinheiro:
string "5euros     "
string 50

string "2euros     "
string 41

string "1euro      "
string 31

string "50cent     "
string 68

string "20cent     "
string 27

string "10cent     "
string 12

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

MenuErro:
string "----------------"
string "      OPCAO     "
string "    INVALIDA    "
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
call CalcTotalPaginas
call RenderizaPagStock
jmp fimPrograma

;------ ROTINAS/FUNCOES ------;
MostraDisplay:          ; escreve os menus no periférico de saída
; input (r0)              r0 = endereço do menu a ser mostrado
push r1                 ; r1 = primeiro endereço do periférico de saida
push r2                 ; r2 = último endereço do periférico de saida
push r3                 ; r3 = caractere (em ASCII) no endereço r0
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

RotinaErro:; chamada em casos de opção inválida por exemplo
push r0             ; r0 = endereço do menu de erros
push r1             ; r1 = endereço do periférico de entrada
push r2             ; r2 = valor da opção
mov r0, MenuErro
call MostraDisplay  ; mostra o menu de erros no display
leitura:
mov r1, Opcao
mov r2, [r1]
cmp r2, 0           ; opcao = 0?
jeq leitura
pop r2
pop r1
pop r0
ret

EscreveLinhaStock:
; input : r1 = Endereço do inicio da linha no display (vai iterar no display)
; input : r0 = endereço do primeiro produto a ser escrito
; output : r1 = endereço da proxima linha do display
push r2
push r3
push r4
push r5
push r7
add r0, 1		            ; r0 = endereço do nome do primeiro produto
mov r2, 0		            ; r2 = i = 0
mov r3, TamanhoNomeProd	    ; r3 = tamanho em bytes do nome do produto
escreveNome:
mov r4, r0		            ; r4 = r0
add r4, r2		            ; r4 = r0 + i
movb r5, [r4]		        ; r5 = Caracter do nome do produto ( = Mb[Produtos + i])
movb [r1], r5		        ; Display[r1] = Caracter do nome do produto ( = Mb[Produtos + i])
add r1, 1		            ; r1++
add r2, 1		            ; i++
cmp r2, r3		   
jlt escreveNome		        ; i < TamanhoNomeProd?
escreveQtd:
mov r7, 5
add r4, 1		            ; r4 = r4 + 1 = endereço da quantidade do produto
call NumParaASCII	        ; converte o numero na posiçao apontada por r4 para ASCII e imprime no display
pop r7
pop r5
pop r4
pop r3
pop r2
ret 

RenderizaPagStock:
push r0
push r1
push r3
push r4
push r5
push r7
mov r1, DisplayInicio
;escreve o início da página do stock
mov r3, 5374h           ; r3 = "St"
mov [r1], r3            ; Display = "St"
add r1, 2               ; r0 = r0 + 2 
mov r3, 6f63h           ; r3 = "oc"
mov [r1], r3            ; Display = "Stoc"
add r1, 2               ; r0 = r0 + 2 
mov r3, 6b20h           ; r3 = "k "
mov [r1], r3            ; Display = "Stock "
add r1, 2               
mov r4, 6000h           ; endereço da pagina atual
mov r5, 0               ; pagina atual
mov [r4], r5            ; M[r4] = r5
mov r7, 4               ; r7 = numero de digitos pretendidos - 1
call NumParaASCII       ; input : r1 = endereço atual do display, r4 = endereço do numero a converter, r7 = numero de digitos pretendidos - 1
mov r3, 2fh             ; r3 = "/"
movb [r1], r3           ; Display = "Stock " + pagina_atual + "/"
add r1, 1               ; 
mov r4, TotalPagStock
call NumParaASCII 
mov r3, CaracterVazio   ; r3 = " "
movb [r1], r3           ; Display = "Stock " + pagina_atual + "/" + total_paginas 
add r1, 1               ; r1 aponta para a próxima linha do display
mov r7, 0               ; r7 = i = 0
;escrever items na página
proximoItem:
mov r0, TamanhoRegistos ; r0 = TamanhoRegistos
mul r0, r7              ; r0 = i * TamanhoRegistos
mov r8, Bebidas         ; r8 = BaseTabelaRegistos
add r0, r8              ; r0 = BaseTabelaRegistos +  i * TamanhoRegistos
call EscreveLinhaStock  
add r7, 1
cmp r7, 4
jlt proximoItem
;escreve a opção para ir para a próxima página
mov r3, 3129h           ; r3 = "1)"
mov [r1], r3            ; Display = "1)"
add r1, 2               ; r1 = r1 + 2
mov r3, 2053h           ; r3 = " S"
mov [r1], r3            ; Display = "1) S"
add r1, 2               ; r1 = r1 + 2
mov r3, 6567h           ; r3 = "eg"
mov [r1], r3            ; Display = "1) Seg"
add r1, 2               ; r1 = r1 + 2
mov r3, 7569h           ; r3 = "ui"
mov [r1], r3            ; Display = "1) Segui"
add r1, 2               ; r1 = r1 + 2
mov r3, 6e74h           ; r3 = "nt"
mov [r1], r3            ; Display = "1) Seguint"
add r1, 2               ; r1 = r1 + 2
mov r3, 6520h           ; r3 = "e "
mov [r1], r3            ; Display = "1) Seguinte "
add r1, 2               ; r1 = r1 + 2
mov r3, 2020h           ; r3 = "  "
mov [r1], r3            ; Display = "1) Seguinte   "
add r1, 2               ; r1 = r1 + 2
mov [r1], r3            ; Display = "1) Seguinte     "
pop r7
pop r5
pop r4
pop r3
pop r1 
pop r0
ret

NumParaASCII:
; input :   r4 = endereço de n (numero a converter)
;           r7 = nr_digitos = numero de digitos pretendidos
;           r1 = base_display = endereço atual do display
; output : r1 = disp + nr_digitos = endereço do display depois da conversoa
push r0 
push r2
push r3
push r5
push r6             ; r6 = i (vai iterar o display)
mov r6, r1          ; i = base_display
add r6, r7          ; i = base_display + nr_digitos
sub r6, 1           ; i = base_display + nr_digitos - 1
mov r0, 10		    ; r0 = 10
movb r2, [r4]		; r2 = n
proximo:            
mov r3, r2		    ; r3 = n (faz uma cópia do número)
mod r3, r0		    ; r3 = digito = n % 10
div r2, r0		    ; n = n / 10
mov r5, 48 		    ; r5 = 48
add r3, r5		    ; r3 = digito_ASCII = digito + 48
movb [r6], r3		; escreve digito_ASCII no display (posição i)
sub r6, 1		    ; i = i - 1
cmp r6, r1
jge proximo         ; i >= base_display?
add r1, r7          ; r1 passa a apontar para a proxima posiçao do display
pop r6
pop r5
pop r3
pop r2
pop r0
ret

CalcTotalPaginas:
push r0                     
push r1
push r2
push r4                     
mov r0, TotalRegistos       ; r0 = numero total de registos
mov r1, 5                   ; r1 = 5
mov r2, TotalPagStock       ; r2 = endereço onde fica guardado o total de páginas
jmp inicioCalc                 
cicloCalc:
add r0, 1; 
inicioCalc:
mov r4, r0
mod r4, r1
cmp r4, 0                   ; r4 % 5 = 0?
jnz cicloCalc
div r0, r1
movb [r2], r0                ; M[TotalPagStock] = numero total de páginas para o stock    
pop r4
pop r2
pop r1
pop r0
ret

VerificaPassword:
push r0
push r1
push r2
push r3
push r4
push r7
mov r0, Password
mov r1, PasswordInput
mov r2, 0               ; r2 = i = incremento
mov r5, 0               ; r5 = registo de retorno = 0 (inicialmente)
proximaLetra:
mov r3, [r0]            ; r2 = primeira letra da passe correta
mov r4, [r1]            ; r3 = primeira letra da passe introduzida
cmp r4, r3
jne diferentes          ; Password[i] != PasswordInput[i] ?
add r2, 1               ; i = i + 1
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

fimPrograma:
nop