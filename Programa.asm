;------ CONSTANTES ------;
DisplayInicio equ 100h
DisplayFim equ 16fh
Opcao equ 200h
TamanhoNomeProd equ 11
CaracterVazio equ 20h
ItemsPorPag equ 5
TotalRegistos equ 15
TotalPagStock equ 250h ; endereço onde vai ficar guardado o total de paginas do stock

;------ PASSWORD ------;
place 1ff0h
Password:
string "p4S$"

;------ PRODUTOS ------;
;   id - 1 byte 
;   nome - 11 bytes 
;   quantidade - 1 byte 
;   preço (em cent) - 1 byte
;   (total - 14 bytes)

place 1000h
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
place 2000h
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
string "!--------------!"
string "!     OPCAO    !"
string "!   INVALIDA   !"
string "!--------------!"
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

;------ ROTINAS/FUNCOES ------;
MostraDisplay:; escreve os menus no periférico de saída
; input : r0 = endereço do menu a ser mostrado
push r1; r1 = primeiro endereço do periférico de saida
push r2; r2 = último endereço do periférico de saida
push r3; r3 = caractere (em ASCII) no endereço r0
mov r1, DisplayInicio
mov r2, DisplayFim
ciclo:
mov r3, [r0]
mov [r1], r3
add r0, 2; r0 = r0 + 2
add r1, 2; r1 = r1 + 2
cmp r1, r2
jlt ciclo; r1 < DisplayFim?
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
add r4, 1		            ; r4 = r4 + 1 = endereço da quantidade do produto
call NumParaASCII	        ; converte o numero no endereço r4 para ASCII e imprime no display
add r1, 6		            ; r1 = endereço do fim da linha
pop r5
pop r4
pop r3
pop r2
ret 

NumParaASCII:
; input : r4 = endereço do numero a converter
; input : r1 = endereço atual do display
push r0 
push r2
push r3
push r5
push r6
mov r6, r1		    ; r6 = r1
add r6, 4           ; r6 = i = r1 + 4 = endereço do fim da linha no display
mov r0, 10		    ; r0 = 10
movb r2, [r4]		; r2 = n = número a converter
proximo:            
cmp r6, r1
jlt fimCiclo        ; while (i >= r1) {
mov r3, r2		    ; faz uma cópia do número
mod r3, r0		    ; digito = n % 10
div r2, r0		    ; n = n / 10
mov r5, 48 		    ; r5 = 48
add r3, r5		    ; r3 = digito_ASCII = digito + 48
movb [r6], r3		; Display[i] = digito_ASCII
sub r6, 1		    ; i--		
cmp r6, r1
jmp proximo         ;}
fimCiclo:
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
mov [r2], r0                ; M[r2] = numero total de páginas para o stock    
pop r4
pop r2
pop r1
pop r0
ret