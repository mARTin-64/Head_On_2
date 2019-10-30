;--------------------------------------------------------
;--Main game draw map and menu routines                    
;--------------------------------------------------------
!zone SCREEN {

;--------------------------------------------------------
;--Clear the visible screen routine     
;--------------------------------------------------------
ClearScreen:

    lda #$00
    ldx #250
-
    dex                 ; Decreas value in X register by 1
    sta SCREEN_RAM, X       ;\
    sta SCREEN_RAM + 250, X ; Store loaded character to Screen RAM
    sta SCREEN_RAM + 500, X ; at multiple locations at once 
    sta SCREEN_RAM + 750, X ;/
    bne -               ; Go to - if X != 0

    rts

;--------------------------------------------------------
;--Routine for drawing game map         
;--------------------------------------------------------
DrawGame:
DATA_POINTER = TEMP5
.Row    = TEMP5
    
    lda #$00
    sta .Row
    
    lda #<SCREEN_RAM
    sta Screen + 1 
    sta Color + 1

    lda #>SCREEN_RAM
    sta Screen + 2
    lda #>COLOR_RAM
    sta Color + 2

    lda GAME_STATE
    cmp #MAIN_MENU
    bne +
    lda #<START_MENU
    sta Data + 1
    lda #>START_MENU
    sta Data + 2
    
    jmp Done
+
    cmp #PLAY
    bne +    
    lda #<MAP
    sta Data + 1
    lda #>MAP
    sta Data + 2
    
    jmp Done
+
    cmp #VICTORY
    bne +
+

Done:
    ldy #00                ; Our map data is loaded to $8000 location. See "assets.asm
-   
Data:                       ; Loop through Map bytes and store them in Screen RAM
    lda $B00B, y   ; This is currently drawing map from 4 locations on screen
    tax                     ; and setting right colors for characters. I will later 
Screen:    
    sta $B00B, y       ; change this code to be self modifying.
    lda CHAR_COLORS, x
Color:    
    sta $B00B, y 
    iny
    cpy #40
    bne Data
    
    ; INCREASE TILE LOCATION
    clc
    lda Data + 1
    adc #$28
    sta Data + 1
    lda Data + 2
    adc #$00
    sta Data + 2
    
    ; INCREASE SCREEN AND COLOR RAM LOCATIONS
    clc
    lda Screen + 1
    adc #$28
    sta Screen + 1
    sta Color  + 1
    bcc +
    inc Screen + 2 
    inc Color  + 2
+
    inc .Row
    ldx .Row
    cpx #25
    bne Done

    rts
}


