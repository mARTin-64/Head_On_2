;   This is a game code for Commodore 64 called 
;   Head On 2 written in ACME cross-assembler. 
;   Graphics is made in program called CharPad. 
;   This game was tested with VICE emulator 
;   on Arch-Linux operating system.
;   Code was written by Martin Živica.
;   Date: October, 2019.

!to "../head_on_2.prg",cbm    ; This line of code tells the compiler output file name and type
!cpu 6502
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
    jsr EnemyUpdate

    dec $d020
    +GetRaster($82)
    
    jmp Loop
;----------LOAD ASSETS----------;

X_BORDER_OFFSET:    !byte $18
Y_BORDER_OFFSET:    !byte $32

Player_X:    !byte $00, $00
Player_Y:    !byte $00 
Player_MSB   !byte $00
PTH          !byte $00, $00          ; Player Turn History

MV_UP: !byte %0001
MV_DN: !byte %0010
MV_LT: !byte %0100
MV_RT: !byte %1000

Enemy0_X:       !byte $00, $00
Enemy1_X:       !byte $00, $00
Enemy2_X:       !byte $00, $00
Enemy3_X:       !byte $00, $00

Enemy_Y:        !byte $00, $00, $00, $00 
EN_DIR:         !byte $00, $00, $00, $00
EN_TURBO        !byte $00, $00, $00, $00
Enemy_MSB:      !byte $00, $00, $00, $00
ENEMY_STATE:    !byte $00, $00, $00, $00
CurrentEnemy:   !byte $00

CheckSnap:      !byte $00
CheckZone:      !byte $00 
FreeZoneUp:     !byte $00
FreeZoneDown:   !byte $00
FreeZoneLeft:   !byte $00
FreeZoneRight:  !byte $00

Score   !byte $00, $00, $00

!source "player.asm"
!source "enemy.asm"
!source "collision.asm"
!source "tables.asm"
!source "assets.asm"   ; Load assets with Sprite and Map data
!source "score.asm"

