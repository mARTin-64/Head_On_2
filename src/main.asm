;   This is a game code for Commodore 64 called 
;   Head On 2 written in ACME cross-assembler. 
;   Graphics is made in program called CharPad. 
;   This game was tested with VICE emulator 
;   on Arch-Linux operating system.
;   Code was written by Martin Živica.
;   Date: October, 2019.

!TO "../head_on_2.prg", CBM    ; This line of code tells the compiler output file name and type

;----------LOAD FILES----------;
!src "zero_page.asm"
!src "macros.asm"   ; Loads file with defined macro!
!src "labels.asm"   ; Load predefined labels 

;----------MAIN PROGRAM----------;   
    +BasicStart     ; Call to macro for starting program
    
    * = $0810       ; Set program memory addres
    
    +Init6502

Start:

    +GameInit

Loop:
    +GetRaster($ff)
    inc $D020 
      
    lda GAME_STATE
    and #VICTORY
    bne Start
    
    jsr PlayerUpdate
   
    dec $d020
    +GetRaster($82)
    
    jmp Loop
;----------LOAD ASSETS----------;

X_BORDER_OFFSET:        !byte $18
Y_BORDER_OFFSET:        !byte $32

PlayerX: !byte $00, $00
PlayerY: !byte $00, $00

MV_UP: !byte %0001
MV_DN: !byte %0010
MV_LT: !byte %0100
MV_RT: !byte %1000

CheckZone:      !byte $00, $00, $00, $00, $00, $00, $00, $00
FreeZone:       !byte $00, $00, $00, $00, $00, $00, $00, $00  
MoveRotation:   !byte $00, $00, $00, $00, $00, $00, $00, $00  

EntityActive:   !byte $00

Score   !byte $00, $00, $00

!source "player.asm"
!source "enemy.asm"
!source "collision.asm"
!source "tables.asm"
!source "assets.asm"   ; Load assets with Sprite and Map data
!source "score.asm"

