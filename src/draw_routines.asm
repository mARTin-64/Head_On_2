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
    cmp #BONUS_SCR
    bne +
    jmp BonusScreen
    
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
    lda PlayerLives
    cmp #$01
    bne +
    rts
+
    ldy #$01
-    
    lda #$07
    sta SCREEN_RAM + 536, y
    tax
    lda CHAR_COLORS, x
    sta COLOR_RAM + 536, y

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


;-----BONUS TEXT
    lda BONUS_SCREEN + 20, y
    sta SCREEN_RAM + 610, y
    sta SCREEN_RAM + 690, y
    tax
    lda CHAR_COLORS, x
    sta COLOR_RAM + 610, y
    sta COLOR_RAM + 690, y
    
    iny
    cpy #$0a
    bne -

;-----POINTS PER (dots and value)
    ldy #$00
-    
    lda #$08
    sta SCREEN_RAM + 621, y
    tax
    lda CHAR_COLORS, x
    sta COLOR_RAM + 621, x

    lda #$09
    sta SCREEN_RAM + 701, y
    tax
    lda CHAR_COLORS, x
    sta COLOR_RAM + 701, y 
    
    iny
    cpy #$03
    bne -

;-----EQUAL SIGN
    lda #58
    sta SCREEN_RAM + 625
    sta SCREEN_RAM + 705
    tax
    lda CHAR_COLORS, x
    sta COLOR_RAM + 625
    sta COLOR_RAM + 705

;-----Display values 
    ldy #$00
    
    lda Value_Small
    pha
    lsr
    lsr
    lsr
    lsr
    beq +
    jsr ShowValue
+
    pla
    and #$0f
    jsr ShowValue
    
    ldy #80

    lda Value_Big + 1
    beq +
    jsr ShowValue
+    
    sed
    lda Value_Big
    clc
    adc Value_Big + 1 
    cld
    pha
    lsr
    lsr
    lsr
    lsr
    jsr ShowValue
    pla
    and #$0f
    jsr ShowValue
    
    rts

ShowValue:
    clc
    adc #10
    sta SCREEN_RAM + 627, y
    tax
    lda CHAR_COLORS, x
    sta COLOR_RAM + 627, y
    iny
    
    rts

}

