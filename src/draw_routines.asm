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
    cmp #CRASHED
    bne +
    lda #<BONUS_SCREEN
    sta Data + 1
    lda #>BONUS_SCREEN
    sta Data + 2
    
    jsr BonusScreen
    rts
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
    ldy #00 
-   
Data:
    lda $B00B, y   
    tax
Screen:    
    sta $B00B, y
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

DrawLives:
    ldy #$00
-    
    lda #$07
    sta SCREEN_RAM + 537, y
    tax
    lda CHAR_COLORS, x
    sta COLOR_RAM + 537, y

    iny
    cpy PlayerLives
    bne -
    
    rts

BonusScreen:
;-----BONUS LOGO
    ldy #$00
-    
    lda BONUS_SCREEN, y
    sta SCREEN_RAM + 376, y
    tax
    lda CHAR_COLORS, x
    sta COLOR_RAM + 376, y
    
    lda BONUS_SCREEN + 10, y
    sta SCREEN_RAM + 416, y
    tax
    lda CHAR_COLORS, x
    sta COLOR_RAM + 416, y

;-----BONUS TEXT
    lda BONUS_SCREEN + 20, y
    sta SCREEN_RAM + 611, y
    sta SCREEN_RAM + 691, y
    tax
    lda CHAR_COLORS, x
    sta COLOR_RAM + 611, y
    sta COLOR_RAM + 691, y
    
    iny
    cpy #$0a
    bne -

;-----BONUS NUMBER
    lda Bonus
    clc 
    adc #10
    sta SCREEN_RAM + 458
    lda #10
    sta SCREEN_RAM + 459
    sta SCREEN_RAM + 460
    lda #$07 
    sta COLOR_RAM + 458
    sta COLOR_RAM + 459
    sta COLOR_RAM + 460

;-----POINTS PER
    ldy #$00
-    
    lda #$08
    sta SCREEN_RAM + 622, y
    tax
    lda CHAR_COLORS, x
    sta COLOR_RAM + 622, x

    lda #$09
    sta SCREEN_RAM + 702, y
    tax
    lda CHAR_COLORS, x
    sta COLOR_RAM + 702, y 
    
    iny
    cpy #$03
    bne -

    lda #58
    sta SCREEN_RAM + 626
    sta SCREEN_RAM + 706
    tax
    lda CHAR_COLORS, x
    sta COLOR_RAM + 626
    sta COLOR_RAM + 706
 
    ldy #$01
    
    lda Value_Small
    pha
    and #$0f
    jsr ShowValue
    pla
    lsr
    lsr
    lsr
    lsr
    jsr ShowValue

    ldy #82

    lda Value_Big
    pha
    and #$0f
    jsr ShowValue
    pla
    lsr
    lsr
    lsr
    lsr
    jsr ShowValue
    
    rts

ShowValue:
    clc
    adc #10
    sta SCREEN_RAM + 628, y
    tax
    lda CHAR_COLORS, x
    sta COLOR_RAM + 628, y
    dey
    
    rts

}

