;------ CONSTANTES ------;
DisplayInicio equ 100h
DisplayFim equ 16fh
Opcao equ 200h

;------ PRODUTOS ------;

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
string "---------------!"
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
;...
place 0000h
mov r0, MenuInicio;
call mostraDisplay;

;------ ROTINAS/FUNCOES ------;
mostraDisplay:; escreve os menus no periférico de saída
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

limpaPerifericos:
push r0
mov r0, Opcao; r0 = endereço do periferico de entrada
mov [r0], 0; PER_EN = 0
pop r0
ret