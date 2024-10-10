.data
    array: .word 40, 12, 432, 5, 0, 3, 4, 12, 42
    size: .word 9    # Tama�o del array
    guion: .asciiz " - "  # Guion separador para la impresi�n
    saltoLinea: .asciiz "\n"  # Salto de l�nea para imprimir
.text
.globl main
main:
    la $a0, array     # Carga la direcci�n del array
    lw $a1, size      # Carga el tama�o del array
    addi $a1, $a1, -1 # Ajusta para que $a1 sea el �ndice del �ltimo elemento
    
    jal sort_descendente  # Llama a la funci�n de orden descendente
    # Imprime el array ordenado
    la $a0, array
    lw $a1, size
    jal print_array
    # Termina el programa
    li $v0, 10
    syscall
sort_descendente:
    blez $a1, done_desc    # Si el tama�o es 0 o 1, ya est� ordenado
    # Guarda $ra y $a1 en la pila
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $a1, 4($sp)
    move $a3, $a1     # $a3 ser� el �ndice final
    # Llama a la funci�n que encuentra el m�nimo
    jal min           
    j intercambio_desc

intercambio_desc:
    # Intercambia el valor encontrado con el �ltimo elemento
    sll $t0, $a1, 2   # Multiplica $a1 por 4 para obtener el offset en bytes
    add $t0, $a0, $t0 # $t0 ahora es la direcci�n del �ltimo elemento
    lw $t1, 0($t0)    # $t1 es el valor del �ltimo elemento
    sw $v1, 0($t0)    # Guarda el valor m�nimo en la �ltima posici�n
    sll $t2, $v0, 2   # Multiplica el �ndice del valor m�nimo por 4
    add $t2, $a0, $t2 # $t2 es la direcci�n del valor m�nimo
    sw $t1, 0($t2)    # Guarda el valor del �ltimo elemento en la posici�n del valor m�nimo

    addi $a1, $a1, -1 # Decrementa el �ndice del �ltimo elemento

    jal sort_descendente  # Repite la funci�n para el subarreglo m�s peque�o
    # Restaura $ra y ajusta $sp
    lw $ra, 0($sp)
    addi $sp, $sp, 8

done_desc:
    jr $ra
# Encuentra el m�nimo
min:
    move $v0, $zero   # Inicializa el �ndice del m�nimo
    lw $v1, 0($a0)    # Inicializa el valor m�nimo
    li $t0, 0         # Inicializa el �ndice actual

min_loop:
    bgt $t0, $a3, min_done
    sll $t1, $t0, 2   # Multiplica el �ndice por 4
    add $t1, $a0, $t1 # Obtiene la direcci�n del elemento actual
    lw $t2, 0($t1)    # Carga el valor del elemento actual
    bge $t2, $v1, min_next # Si el valor actual es mayor o igual, sigue buscando    
    move $v0, $t0     # Actualiza el �ndice del m�nimo
    move $v1, $t2     # Actualiza el valor m�nimo

min_next:
    addi $t0, $t0, 1  # Incrementa el �ndice
    j min_loop

min_done:
    jr $ra

print_array:
    move $t0, $a0         # Puntero al array
    move $t1, $a1         # Contador
print_loop:
    beqz $t1, print_done   
    lw $a0, 0($t0)
    li $v0, 1
    syscall
    la $a0, guion
    li $v0, 4
    syscall
    addi $t0, $t0, 4
    addi $t1, $t1, -1
    j print_loop
print_done:
    la $a0, saltoLinea
    li $v0, 4
    syscall
    jr $ra
