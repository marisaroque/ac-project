; *********************************************************************************
; * Jogo Batalha Espacial
; * Arquitectura de Computadores (2012/2013)
; *
; * Autores:  Paulo Cabe�as   76358
; *           Marisa Roque    76653
; *           Sara Santos     76358
; *********************************************************************************


; *********************************************************************************
; * Constantes
; *********************************************************************************
DOIS			EQU 2H
QUATRO			EQU 4H
OITO			EQU 8H
DEZ 			EQU 10			; base decimal
TAMANHO_PX		EQU 32			; pixeis, ecra � sempre quadrado
LIMITE_64		EQU 64			; limite superior na escrita de palavras no pixelscreen
LIMITE_128		EQU 128			; limite superior na escrita de palavras no pixelscreen
PX_SCREEN		EQU 8000H		; endere�o do pixelscreen (inicio)
TECLADO_OUT		EQU 0C000H		; endere�o do porto de E/S do teclado
TECLADO_IN		EQU 0E000h
DISPLAY 		EQU 0A000H		; endere�o do porto dos displays hexadecimais
NORMAL			EQU 0			; estado_jogo: situa��o normal de jogo
PAUSADO			EQU 1			; estado_jogo: jogo em pausa
TERMINADO		EQU 2			; estado_jogo: jogo terminado

; *********************************************************************************
; * Configuracoes
; *********************************************************************************
ENERGIA_INICIAL		EQU 80
ENERGIA_MAXIMO		EQU 99
BONUS_ENERGIA		EQU 10		; valor do bonus de energia ao destruir um alien
N_ALIENS		EQU 4		; numero de aliens
NAVE_X_INICIAL		EQU 20
NAVE_Y_INICIAL		EQU 15
ORIENTACAO_INICIAL	EQU 1
RAIO_INICIAL		EQU 0
ENERGIA_TEMP		EQU 2
TAMANHO_RAIO		EQU 5		; tamanho do raio, a contar do centro da nave
ALIEN_X0_INICIAL    	EQU 30
ALIEN_Y0_INICIAL    	EQU 30
ALIEN_X1_INICIAL    	EQU 1
ALIEN_Y1_INICIAL    	EQU 1
ALIEN_X2_INICIAL    	EQU 30
ALIEN_Y2_INICIAL    	EQU 1
ALIEN_X3_INICIAL    	EQU 1
ALIEN_Y3_INICIAL    	EQU 30
; *********************************************************************************
; * Stack 
; *********************************************************************************
PLACE		1000H					; localiza blocos de dados
			
pilha:		TABLE 200H				; espa�o reservado para a pilha 

SP_inicial:						; este � o endere�o com que o SP deve ser inicializado. 

; *********************************************************************************
; * Dados
; *********************************************************************************								
table_pxscreen: 			WORD 10000000b	; 0 tabela de 8 m�scaras (cada uma s� com um bit a 1)
					WORD 01000000b	; 1	para desenhar no pixel screen
					WORD 00100000b	; 2
					WORD 00010000b	; 3
					WORD 00001000b	; 4
					WORD 00000100b	; 5	
					WORD 00000010b	; 6		
					WORD 00000001b	; 7

table_alien:				WORD 00000101b	; 1a linha
					WORD 00000010b	; 2a linha
					WORD 00000101b	; 3a linha
					
table_nave: 				WORD 00000111b	; 1a linha
					WORD 00000101b	; 2a linha
					WORD 00000111b	; 3a linha


table_x: 				WORD 0			; componente no eixo y da direcao no sistema de eixos do ecra
					WORD 1
					WORD 1
					WORD 1
					WORD 0
					WORD -1
					WORD -1
					WORD -1

table_y: 				WORD -1			; componente no eixo y da direcao no sistema de eixos do ecra
					WORD -1
					WORD 0
					WORD 1
					WORD 1
					WORD 1
					WORD 0
					WORD -1	

teclado_direccao: 			WORD 7			; tabela para converter as teclas em orientacoes
					WORD 0			; o valor da tecla sera o indice 
					WORD 1			; usa-se -1 para perfazer uma tabela de 16 entradas
					WORD -1
					WORD 6
					WORD -1
					WORD 2
					WORD -1
					WORD 5
					WORD 4
					WORD 3
					WORD -1
					WORD -1
					WORD -1
					WORD -1
					
					
nave_x: 			WORD NAVE_X_INICIAL
nave_y: 			WORD NAVE_Y_INICIAL
raio_on:			WORD RAIO_INICIAL
energia:			WORD ENERGIA_INICIAL 		
canhao_index:			WORD ORIENTACAO_INICIAL		; indice das tabelas y e x


table_teclado:  			WORD andar 			; 0
					WORD andar 			; 1
					WORD andar 			; 2
					WORD pausa 			; 3
					WORD andar			; 4
					WORD disparar 			; 5
					WORD andar 			; 6
					WORD sair 			; 7
					WORD andar 			; 8
					WORD andar 			; 9
					WORD andar 			; A
					WORD reset 			; B
					WORD gira_esquerda  		; C
					WORD gira_direita 		; D
					WORD nada 			; E
					WORD nada 			; F
					
alien_x_inicial:			WORD ALIEN_X0_INICIAL	; tabela com posi��es x iniciais dos aliens para repor mais facilmente 
					WORD ALIEN_X1_INICIAL
					WORD ALIEN_X2_INICIAL
					WORD ALIEN_X3_INICIAL
										
alien_y_inicial:			WORD ALIEN_Y0_INICIAL	; tabela com posi��es y iniciais dos aliens para repor mais facilmente 
					WORD ALIEN_Y1_INICIAL
					WORD ALIEN_Y2_INICIAL
					WORD ALIEN_Y3_INICIAL	
						
alien_x:				WORD ALIEN_X0_INICIAL	;  tabela com posi��es x dos aliens
					WORD ALIEN_X1_INICIAL
					WORD ALIEN_X2_INICIAL
					WORD ALIEN_X3_INICIAL
					
alien_y:				WORD ALIEN_Y0_INICIAL	;  tabela com posi��es y dos aliens
					WORD ALIEN_Y1_INICIAL
					WORD ALIEN_Y2_INICIAL
					WORD ALIEN_Y3_INICIAL

					
estado_jogo: 		WORD NORMAL
redesenha:		WORD 1
redesenha_energia:	WORD 1
				
				
tecla_flanco:		WORD 0					; 0 = flanco ascendente; 1 flanco descendente
tecla_transicao:	WORD 0					; 0 = sem transi��o; 1 = com transi�ao
tecla_anterior:		WORD -1					; guarda a tecla pressionada entre itera��es, para detectar transi��es

; Tabela de vectores de interrup��o
tabela_interrupcoes:	WORD relogio_aliens
			WORD relogio_energia						

; *********************************************************************************
; * C�digo
; *********************************************************************************
PLACE			0000H						; o c�digo tem de come�ar em 0000H
inicio:			MOV	SP, SP_inicial				; inicializa SP para a palavra a seguir � �ltima da pilha
				MOV	BTE, tabela_interrupcoes	; incializa BTE

			   	CALL desenha_tudo		

				EI0					; permite interrup��es tipo 0
				EI1					; permite interrup��es tipo 1
				EI					; activa interrup�oes globais 
ciclo_inicio:			CALL teclado

				CALL detecta_flancos			; detectar tecla pressionada ou largada

				
				CALL invoca_accao				
				CALL detecta_game_over	
				CALL detecta_ataque		
				CALL desenha_tudo

				JMP ciclo_inicio


; *********************************************************************************
; * Rotinas de Interrup��es
; *********************************************************************************

; *********************************************************************************
; * Descri��o:	Trata a interrup��o do rel�gio da energia.
; *********************************************************************************
relogio_energia:
				PUSH R1
				PUSH R2
				PUSH R3
				
				MOV R3, estado_jogo				; nao detecta se j� terminado
				MOV R2, [R3] 
				CMP R2, TERMINADO
				JEQ f_rel_energia
				
				MOV R1, raio_on					; se raio desligado n�o faz nada
				MOV R2, [R1]
				CMP R2,0
				JEQ f_rel_energia
				
				MOV R1, energia					; l� energia
				MOV R2, [R1]
				MOV R3, ENERGIA_TEMP
				SUB R2, R3					; decrementa
				MOV [R1], R2					; escreve na mem�ria

				MOV R2, redesenha_energia			; activar flag, para redesenhar
				MOV R1, 1
				MOV [R2], R1

f_rel_energia:			POP R3
				POP R2
				POP R1
				RFE

; *********************************************************************************
; * Descri��o:	Trata a interrup��o do rel�gio dos aliens.
; *********************************************************************************
relogio_aliens:
				CALL mover_aliens
				RFE


; *********************************************************************************
; * Rotinas
; *********************************************************************************


; *********************************************************************************
; * Descri��o:	Detecta fim de jogo, por colis�o ou falta de energia
; * Entrada:		--
; * Sa�da:	 		--
; * Destr�i:		--
; *********************************************************************************

detecta_game_over:
					PUSH R1
					PUSH R2
					PUSH R3
					PUSH R9
					
					MOV R3, estado_jogo				; nao detecta se j� terminado
					MOV R2, [R3] 
					CMP R2, TERMINADO
					JEQ go_fim
					
					MOV R1, energia
					MOV R2, [R1]
					CMP R2, 0
					JLE go_terminado
					
					CALL detecta_colisao_aliens			; saida em R9
					CMP R9, 1
					JNE go_fim
					
go_terminado:				DI
					
					MOV R2, 0
					MOV [R1], R2 					; energia a zero
				
					MOV R2, TERMINADO				; muda o estado de jogo para terminado
					MOV [R3], R2
					
					MOV R2, redesenha				; activar flag, para redesenhar
					MOV R1, 1
					MOV [R2], R1
					
					MOV R2, redesenha_energia			; activar flag, para redesenhar energia
					MOV R1, 1
					MOV [R2], R1
					
go_fim:					POP R9
					POP R3
					POP R2
					POP R1		
					RET 

; *********************************************************************************
; * Descri��o:	Desenha aliens e nave
; * Entrada:		--
; * Sa�da:	 		--
; * Destr�i:		--
; *********************************************************************************
desenha_tudo:
				PUSH R0
				PUSH R1
				PUSH R2
				
				MOV R2, redesenha_energia			; nao mostra energia, se a flag estiver a 0. Para n�o piscar
				MOV R1, [R2]
				CMP R1, 0
				JEQ dt_screen
				CALL mostra_energia	
				
				MOV R1, 0					; ja' desenhou, limpa flag
				MOV [R2], R1
				
				
dt_screen:			MOV R2, redesenha				; nao desenha, se a flag estiver a 0. Para n�o piscar
				MOV R1, [R2]
				CMP R1, 0
				JEQ dt_fim
				
				MOV R0, estado_jogo				; nao desenha, se terminado
				MOV R1, [R0]
				CMP R1, TERMINADO
				JEQ dt_terminado				; if terminado { enche_screen } else {desenha nave + aliens }
				
	
				CALL limpa_screen
				CALL desenha_nave
				CALL desenha_aliens
	
				JMP dt_if_fim
				
dt_terminado:   CALL enche_screen
				
				
dt_if_fim:    			MOV R1, 0					; ja' desenhou, limpa flag
				MOV [R2], R1
				
dt_fim:				POP R2
				POP R1
				POP R0
				RET


; *********************************************************************************
; * Descri��o:	Altera/modifica no ecra o pixel nas coordenadas X e Y. 
; * Entrada:	R1 (Coordenada X do ecra)
;         		R2 (Coordenada Y do ecra)
;             	R9 (Accao a fazer: apagar = 0 / acender = 1)
; * Sa�da:			--
; * Destr�i:		--
; *********************************************************************************
; * Notas:
; *(0,0) do pixelscreen � o canto superior esquerdo.
 
modifica_pixel:
				PUSH R3						; salvaguarda registos
				PUSH R4
				PUSH R5
				PUSH R6
				PUSH R7
				PUSH R8
				
				; 1� fase: descobrir qual o endere�o do byte a ser lido do pixel screen
				
				; 8000h + (y * 4 + x / 8) = endereco do byte de interesse, resultado em R3
				MOV R3, R2					; primeira parte: y * 4, resultado em R3
				MOV R4, QUATRO
				MUL R3, R4
				MOV R4, R1					; segunda parte: x / 8, resultado em R4
				MOV R5, OITO
				DIV R4, R5
				ADD R3, R4					; junta as duas partes, resultado em R3
				MOV R5, PX_SCREEN 				; somar offset do endereco do ecra
				ADD R3, R5
		
				; 2� fase: descobrir qual a posi��o do bit a ser modificado do pixel screen
				MOV R6, R1					; x % 8 = posi��o do bit de interesse, resultado em R6
				MOV R7, OITO	
				MOD R6, R7
		
				; multiplicar por dois, devido � cena par/impar da RAM
				MOV R7, DOIS
				MUL R6, R7
		
				MOV R7, table_pxscreen
				ADD R7, R6
				ADD R7, 1
				MOVB R8, [R7]				; m�scara
				
				; 3� fase: ler do endere�o calculado o byte a ser modificado
				; ler o byte de interesse do ecra, resultado em R4
				MOVB R4, [R3]
				
				; 4� fase: modificar o bit de interesse
				
				; if acende = true
				CMP R9, 0
				JZ apaga
				OR R8, R4
				JMP fim_if

apaga:				NOT R8
				AND R8, R4
		
				; 5� fase: reescrever o byte modificado no endereco de interesse no ecra
fim_if:				MOVB [R3], R8
			
				POP R8						; restaura registos
				POP R7
				POP R6
				POP R5
				POP R4
				POP R3
				RET

; *********************************************************************************
; * Descri��o:	Move N aliens com base nas coordenadas da tabela.
; * Entrada:		--
; * Sa�da:	 		--
; * Destr�i:		--
; *********************************************************************************

mover_aliens: 				PUSH R1
					PUSH R2
					PUSH R3
					PUSH R4
					PUSH R5
					PUSH R6
				
					MOV R5, 0 				; inicializa variavel de indice
					MOV R6, N_ALIENS 			; inicializa numero de aliens (N)
					SHL R6, 1				; N_ALIENS * 2
					MOV R3, alien_x
					MOV R4, alien_y


percorre_aliens1:			CMP R5, R6
					JGE terminou1
					
					MOV R1, [R3+R5]				; alien_x
					MOV R2, [R4+R5]				; alien_y

					CALL andar_alien			; modifica R1 e R2
					
					MOV [R3+R5], R1				; actualiza em memoria
					MOV [R4+R5], R2 
					
					ADD R5, 2				; par/impar	
					JMP percorre_aliens1

terminou1:			MOV R2, redesenha				; activar flag, para redesenhar
					MOV R1, 1
					MOV [R2], R1

					POP R6
					POP R5
					POP R4
					POP R3
					POP R2
					POP R1
					RET

; *********************************************************************************
; * Descri��o:	Andar aliens
; * Entrada:		R1 (x_alien), R2 (y_alien)
; * Sa�da:	 		R1 (x_alien), R2 (y_alien)
; * Destr�i:		--
; *********************************************************************************

andar_alien:	 
				PUSH R4
				PUSH R5
				PUSH R6

				;;;;;;;;;
				; 	X	;
				;;;;;;;;;
				
				MOV R6, nave_x		; endere�o nave_x
				MOV R4,[R6]		; nave_x
				
				CMP R4,R1			
				JZ fim_x		; nave_x (R4) = alien_x (R1)
				JGT aumenta_x 		; nave_x (R4) > alien_x (R1)
				SUB R1,1            	; senao diminui o x uma unidade
				JMP fim_x
aumenta_x: 			ADD R1,1         	; aumenta uma unidade ao x do alien

				;;;;;;;;;
				; 	Y	;
				;;;;;;;;;

fim_x:				MOV R6,nave_y    	; endere�o nave_y
				MOV R4,[R6]		; nave_y
				
				CMP R4,R2			
				JZ fim_y		; nave_y = alien_y
				JGT aumenta_y		; nave_y (R4) > alien_y (R2)
				SUB R2,1
				JMP fim_y
		 		 
aumenta_y: 			ADD R2,1


fim_y: 				POP R6
				POP R5
				POP R4
				RET

; *********************************************************************************
; * Descri��o:	Desenha N aliens com base nas coordenadas da tabela.
; * Entrada:		--
; * Sa�da:	 		--
; * Destr�i:		--
; *********************************************************************************

desenha_aliens:				PUSH R1
					PUSH R2
					PUSH R3
					PUSH R4
					PUSH R5
					PUSH R6
					PUSH R7
				
					MOV R5, 0 		; inicializa variavel de indice
					MOV R6, N_ALIENS 	; inicializa numero de aliens
					SHL R6, 1		; N_ALIENS * 2
					MOV R3, alien_x
					MOV R4, alien_y


percorre_aliens:	CMP R5, R6
					JGE terminou
					
					MOV R1,[R3+R5]		; alien_x
					MOV R2, [R4+R5]		; alien_y
					
					CALL desenha_alien
					
					ADD R5, 2		; par/impar	
					JMP percorre_aliens

terminou:				POP R7
					POP R6
					POP R5
					POP R4
					POP R3
					POP R2
					POP R1
					RET

; *********************************************************************************
; * Descri��o:	Desenha um alien no ecra com base nas coordenadas X e Y, que � o seu centro.
; * Entrada:		R1 (Coordenada X do centro do alien)
;			R2 (Coordenada Y do centro do alien)
; * Sa�da:	 	--
; * Destr�i:		--
; *********************************************************************************

desenha_alien:
					PUSH R10
					MOV R10, table_alien 		; tabela com os pixeis do alien
					CALL desenha_objecto		; entra R1, R2 e R10
					POP R10
					RET

; *********************************************************************************
; * Descri��o:	Desenha um nave no ecra com base nas coordenadas X e Y, que � o seu centro.
; * Entrada:		--
; * Sa�da:	 	--
; * Destr�i:		--
; *********************************************************************************

desenha_nave:
				PUSH R1
				PUSH R2
				PUSH R3
				PUSH R4
				PUSH R10
				
				MOV R10, table_nave 			; tabela com os pixeis da nave
				MOV R3, nave_x				; endere�o x_nave
				MOV R4, nave_y				; endere�o y_nave
				MOV R1, [R3]				; x_nave
				MOV R2, [R4] 				; y_nave
				
				CALL desenha_objecto			; entra R1, R2 e R10
				
				MOV R3, raio_on				; desenha raio ou canh�o conforme variavel raio_on
				MOV R4, [R3]
				CMP R4, 0
				JEQ canhao
				CALL desenha_raio
				JMP fim_des_nave	
canhao:				CALL desenha_canhao
				
fim_des_nave:			POP R10
				POP R4
				POP R3
				POP R2
				POP R1
				RET


; *********************************************************************************
; * Descri��o:	Desenha um objecto (nave/alien) no ecra com base nas coordenadas X e Y, que � o seu centro.
; * Entrada:		R1 (Coordenada X do centro do objecto)
;			R2 (Coordenada Y do centro do objecto)
;			R10 (Tabelas da nave ou do alien)
; * Sa�da:	 	--
; * Destr�i:		--
; *********************************************************************************
; * Notas:
; * O objecto tem 3x3 pixeis

desenha_objecto:
				PUSH R3							; salvaguarda registos
				PUSH R4
				PUSH R5
				PUSH R6
				PUSH R7
				PUSH R8
				PUSH R9
				
				MOV R3, R1						; backup de R1 (x_centro)
				MOV R4, R2						; backup de R2 (y_centro)
				
				MOV R5, -1						; variavel do ciclo for 
			
ciclo_nave:			CMP R5, 2						; sair do ciclo quando for >= 3
				JGE fim_nave
			
				MOV R2, R4						; y_centro
				ADD R2, R5						; y_pixel = y_centro + i	
				
				MOV R7, R5						; posicao_memoria = 3 + 2 * R5 + table_nave
				SHL R7, 1						; equivale a multiplicar por 2
				ADD R7, 3
				ADD R7, R10
				
				MOVB R6, [R7]						; ler o byte original da tabela
	
				MOV R9, R6
				MOV R8, 00000100b
				AND R9, R8			 			; mascara para definir o bit de interesse
				SHR R9, 2 						; meter o bit de interesse na posicao de menor peso					
				MOV R1, R3						; x_centro
				SUB R1, 1						; x_pixel = x_centro - 1
				CALL modifica_pixel
				
				MOV R9, R6
				MOV R8, 00000010b
				AND R9, R8		
				SHR R9, 1
				MOV R1, R3						; x_pixel = x_centro
				CALL modifica_pixel
				
				MOV R9, R6
				MOV R8, 00000001b
				AND R9, R8		
				MOV R1, R3						; x_centro
				ADD R1, 1						; x_pixel = x_centro + 1
				CALL modifica_pixel
	
				ADD R5, 1						; incrementa a variavel do ciclo
				JMP ciclo_nave
				


fim_nave:			MOV R1, R3						; restore de R1 (x_centro)
				MOV R2, R4						; restore de R2 (y_centro)
				POP R9							; restaura registos
				POP R8
				POP R7
				POP R6		
				POP R5
				POP R4
				POP R3
				RET

; *********************************************************************************
; * Descri��o:		Verifica ataque aos aliens.
; * Entrada:		--
; * Sa�da:		--
; * Destr�i: 		-- 
; *********************************************************************************
detecta_ataque:
				PUSH R0
				PUSH R1
				PUSH R2
				PUSH R3
				PUSH R4
				PUSH R5
				PUSH R6
				PUSH R7
				PUSH R8
				PUSH R9
				PUSH R10
				PUSH R11

				
				MOV R1, estado_jogo				; nada, se jogo terminado
				MOV R1, [R1]
				CMP R1, TERMINADO
				JEQ da_fim
				
				MOV R1, raio_on					; nada, se raio desligado
				MOV R1, [R1]
				CMP R1, 0
				JEQ da_fim


				MOV R1, nave_x
				MOV R2, nave_y
				MOV R1, [R1]					; x_nave
				MOV R2, [R2]
				MOV R10, TAMANHO_RAIO				; tamanho do raio, a contar do centro da nave
						
				CALL coordenadas_raio				; entra R1, R2, R10. calcular coordenadas da ponta do raio. resultado em R3, R4
		
		
				MOV R0, 0					; indice do loop
				MOV R11 ,N_ALIENS
				SHL R11 ,1		
da_loop:			CMP R0, R11
				JEQ da_fim


				CALL detecta_ataque_alien

				
da_proximo:			ADD R0, 2					; par/impar
				JMP da_loop
				
da_fim:				POP R11
				POP R10
				POP R9
				POP R8
				POP R7
				POP R6		
				POP R5
				POP R4
				POP R3
				POP R2
				POP R1
				POP R0
				RET 
				
; *********************************************************************************
; * Descri��o:		Verifica se a ponta do raio colide com alien.
; * Entrada:		R0 (offset das tabelas alien_x, alien_y, alien_x_inicial, alien_y_inicial
;			R3 (x_raio)
;			R4 (y_raio)
; * Sa�da:		--
; * Destr�i: 		-- 
; *********************************************************************************
detecta_ataque_alien:
				PUSH R0
				PUSH R1
				PUSH R2
				PUSH R3
				PUSH R4
				PUSH R5
				PUSH R6
				PUSH R7
				PUSH R8
				PUSH R9
				PUSH R10
				PUSH R11

				MOV R5, 1					; dist�ncia limite da colis�o entre raio e aliens
				MOV R7, alien_x
				MOV R8, alien_y
				MOV R10, alien_x_inicial			; endere�o da tabela de posi��es iniciais dos aliens
				MOV R6, alien_y_inicial
				
				
				MOV R1, [R7 + R0]				; x_alien
				MOV R2, [R8 + R0]

				CALL detecta_colisao				; entra R1,R2,R3,R4,R5, saida em R9
				CMP R9, 1
				JNE daa_fim
		

				MOV R1, [R10 + R0]				; conteudo da tabela de posi��es iniciais dos aliens
				MOV R2, [R6 + R0]
				
				MOV [R7 + R0], R1				; copiar para a tabela das posi��es dos aliens
				MOV [R8 + R0], R2
				
				CALL add_bonus_energia				; incrementa o bonus de energia
				
daa_fim:			POP R11
				POP R10
				POP R9
				POP R8
				POP R7
				POP R6		
				POP R5
				POP R4
				POP R3
				POP R2
				POP R1
				POP R0
				RET
				
; *********************************************************************************
; * Descri��o:		Incrementa a energia da NAVE, depois da morte de um alien
; * Entrada:		--
; * Sa�da:		--
; * Destr�i: 		--
; *********************************************************************************
add_bonus_energia:
				PUSH R1
				PUSH R2
				PUSH R3
				PUSH R4
				
				MOV R2, energia				; incrementar BONUS_ENERGIA de energia
				MOV R1, [R2]
				MOV R3, BONUS_ENERGIA
				ADD R1, R3
				
				MOV R4, ENERGIA_MAXIMO			; h� um m�ximo de energia
				CMP R1, R4
				JLT abe_escreve
				
				MOV  R1, R4	
				
abe_escreve:	MOV [R2], R1
				
				MOV R2, redesenha_energia		; activar flag, para redesenhar
				MOV R1, 1
				MOV [R2], R1
				
				POP R4
				POP R3
				POP R2
				POP R1
				RET


; *********************************************************************************
; * Descri��o:		Verifica se existe colisao entre objectos.
;					|x_1 - x_2 | <= d AND |y_1 - y_2| <= d
; * Entrada:		R1 (x do objecto 1)
;					R2 (y do objecto 1)
;					R3 (x do objecto 2)
;					R4 (y do objecto 2)
;					R5 ( distancia limite da colis�o )
; * Sa�da:			R9 (Colisao = 1 / Sem colisao = 0)
; * Destr�i: 		R3, R4
; *********************************************************************************
detecta_colisao:

				MOV R9, 0				; inicializar R9 = 0: sem colisao
				
				SUB R3, R1
				JNN positivo_x	
				NEG R3
positivo_x:			CMP R3, R5				; |x_1 - x_2| <= d
				JGT dc_fim
				
				SUB R4, R2
				JNN positivo_y
				NEG R4
positivo_y:			CMP R4, R5
				JGT dc_fim
				
				MOV R9, 1				; houve colisao entre os objectos
				
dc_fim:				RET

; *********************************************************************************
; * Descri��o:		Verifica se existe colisao entre os aliens e a nave.
; * Entrada:		--
; * Sa�da:		R9 (Colisao = 1 / Sem colisao = 0)
; * Destr�i: 		--
; *********************************************************************************
detecta_colisao_aliens:
				PUSH R0
				PUSH R1
				PUSH R2
				PUSH R3
				PUSH R4
				PUSH R5
				PUSH R6
				PUSH R7
				PUSH R8
				PUSH R10
				
				MOV R7, alien_x				; endere�os das coordenadas dos alien
				MOV R8, alien_y
				
				MOV R1, nave_x				; endere�os das coordenadas da nave
				MOV R2, nave_y
				MOV R1, [R1]				; x_nave
				MOV R2, [R2]				; y_nave
				
				MOV R5, DOIS				; dist�ncia limite da colis�o entre nave e aliens
				
				MOV R10, 0 					; inicializa variavel do indice
				MOV R0, N_ALIENS
				SHL R0, 1					; N_ALIENS * 2
				
				
dca_loop: 			CMP R10, R0	
				JGE dca_fim_loop
	
				MOV R3, [R7+R10]			; x_alien
				MOV R4, [R8+R10]			; y_alien
	
				CALL detecta_colisao			; retorna 1/0 em R9
				CMP R9, 1
				JEQ dca_fim_loop
				
				ADD R10, 2				; par/impar	
				JMP dca_loop
	
dca_fim_loop:	POP R10
				POP R8
				POP R7			
				POP R6
				POP R5
				POP R4
				POP R3
				POP R2
				POP R1
				POP R0
				RET
			
; *********************************************************************************
; * Descri��o:	Incrementa o indice da direccao do canhao, fazendo-o virar � direita.
; * Entrada:		--
; * Sa�da:		--
; * Destr�i: 		--
; *********************************************************************************
gira_direita: 	
				PUSH R1
				PUSH R2
				PUSH R3
				PUSH R4
				PUSH R5
				PUSH R6
				PUSH R7
				PUSH R8
							
				MOV R7, estado_jogo 			; verificar o estado do jogo
				MOV R8, [R7]
				CMP R8, NORMAL				; em caso afirmativo o canh�o n�o gira
				JNE fim
				
				MOV R3, canhao_index 			
				MOV R4, [R3]
				
				MOV R6, nave_x
				MOV R6, [R6]					; x_nave
				MOV R7, nave_y
				MOV R7, [R7]					; y_nave
				
				; parede � esquerda
				CMP R6, 1						; x_nave = 1, canhao_index = 4, n�o incrementar
				JNE fim_parede_e
				CMP R4, 4
				JEQ fim
				
				; parede � direita
fim_parede_e:			MOV R5, TAMANHO_PX
				SUB R5, 2
				CMP R6, R5						; x_nave = 31, canhao_index = 0, n�o incrementar		
				JNE fim_parede_d	
				CMP R4, 0
				JEQ fim		
				
				; parede em cima
fim_parede_d:			CMP R7, 1						; y_nave = 1, canhao_index = 6, n�o incrementar		
				JNE fim_parede_c
				CMP R4, 6
				JEQ fim	

				; parede em baixo
fim_parede_c:			CMP R7, R5						; y_nave = 31, canhao_index = 2, n�o incrementar		
				JNE fim_parede_b
				CMP R4, 2
				JEQ fim	
				
fim_parede_b:			ADD R4, 1 						; incrementa o indice da direccao
				MOV R5, 00000111b	 
				AND R4, R5						; mascara para voltar para o zero  (incrementa entre 0 e 7)
				MOV [R3], R4
				
fim:				MOV R2, redesenha					; activar flag, para redesenhar
				MOV R1, 1
				MOV [R2], R1
					
				POP R8
				POP R7
				POP R6
				POP R5
				POP R4
				POP R3
				POP R2
				POP R1
				RET


; *********************************************************************************
; * Descri��o:	Decrementa o indice da direccao do canh�o, fazendo-o virar � esquerda.
; * Entrada:		--
; * Sa�da:		--
; * Destr�i: 		--
; *********************************************************************************

gira_esquerda: 
				PUSH R1
				PUSH R2
				PUSH R3
				PUSH R4
				PUSH R5
				PUSH R6
				PUSH R7
				PUSH R8
				
				MOV R7, estado_jogo 			; verificar o estado do jogo
				MOV R8, [R7]
				CMP R8, NORMAL					; em caso afirmativo o canhao n�o gira
				JNE fim1
							
				
				MOV R3, canhao_index 	
				MOV R4, [R3]
				
				MOV R6, nave_x
				MOV R6, [R6]					; x_nave
				MOV R7, nave_y
				MOV R7, [R7]					; y_nave
				
				; parede � esquerda
				CMP R6, 1						; x_nave = 1, canhao_index = 0, n�o incrementar
				JNE fim_parede_e1
				CMP R4, 0
				JEQ fim1
				
				; parede � direita
fim_parede_e1:			MOV R5, TAMANHO_PX
				SUB R5, 2
				CMP R6, R5						; x_nave = 31, canhao_index = 4, n�o incrementar		
				JNE fim_parede_d1	
				CMP R4, 4
				JEQ fim1		
				
				; parede em cima
fim_parede_d1:			CMP R7, 1						; y_nave = 1, canhao_index = 2, n�o incrementar		
				JNE fim_parede_c1
				CMP R4, 2
				JEQ fim1	

				; parede em baixo
fim_parede_c1:			CMP R7, R5						; y_nave = 31, canhao_index = 6, n�o incrementar		
				JNE fim_parede_b1
				CMP R4, 6
				JEQ fim1

				
fim_parede_b1:			SUB R4, 1 						; decrementa o indice da direccao
				MOV R5, 00000111b	 
				AND R4, R5						; mascara para voltar para o zero (decrementa entre 0 e 7)
				MOV [R3], R4	
				
				
fim1:				MOV R2, redesenha				; activar flag, para redesenhar
				MOV R1, 1
				MOV [R2], R1
				
				POP R8
				POP R7
				POP R6
				POP R5
				POP R4
				POP R3
				POP R2
				POP R1
				RET


; *********************************************************************************
; * Descri��o:	Calcula as coordenadas a uma determinada dist�ncia, segundo a orienta��o do canh�o.
; * Entrada:		R1 (posi�ao x do centro da nave)
;					R2 (posicao y do centro da nave)
;					R10 (distancia do raio)
;
; * Sa�da:			R3 (posi��o x do raio)
;					R4 (posi��o y do raio)
; * Destr�i: 		--
; *********************************************************************************
coordenadas_raio:
				PUSH R5
				PUSH R6

				MOV R6, canhao_index
				MOV R5, [R6]
				SHL R5,1				; corresponde a multiplicar por 2. par/impar
				
				MOV R6, table_x
				MOV R3,[R6 + R5]
				
				; x_canhao = x_centro + (table_x * 2)
				MUL R3, R10				; multiplicar pelo tamanho do raio (entre 2 e 5)
				ADD R3, R1
				
				
				MOV R6, table_y
				MOV R4, [R6 + R5]
				
				; y_canhao = y_centro + (table_y * 2)
				MUL R4, R10				; multiplicar pelo tamanho do raio (entre 2 e 5)
				ADD R4, R2

				POP R6
				POP R5
				RET
				

; *********************************************************************************
; * Descri��o:	Fun��o que desenha o canh�o da nave.
; * Entrada:	R1 ( posi�ao x do centro da nave )
;				R2 ( posicao y do centro da nave )
; * Sa�da:		--
; * Destr�i: 	--
; *********************************************************************************

desenha_canhao: 
				PUSH R3
				PUSH R4
				PUSH R9
				PUSH R10
				
				MOV R10, 2						; tamanho 2 do raio (corresponde ao canhao)
				
				CALL coordenadas_raio 

				MOV R9, 1						; 1 para acender o pixel

				MOV R1, R3
				MOV R2, R4
				
				CALL modifica_pixel
					
				POP R10
				POP R9
				POP R4
				POP R3
				RET

; *********************************************************************************
; * Descri��o:	Fun��o que desenha o raio da nave.
; * Entrada:	R1 ( posi�ao x do centro da nave )
;				R2 ( posicao y do centro da nave )
; * Sa�da:		--
; * Destr�i: 	--
; *********************************************************************************

desenha_raio: 
				PUSH R3
				PUSH R4
				PUSH R5
				PUSH R6
				PUSH R7
				PUSH R9
				PUSH R10

				MOV R10, 2						; tamanho 2 do raio (corresponde ao canhao)
				
dr_loop:		CMP R10, TAMANHO_RAIO
				JGT dr_fim

				MOV R5, R1						; guardar x_nave, porque modifica_pixel precisa de R1 com outro valor
				MOV R6, R2
				CALL coordenadas_raio 			; saidas em R3 e R4


				MOV R1, R3
				MOV R2, R4
				MOV R9, 1						; 1 para acender o pixel
				
				; n�o deixa desejar para al�m das paredes do ecra
				MOV R7, TAMANHO_PX				; parede da direita
				CMP R1, R7
				JGE dr_fim

				CMP R2, R7						; parede de baixo
				JGE dr_fim		

				CMP R1, 0						; parede da esquerda
				JLT dr_fim
				
				CMP R2, 0						; parede de cima
				JLT dr_fim

				CALL modifica_pixel
				
				MOV R1, R5						; repor x_nave em R1
				MOV R2, R6
				
				ADD R10, 1						; pr�ximo pixel do raio
				JMP dr_loop
				
dr_fim:			POP R10
				POP R9
				POP R7
				POP R6
				POP R5
				POP R4
				POP R3
				RET


; *********************************************************************************
; * Descri��o:		Fun��o que altera a posi��o da nave.
; * Entrada:		R10 (Tecla premida)
; * Sa�da:			--
; * Destr�i: 		--
; *********************************************************************************

andar: 
				PUSH R9
				PUSH R8
				PUSH R7
				PUSH R6
				PUSH R5
				PUSH R4
				PUSH R3
				PUSH R2
				PUSH R1
				PUSH R0
				
				MOV R0, 0						; flag para detectar movimento para a energia
				
				MOV R7, estado_jogo 			; verificar o estado do jogo
				MOV R8, [R7]
				CMP R8, NORMAL					; em caso afirmativo n�o anda
				JNE fim_andar_y

				MOV R7, teclado_direccao
				
				MOV R4, R10
				SHL R4, 1						; R4 * 2, par/impar
				MOV R3, [R7+R4]					; orientacao do movimento em R3
				SHL R3, 1						; R3 * 2, par/impar
				
				;;;;;;;;;
				; 	X	;
				;;;;;;;;;
				
				MOV R7, table_x
				MOV R1, [R7 + R3]				; componente x do movimento
				CMP R1, 0
				JEQ fim_andar_x
				
				MOV R9, canhao_index	
				MOV R9, [R9]
				SHL R9, 1						; R9 * 2		
				MOV R9, [R7+R9]					; componente x da orientacao do canhao, x_canhao (R9)
		
				; x_novo (R5) = x_antigo (R5) + e_x (R1)
				MOV R7, nave_x
				MOV R5, [R7]		
				ADD R5, R1 
				
				; testar x_novo com a parede da direita
				MOV R8, TAMANHO_PX				; limite (R8) a ser construido
				SUB R8, 1
				CMP R9,0						; se x_canhao (R9) >= 0, o limite (R8) decresce 1
				JLT fim_canhao_x_d
				SUB R8, R9		
fim_canhao_x_d:	CMP R5, R8 
				JGE fim_andar_x					; fora da parede da direita. nao se actualiza e nao se testa a parede da esquerda

				; testar x_novo com a parede da esquerda
				MOV R8, 1						
				CMP R9, 0						; se x_canhao (R9) <= 0, o limite (R8) cresce 1
				JGT fim_canhao_x_e
				SUB R8, R9				
fim_canhao_x_e: CMP R5,R8
				JLT fim_andar_x
				
				; limites X testados, actualizar memoria	
				MOV [R7], R5					; actualiza x_novo em memoria
				MOV R0, 1						; movimento efectuado
				
				
				;;;;;;;;;
				; 	Y	;
				;;;;;;;;;
				
fim_andar_x:	MOV R7, table_y
				MOV R2, [R7 + R3]				; componente y do movimento
				CMP R2, 0
				JEQ fim_andar_y
				
				MOV R9, canhao_index	
				MOV R9, [R9]
				SHL R9, 1						; R9 * 2		
				MOV R9, [R7+R9]					; componente y da orientacao do canhao, y_canhao (R9)				
				
				
				; y_novo (R6) = y_antigo (R6) + e_x (R2)
				MOV R7, nave_y
				MOV R6, [R7] 
				ADD R6, R2
				
				; testar y_novo com a parede de baixo
				MOV R8, TAMANHO_PX				; limite (R8) a ser construido
				SUB R8, 1
				CMP R9,0						; se y_canhao (R9) >= 0, o limite (R8) decresce 1
				JLT fim_canhao_y_b
				SUB R8, R9		
fim_canhao_y_b:	CMP R6, R8 
				JGE fim_andar_y					; fora da parede de baixo. nao se actualiza e nao se testa a parede de cima
				
				; testar y_novo com a parede de cima
				MOV R8, 1
				CMP R9, 0						; se x_canhao (R9) <= 0, o limite (R8) cresce 1
				JGT fim_canhao_y_c
				SUB R8, R9				
fim_canhao_y_c: CMP R6,R8
				JLT fim_andar_y
				
				; limites Y testados, actualizar memoria	
				MOV [R7], R6
				MOV R0, 1						; movimento efectuado
				
fim_andar_y:	MOV R7, energia
				MOV R6, [R7]
				SUB R6, R0						; R0 tem 0 ou 1 consoante movimentos efectuados ou nao
				MOV [R7], R6
				
				MOV R2, redesenha				; activar flag, para redesenhar
				MOV R1, R0						;  R0 tem 0 ou 1 consoante movimentos efectuados ou nao
				MOV [R2], R1
				
				MOV R2, redesenha_energia		; activar flag, para redesenhar energia
				MOV R1, R0
				MOV [R2], R1
				
				POP R0
				POP R1
				POP R2
				POP R3
				POP R4
				POP R5
				POP R6
				POP R7
				POP R8
				POP R9
				RET

; *********************************************************************************
; * Descri��o:		Fun��o que activa/desactiva o raio.
; * Entrada:		--
; * Sa�da:			--
; * Destr�i: 		--
; *********************************************************************************

disparar: 		
				PUSH R0
				PUSH R1
				PUSH R2
				PUSH R7
				PUSH R6
				
				MOV R7, estado_jogo 	; verificar o estado do jogo
				MOV R6, [R7]
				CMP R6, NORMAL			; em caso afirmativo n�o dispara
				JNE dispa_fim

				MOV R0, raio_on
				MOV R1, [R0]			; ler estado do raio
				
		
				CMP R1, 0				
				JEQ dispara
				
				MOV R1, 0				; se raio ligado, desliga	
				JMP fim_disparar
	

dispara:		MOV R1, 1				; se raio desligado, liga
				MOV R7, energia			; decrementar 2 unidades de energia
				MOV R6, [R7]
				SUB R6, 2
				MOV [R7], R6	

		
fim_disparar:	MOV [R0], R1			; escrever estado do raio

				MOV R2, redesenha		; activar flag, para redesenhar
				MOV R1, 1
				MOV [R2], R1
				
				MOV R2, redesenha_energia		; activar flag, para redesenhar
				MOV R1, 1
				MOV [R2], R1
				
dispa_fim:		POP R6
				POP R7
				POP R2
				POP R1
				POP R0
				RET

; *********************************************************************************
; * Descri��o:		Interrompe o jogo at� ser chamada novamente ou o jogo recome�ado.
; * Entrada:		--
; * Sa�da:			--
; * Destr�i: 		--
; *********************************************************************************

pausa: 
				PUSH R0
				PUSH R1
				
				MOV R0, estado_jogo
				MOV R1, [R0]
				
				CMP R1, TERMINADO
				JEQ p_fim				; estado terminado, sair
				
				CMP R1, NORMAL
				JNE p_normal			
				
				DI						; parar interrup��es global	
				MOV R1, PAUSADO			; jogo normal, pausar
	
		  		JMP p_fim
		  		
p_normal: 		MOV R1, NORMAL			; jogo pausado, 
				EI						; recome�ar interrup��es
p_fim:			MOV [R0], R1
	
				POP R1
				POP R0
				RET

; *********************************************************************************
; * Descri��o:		Fun��o vazia para preencher na tabela de ac��es do teclado. 
; * Entrada:		--
; * Sa�da:			--
; * Destr�i: 		--
; *********************************************************************************

nada: 		
				NOP
				RET

; *********************************************************************************
; * Descri��o:		P�ra o jogo independentemente do estado actual.
; * Entrada:		--
; * Sa�da:			--
; * Destr�i: 		--
; *********************************************************************************
sair: 
				PUSH R0
				PUSH R1
	
				DI						; parar interrup��es
				MOV R0, estado_jogo		; endere�o do estado_jogo
			 	MOV R1, TERMINADO		; jogo pausado
				MOV [R0], R1			; escreve o estado em mem�ria
				
				CALL enche_screen		; mostra visualmente que o jogo acabou
				
				MOV R0, redesenha		; activar flag, para redesenhar
				MOV R1, 1
				MOV [R0], R1
				
				POP R1
				POP R0
				RET


; *********************************************************************************
; * Descri��o:		Recome�a o jogo, independentemente do estado actual.
; * Entrada:		--
; * Sa�da:			--
; * Destr�i: 		--
; *********************************************************************************
reset:
				PUSH R0
				PUSH R1
				PUSH R2
				PUSH R3
				PUSH R4
				PUSH R5
				PUSH R6
				
				DI							; suspender interrup��es, enquanto repomos o estado inicial
				
				MOV R0, estado_jogo			; endere�o do estado_jogo
			 	MOV R1, NORMAL				; recome�ar o estado
				MOV [R0], R1				; escreve o estado em memoria
	
				MOV R0, energia				; repor energia inicial
				MOV R1, ENERGIA_INICIAL
				MOV [R0], R1
	
				MOV R0, nave_x				; repor x_nave
				MOV R1, NAVE_X_INICIAL
				MOV [R0], R1
	
				MOV R0, nave_y				; repor y_nave
				MOV R1, NAVE_Y_INICIAL
				MOV [R0], R1
				
				MOV R0, canhao_index		; repor orienta��o da nave
				MOV R1, ORIENTACAO_INICIAL
				MOV [R0], R1
	
				MOV R0, raio_on				; repor estado do raio da nave
				MOV R1, RAIO_INICIAL
				MOV [R0], R1
				
				; repor posi��es dos aliens
				MOV R3, alien_x_inicial		
				MOV R0, alien_x
				MOV R5, alien_y_inicial		
				MOV R6, alien_y
				
				MOV R1, 0
				MOV R2, N_ALIENS
				SHL R2, 1					; R2 * 2; par/impar
r_loop:			CMP R1, R2
				JGE r_fim_loop
				
				MOV R4, [R3+R1]				; copia da tabela de valores iniciais de x
				MOV [R0+R1], R4
				MOV R4, [R5+R1]				; copia da tabela de valores iniciais de y
				MOV [R6+R1], R4
				
				ADD R1, 2
				JMP r_loop
				
r_fim_loop:		MOV R0, redesenha			; activar flag, para redesenhar
				MOV R1, 1
				MOV [R0], R1
				
				MOV R0, redesenha_energia	; activar flag, para redesenhar energia nos displays
				MOV R1, 1
				MOV [R0], R1
				
				EI							; recome�ar interrup��es
				
				POP R6
				POP R5
				POP R4
				POP R3
				POP R2
				POP R1
				POP R0
				RET

; *********************************************************************************
; * Descri��o:	Fun��o que limpa completamente o Pixel Screen.
; * Entrada:	--
; * Sa�da:		--
; * Destr�i: 	--
; *********************************************************************************
limpa_screen:
				PUSH 	R1					; salvaguarda registos
				PUSH 	R2
				PUSH 	R3
		
				MOV		R1, PX_SCREEN			; mete o endere�o do pixel screen em R1
				MOV		R3, LIMITE_128		; define o limite de bytes do pixel screen
				ADD 	R3, R1				
				MOV		R2, 0				; pixeis todos a 0		

ciclo_screen:	CMP		R1, R3					; testa se chegou ao fim da matriz
				JZ		fim_screen			; salta para fim_matriz caso tenha chegado

				MOVB	[R1], R2					; preenche os primeiros 8 bits com o valor
				ADD		R1, 1				; passa para os proximos 8 bits
				JMP 	ciclo_screen				; repete o ciclo at� ter limpo todo o pixel screen

fim_screen:		POP 	R3						; restaura registos 
				POP 	R2
				POP 	R1
				RET
				

; *********************************************************************************
; * Descri��o:	Fun��o que preenche completamente o Pixel Screen.
; * Entrada:	--
; * Sa�da:		--
; * Destr�i: 	--
; *********************************************************************************

enche_screen:
				PUSH 	R1					; salvaguarda registos
				PUSH 	R2
				PUSH 	R3
		
				MOV		R1, PX_SCREEN			; mete o endere�o do pixel screen em R1
				MOV		R3, LIMITE_128		; define o limite de bytes do pixel screen
				ADD 	R3, R1				
				MOV		R2, 0FFh				; pixeis todos a 1

ciclo_preenche:	CMP		R1, R3				; testa se chegou ao fim
				JZ		fim_preenche		

				MOVB	[R1], R2				; preenche os primeiros 8 bits com o valor
				ADD		R1, 1			; passa para os proximos 8 bits
				JMP 	ciclo_preenche		; repete o ciclo at� ter limpo toda a matriz

fim_preenche:	POP 	R3						; restaura registos 
				POP 	R2
				POP 	R1
				RET


; *********************************************************************************
; * Descri��o:		Fun�ao que faz a descodifica��o da tecla que foi premida.
; * Entrada:		--
; * Sa�da:			R10 (Tecla premida)
; * Destr�i: 		--
; *********************************************************************************

teclado:	
				PUSH R1
				PUSH R2
				PUSH R3
				PUSH R4
				PUSH R5
				PUSH R6
				PUSH R7
				PUSH R8
				
				MOV	R2, TECLADO_OUT		; R2 com o endere�o do perif�rico
				MOV R7, TECLADO_IN		
				MOV R5,2				; � usado as potencias de dois para relacionar a linha com as entradas e saidas do teclado
				
				MOV R6, 000FH			; m�scara para isolar o bit de menor peso
				
				MOV R8, 0				; R8 vai indicar qual a linha em teste
				MOV	R1, 1				; R1 vai ter o input correspondente � linha em teste. Inicia com linha 0 (0001b)	
				MOV R4, 4				; Limite para recome�ar o ciclo
				
ciclo_scan:		MOVB [R2], R1			; escrever no porto de sa�da (teclado)
				MOVB R3, [R7]			; ler do porto de entrada (teclado)
				AND R3, R6				; afectar as flags (MOVs n�o afectam as flags)
				JNZ fim_scan			; R3 != 0,  tecla premida
				MUL R1, R5				; proxima linha 
				ADD R8, 1
				CMP R8, R4
				JLE ciclo_scan				
				MOV R10, -1				; se a linha >= 4, n�o foi detectada nenhuma tecla. Retorna-se com R10 = -1
				JMP teclado_fim
			
fim_scan:		MOV R4, 0				; inicializa o contador
				
ciclo_tecla: 	CMP R3, 1				; verifica se � igual a 1
				JZ fim_coluna				
				DIV R3, R5				; divide sempre por 2
				ADD R4, 1				; incrementa o contador
				JMP ciclo_tecla
		
				; tecla (R10) = linha (R8) * 4 + coluna (R4)
fim_coluna:		SHL R8,2
				ADD R8, R4
				MOV R10, R8 			; guardar tecla premida em registo
				
teclado_fim:	POP R8
				POP R7
				POP R6
				POP R5
				POP R4
				POP R3
				POP R2
				POP R1
				RET

; *********************************************************************************
; * Descri��o:		Detectar flanco ascendente e descendente da tecla.
; * Entrada:		R10 (Tecla premida)
; * Sa�da:			--
; * Destr�i: 		--
; *********************************************************************************

detecta_flancos:
				PUSH R1
				PUSH R2
				PUSH R3
				PUSH R4

				MOV R1, tecla_transicao
				MOV R2, tecla_anterior
				MOV R4, tecla_flanco

				MOV R3, 0
				MOV [R1], R3					; limpar transi��o
			
				MOV R3, [R2]
				CMP R10, R3					; comparar com tecla anterior
				JEQ dflancos_fim
				
				MOV R3, 1
				MOV [R1], R3					; houve transi��o
				
				CMP R10, -1					; tecla (R10) == -1, � flanco descendente
				JEQ dflancos_desc
	
				MOV R3, 0						; flanco ascendente = 0
				MOV [R4], R3
				JMP dflancos_fim
	
dflancos_desc:	MOV R3, 1						; flanco descendente = 1
				MOV [R4], R3 


dflancos_fim:	POP R4
				POP R3
				POP R2
				POP R1
				RET 
				
				
; *********************************************************************************
; * Descri��o:		Determina qual a ac��o a realizar e executa-a.
; * Entrada:		R10 (tecla premida)
; * Sa�da:			--
; * Destr�i: 		--
; *********************************************************************************	
invoca_accao:
				PUSH R0
				PUSH R1
				PUSH R2
				PUSH R3
				PUSH R4
				PUSH R5
				PUSH R6
				PUSH R7
				
				MOV R0, table_teclado				; tabela com endere�os das rotinas a chamar
				MOV R1, tecla_transicao
				MOV R2, disparar					; endere�o da rotina dispara
				MOV R3, tecla_flanco
				MOV R6, tecla_anterior				; tecla guardada da itera��o anterior

				MOV R7, R10
				MOV R10, [R6]
				MOV [R6], R7						; guarda a tecla premida nesta itera��o para a pr�xima

				MOV R1, [R1]						; R1 = 1 se houve transi�ao entre tecla pressionada e n�o pressionada
				CMP R1, 0							; testar se alguma transi�ao foi detectada
				JEQ ia_fim 
				
				CMP R7, 5							; 5 � a tecla de dispara
				JNE ia_else
				
				CALL disparar
				JMP ia_fim
				
ia_else:		MOV R4, [R3]
				CMP R4, 1							; flanco descendente
				JNE ia_fim
								
				MOV R5, R10
				SHL R5, 1							; R1 * 2
				MOV R0, [R0+R5]
				CALL R0		
				
ia_fim:			MOV R10, R7						; repor tecla premida

				POP R7
				POP R6
				POP R5
				POP R4
				POP R3
				POP R2
				POP R1
				POP R0
				RET

; *********************************************************************************
; * Descri��o:		Mostra energia nos displays.
; * Entrada:		--
; * Sa�da:			--
; * Destr�i: 		--
; *********************************************************************************

mostra_energia:
				PUSH R1
				PUSH R10
				
				MOV R1, energia
				MOV R10, [R1]
				CALL display
				
				POP R10
				POP R1
				RET
				
; *********************************************************************************
; * Descri��o:		Mostra em formato decimal nos dois displays.
; * Entrada:		R10 (valor em hexadecimal)
; * Sa�da:			--
; * Destr�i: 		--
; *********************************************************************************

display:
			    PUSH R2					; guardar registos
			    PUSH R3
			    PUSH R4
			    PUSH R5
			    
			    MOV R3, R10				; coloca valor hexadecimal a mostrar num registo para as unidades
			    MOV R4, R10				; coloca valor hexadecimal a mostrar num registo para as dezenas
				MOV R2, DEZ				; guarda constante 10, �til para fazer a divisao inteira e descobrir o resto da divisao inteira
				
				DIV R4, R2				; guarda o valor das dezenas (R4)
			    MOD R3, R2				; guarda o valor das unidades (R3)
			    
			    SHL R4, 4				; empurra nibble das dezenas para o nibble de maior peso
			    OR  R4, R3				; junta o nibble das dezenas com os das unidades
			    MOV R5, DISPLAY
			    MOVB [R5], R4 			; escreve no porto de sa�da (POUT-1)
			   
			   	POP R5					; restaurar registos
				POP R4
			    POP R3
			    POP R2
			    RET



