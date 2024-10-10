#Evaluación de un polinomio de grado n
#Recibe el grado n del polinomio, reserva memoria para los coeficientes necesarios
#Ingresar los coeficientes (float) mediante un bucle
#Pedir un valor x (float) y calcular el polinomio

.text
.globl __start

__start:
#Solicitamos el grado n
li $v0, 4		
la $a0, cad_n	#Imprimimos cad_n
syscall

li $v0, 5		#Leemos un entero n
syscall
move $t0, $v0	#alamacenar el n en $t0 (Mover datos)
#reservamos memoria para los coeficientes
addi $t1, $t0, 1	#Si n es 4, el N° coeficientes es n + 1 = 5
li $t2, 4		#guardamos 4 en $t2
mul $a0, $t2, $t1	#calculamos el N° de bytes (5 * 4) = 20 en $a0
li $v0, 9		#reservamos memoria, el N°bytes en $a0 calculado antes
syscall
move $s0, $v0	#$v0 es el puntero a la memoria reservada

#Ingresamos los coeficientes
li $t3, 0		#Índice para el bucle

loop_coef:
	beq $t3, $t1, leer_x 	#Si $t3 >=  $t1 (n+1 = 5), leer x

	li $v0, 4
	la $a0, cad_coeff
	syscall
	li $v0, 6		#Modificamos para leer el coef en punto flotante
	syscall

	sll $t4, $t3, 2	#Calculamos cuanto se desplazara($t3 * 4bytes)
	add $t5, $s0, $t4	#Calcula la dirección exacta para el coeficiente 
	swc1 $f0, 0($t5)	#Guarda el valor del coeficiente en la dirección $t5
	addi $t3, $t3, 1	#incementar índice

	j loop_coef

#Solicitar el valor de x
leer_x:
	li $v0, 4
	la $a0, cad_x
	syscall

	li $v0, 6
	syscall
	mov.s $f12, $f0	#El valor de x se guarda en $f12

#El sumador se inicializa en 0.0
	mtc1 $zero, $f2     # Inicializar $f2 a 0.0
	cvt.s.w $f2, $f2    # Convertir de entero a float

# Evaluamos el polinomio
   	move $t3, $t0       # Empezamos desde el grado más alto (n)
	move $t8, $zero	# Indice para recorrer los coeficientes
recorrer_coef:
	bltz $t3, print     # Si $t3 < 0, imprimir el resultado
	sll $t4, $t8, 2	# Desplazamiento para acceder al coeficiente
	add $t5, $s0, $t4	# Dirección del coeficiente
	lwc1 $f4, 0($t5)	# Cargar el coeficiente

	 # Calcular x^t3
    	li $t6, 1
    	mtc1 $t6, $f6
    	cvt.s.w $f6, $f6        # Inicializamos la potencia en 1.0
	beqz $t3, skip_pow      # Si el exponente es 0, saltamos el cálculo de la potencia
    	mov.s $f8, $f12         # $f8 = x
    	li $t7, 0               # Contador para la potencia
    
    
pow_loop:
    	beq $t7, $t3, end_pow_loop  # Si hemos llegado a la potencia deseada, salir
    	mul.s $f6, $f6, $f8     # Multiplicar por x
    	addi $t7, $t7, 1        # Incrementar el contador de la potencia
    	j pow_loop              # Repetir
end_pow_loop:
skip_pow:
    	mul.s $f4, $f4, $f6     # Multiplicar coeficiente * x^t3
    	add.s $f2, $f2, $f4     # Acumular el resultado en $f2
   	subi $t3, $t3, 1        # Incrementar el índice de las potencias
   	addi $t8, $t8, 1	    # Incrementar el índice del coeficiente	

   	j recorrer_coef         # Volver al bucle
	
print:
li $v0, 4
la $a0, cad_rest
syscall

li $v0, 2
mov.s $f12, $f2
syscall

li $v0,10
syscall
.data
	cad_n:        .asciiz "Ingrese el grado del polinomio deseado: "
	cad_coeff:   .asciiz "Ingrese el coeficiente: "
	cad_x:	   .asciiz "Ingrese el valor de x: "
	cad_rest:     .asciiz "El resultado del polinomio es: "
	