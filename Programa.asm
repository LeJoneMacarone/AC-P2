;------ CONSTANTES ------;
DisplayInicio equ 100h
DisplayFim equ 16fh

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
string "                "
string "                "
string "    ATENCAO     "
string "     OPCAO      "
string "    ERRADA      "
string "                "
string "                "

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

;------ ROTINAS/FUNCOES ------;
mostraDisplay: ; r0 indica o endereço do primeiro caracter do menu
push r1 
push r2
push r3
mov r1, DisplayInicio
mov r2, DisplayFim
ciclo:
mov r3, [r0]
mov [r1], r3
add r0, 2
add r1, 2
cmp r1, r2
jne ciclo
pop r3
pop r2
pop r1