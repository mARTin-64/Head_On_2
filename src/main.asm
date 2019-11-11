;   This is a game code for Commodore 64 called 
;   Head On 2 written in ACME cross-assembler. 
;   Graphics is made in program called CharPad. 
;   This game was tested with VICE emulator 
;   on Arch-Linux operating system.
;   Code was written by Martin Živica.
;   Date: October, 2019.

!to "../out.prg",cbm    ; This line of code tells the compiler output file name and type
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
    lda #MAIN_MENU
    sta GAME_STATE
    
    +SetScreen
-   
    jsr ReadKey
    lda GAME_STATE
    cmp #BONUS_SCR
    bne -
    +SetScreen

MainMenu:
    lda CODE_FLAG
    beq MainMenu
    dec CODE_FLAG
    
    jsr Timer
    lda SECONDS
    cmp #$04
    bne +
    +StartGame
    +SetScreen

    lda GAME_STATE
    cmp #LOOSE
    bne +
    jmp Start
+
    jmp MainMenu

GameLoop:
    lda CODE_FLAG
    beq GameLoop
    dec CODE_FLAG
    ;inc $D020 
   
    jsr Timer

    jsr PlayerUpdate
    jsr EnemyUpdate
    
    lda GAME_STATE
    cmp #VICTORY
    bne +
    jsr IfWin
    +SetScreen
    rts
+
    cmp #CRASHED
    bne +
    jsr IfCrashed
    rts   
+
    ;dec $d020
    
    jmp GameLoop
;----------LOAD ASSETS----------;

X_BORDER_OFFSET:    !byte $18
Y_BORDER_OFFSET:    !byte $32

Player_X:    !byte $00
Player_Y:    !byte $00 
Player_MSB:  !byte $00
PL_DIR:      !byte $00
PTH          !byte $00, $00          ; Player Turn History
PlayerLives: !byte $00

MV_UP: !byte %0001
MV_DN: !byte %0010
MV_LT: !byte %0100
MV_RT: !byte %1000

Enemy_X:        !byte $00, $00, $00, $00
Enemy_Y:        !byte $00, $00, $00, $00 
Enemy_Dir:      !byte $00, $00, $00, $00
Enemy_Turbo     !byte $00, $00, $00, $00
Enemy_MSB:      !byte $00
ENEMY_MSB_SET:  !byte %00000010, %00000100, %00001000, %00010000
ENEMY_MSB_UNSET !byte %11111101, %11111011, %11110111, %11101111
MSB_Carry       !byte $00, $00, $00, $00
CurrentEnemy:   !byte $00

CheckSnap:      !byte $00
CheckZone:      !byte $00 
FreeZoneUp:     !byte $00
FreeZoneDown:   !byte $00
FreeZoneLeft:   !byte $00
FreeZoneRight:  !byte $00

Score:  !byte $00, $00, $00
Bonus:  !byte $02 

Score1: !byte $00, $00, $00
Score2: !byte $00, $00, $00
Score3: !byte $00, $00, $00

HighScore:      !byte $00, $00, $00
Enable_Blink:   !byte $00

Value_Small: !byte $05
Value_Big:   !byte $25, $00

Expl_Index: !byte $00
Expl_Extend_Flag:   !byte $00
TEMPX:  !byte $00
TEMPX1: !byte $00
TEMPY:  !byte $00
TEMPY1: !byte $00

!source "tables.asm"
!source "draw_routines.asm"
!source "player.asm"
!source "enemy.asm"
!source "collision.asm"
!source "score.asm"
!source "snap.asm"
!source "game_utils.asm"
!source "assets.asm"   ; Load assets with Sprite and Map data

