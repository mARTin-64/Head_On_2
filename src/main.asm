;   This is a game code for Commodore 64 called 
;   Head On 2 written in ACME cross-assembler. 
;   Graphics is made in program called CharPad. 
;   This game was tested with VICE emulator 
;   on Arch-Linux operating system.
;   Code was written by Martin Živica.
;   Date: October, 2019.

!TO "../head_on_2.prg", CBM    ; This line of code tells the compiler output file name and type

;----------LOAD FILES----------;

!src "macros.asm"   ; Loads file with defined macros

!src "labels.asm"   ; Load predefined labels 
;----------MAIN PROGRAM----------;   
    +BasicStart     ; Call to macro for starting program
    
    * = $0810       ; Set program memory addres
    
    +Init6502
    jsr ClearScreen    ; Call to macro for clearing screen
    jsr DrawMap
    jsr PlayerInit 

loop:
    +GetRaster($ff)
    ;inc $D020 
      
    jsr PlayerUpdate
   
    ;dec $d020
    +GetRaster($82)
    
    jmp loop
;----------LOAD ASSETS----------;

X_BORDER_OFFSET:        !byte $18
Y_BORDER_OFFSET:        !byte $32

!source "game.asm"
!source "tables.asm"
!source "assets.asm"   ; Load assets with Sprite and Map data


