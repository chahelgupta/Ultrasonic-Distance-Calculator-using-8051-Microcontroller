$NOMOD51		;not tied to a specific 8051 microcontroller model
$INCLUDE (8051.MCU)	;include necessary definitions or configurations for 8051 microcontroller programming

trig  EQU  P3.1   	;whenever trig is mentioned it refers to p3.1 = TXD  
echo  EQU  P3.0   	;echo gives time, echo is an output at sensor and input at RXD 
enable EQU p2.2		;enables lcd when 1	
rs EQU p2.0		;selects between command mode when 0 and data mode when 1
rw EQU p2.1		;read from lcd when 1 & write to lcd when 0
LCD_dat EQU p1
ORG 0000
  
setb echo		;starts reading from sensor
clr trig		;stops transmitting
mov tmod, #02h		;sets Timer 0 to operate in mode 2(8-bit auto-reload because we r using serial communication) 
mov th0, #198		;to find the accurate distance
acall LCD_init
acall delay_2s 
acall LCD_clear

loop1:    
	 acall get_level
	 acall CONVERT		;taking distance from sensor and displaying it to lcd
	 acall cursr_home	;used to set the cursor of an LCD to the home position
	 acall display
	 SJMP loop1

LCD_init: 
	 mov dptr, #syntax	;to intialise features of lCD
	 clr rs			;clear the RS pin to prepare for command mode
	 clr rw			;clear the RW pin to indicate write mode
	 
loop:	
	 clr a
	 movc a, @a+dptr	;moves the data from the memory location pointed to by the DPTR register to the accumulator A
	 jz LCD_logo		;jump is A is zero
	 setb enable
	 mov LCD_dat, a
	 clr enable
	 acall delay1ms
	 inc dptr		;increments the DPR, pointing to the next memory location for the next iteration of the loop.
	 sjmp loop
		
syntax: db 38h,0fh,01h,10h,00h		;data bytes indicating features of lCD

LCD_logo: 
	 mov dptr, #syntax1 
	 setb rs
	 clr rw
		
loop4:	
	 clr a
	 movc a, @a+dptr
	 jz new_command
	 setb enable
	 mov LCD_dat, a
	 clr enable
	 acall delay1ms
	 inc dptr
	 sjmp loop4
		
syntax1: db 'C034, C044, C049',0

new_command: 
	 mov dptr, #syntax2 
	 clr rs
	 clr rw
	 
loop5:	
	 clr a
	 movc a, @a+dptr
	 jz LCD_logo_2
	 setb enable
	 mov LCD_dat, a
	 clr enable
	 acall delay1ms
	 inc dptr
	 sjmp loop5
		
syntax2: db 0c0h,14h,14h,14h,00h	;data bytes indicating features of lCD


LCD_logo_2: 
	 mov dptr, #syntax3 
	 setb rs
	 clr rw
	 
loop6:	
	 clr a
	 movc a, @a+dptr
	 jz return
	 setb enable
	 mov LCD_dat, a
	 clr enable
	 acall delay1ms
	 inc dptr
	 sjmp loop6
		
syntax3: db "MPMC Project",0

return:ret    

cursr_home:
	 clr rs
	 setb enable
	 mov LCD_dat,#80h		;data byte for starting to write from top left
	 clr enable
	 acall delay10ms
	 setb enable
	 mov LCD_dat,#0Ch		;command to turn on the display without blinking and without showing the cursor.
	 clr enable
	 ret    
      
LCD_clear:
	 clr rs
	 setb enable
	 mov LCD_dat,#01h		;data bytes indicating lCD to clear
	 clr enable		;disable lcd
	 acall delay10ms
	 ret

get_level:
	 clr A			;clears the accumulator			
	 setb trig			;TXD ready to transmit data
	 acall delay_10us		;to start transmission of ultrasonic waves, it has to be high for 10mu s
	 clr trig			;not transmitting data
      
wait5:				;waits for echo bit to be set		
	 jnb echo, wait5
	 setb tr0
	 
	 wait6:		
	    jnb tf0, wait6
	    inc A
	    clr tf0
	    jz return

	    jb echo, wait6
	    clr tr0
	 ret

delay_10us:
	 mov r7, #18
	 
stay:		
	 djnz r7, stay
	 ret

CONVERT:		;taking distance from sensor and displaying it to lcd
	 MOV B,#10		;b will have remainder and a will have quotient
	 DIV AB
	 MOV 41,B    	;saves ones digit to 41 ram address
	 MOV B,#10
	 DIV AB	
	 
	 MOV 42,B    	;save tenth place digit in 42 RAM ADDRESS
	 MOV 43,A    	;SAVE HUNDREDTH PLACE DIGIT IN 43 RAM ADDRESS
	 
	 CALL LOOKUP
	 MOV 43,A
	 MOV A,42
	 
	 CALL LOOKUP
	 MOV 42,A
	 MOV A,41
	 
	 CALL LOOKUP
	 MOV 41,A
	 RET
  
LOOKUP:
	 CJNE A,#00H,ONE		;CJNE: compare jump if not equal
	 MOV A,#'0'
	 RET
	 
ONE:    
	 CJNE A,#01H,TWO
	 MOV A,#'1'
	 RET
	 
TWO:    
	 CJNE A,#02H,THREE
	 MOV A,#'2'
	 RET
	 
THREE:  
	 CJNE A,#03H,FOUR
	 MOV A,#'3'
	 RET
	 
FOUR:   
	 CJNE A,#04H,FIVE
	 MOV A,#'4'
	 RET
	 
FIVE:   
	 CJNE A,#05H,SIX
	 MOV A,#'5'
	 RET
	 
SIX:    
	 CJNE A,#06H,SEVEN
	 MOV A,#'6'
	 RET
	 
SEVEN:  
	 CJNE A,#07H,EIGHT
	 MOV A,#'7'
	 RET
	 
EIGHT:  
	 CJNE A,#08H,NINE
	 MOV A,#'8'
	 RET
	 
NINE:
	 CJNE A,#09H,TEN
	 MOV A,#'9'
	 RET
	 
TEN:   
	 RET

display:
	 clr rw			;write operation
	 setb rs		;instruction is being sent
	 acall delay1ms		;used to ensure that the LCD has enough time to process the commands or data being sent to it
	 
	 SETB enable
	 MOV LCD_dat,#'d'	;displays 'distance:'
	 clr enable
	 acall delay1ms
	 
	 SETB enable
	 MOV LCD_dat,#'i'	
	 clr enable
	 acall delay1ms
	 
	 SETB enable
	 MOV LCD_dat,#'s'	
	 clr enable
	 acall delay1ms
	 
	 SETB enable
	 MOV LCD_dat,#'t'	
	 clr enable
	 acall delay1ms
	 
	 SETB enable
	 MOV LCD_dat,#'a'	
	 clr enable
	 acall delay1ms
	 
	 SETB enable
	 MOV LCD_dat,#'n'	
	 clr enable
	 acall delay1ms
	 
	 SETB enable
	 MOV LCD_dat,#'c'	
	 clr enable
	 acall delay1ms
	 
	 SETB enable
	 MOV LCD_dat,#'e'	
	 clr enable
	 acall delay1ms
	 
	 SETB enable
	 MOV LCD_dat,#':'	
	 clr enable
	 acall delay1ms
	 
	 SETB enable
	 MOV LCD_dat,#' '
	 clr enable
	 acall delay1ms

	 SETB enable
	 MOV LCD_dat,43	;displays hundreds place
	 clr enable
	 acall delay1ms
	   
	 SETB enable
	 MOV LCD_dat,42	;displays tens place
	 clr enable
	 acall delay1ms
			   
	 SETB enable
	 MOV LCD_dat,41	;displays ones place
	 clr enable
	 acall delay1ms
	   
	 SETB enable
	 MOV LCD_dat,#'c'	;displays 'c'
	 clr enable
	 acall delay1ms
		   
	 SETB enable
	 MOV LCD_dat,#'m'	;displays 'm'
	 clr enable
	 acall delay1ms
	 RET
  
delay10ms:		;to remove the cursur while displaying distance
      MOV R3,#1
      MOV R2,#1
      MOV R1,#19
      
      TT1:  		
	   DJNZ  R1,TT1
	   DJNZ  R2,TT1
	   DJNZ  R3,TT1
      RET
		
delay1ms: 	
      MOV R2,#04
      MOV R1,#18

      TT2:  		
	   DJNZ  R1,TT2
	   DJNZ  R2,TT2
      RET
		
delay_2s:		;register bank 0 getting selected by default(rs1=0 rs0=0 in psw) 
      MOV R3,#50	;to generate delay of 1s(r3=25, r2=5, r1=250) 
      MOV R2,#10
      MOV R1,#250
	
      TT3:  		
	   DJNZ  R1,TT1
	   DJNZ  R2,TT1
	   DJNZ  R3,TT3
      RET

END