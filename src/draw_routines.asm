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
;-----BONUS SIGN 
    ldy #$00
-    
    lda BONUS_SCREEN, y
    sta SCREEN_RAM + 377, y
    tax
    lda CHAR_COLORS, x
    sta COLOR_RAM + 377, y
    
    lda BONUS_SCREEN + 10, y
    sta SCREEN_RAM + 417, y
    tax
    lda CHAR_COLORS, x
    sta COLOR_RAM + 417, y

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
    sta SCREEN_RAM + 459
    lda #10
    sta SCREEN_RAM + 460
    sta SCREEN_RAM + 461
    
    lda #$07 
    sta COLOR_RAM + 459
    sta COLOR_RAM + 460
    sta COLOR_RAM + 461

;-----POINTS PER (dots and value)
    ldy #$00
-    
    lda #$08
    sta SCREEN_RAM + 622, y
    tax
    lda CHAR_COLORS, x 
    sta COLOR_RAM + 622, y

    lda #$09
    sta SCREEN_RAM + 702, y
    tax
    lda CHAR_COLORS, x
    sta COLOR_RAM + 702, y 
    
    iny
    cpy #$03
    bne -

;-----EQUAL SIGN
    lda #46
    sta SCREEN_RAM + 626
    sta SCREEN_RAM + 706
    tax
    lda CHAR_COLORS, x
    sta COLOR_RAM + 626
    sta COLOR_RAM + 706

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
    sta SCREEN_RAM + 628, y
    tax
    lda CHAR_COLORS, x
    sta COLOR_RAM + 628, y
    iny
    
    rts

DrawBonusLogo:
    ldy #$00
-    
    lda BONUS_SCREEN, y
    sta SCREEN_RAM + 377, y
    tax
    lda CHAR_COLORS, x
    sta COLOR_RAM + 377, y
    
    lda BONUS_SCREEN + 10, y
    sta SCREEN_RAM + 417, y
    tax
    lda CHAR_COLORS, x
    sta COLOR_RAM + 417, y
       
    iny
    cpy #$06
    bne -

;-----BONUS NUMBER
    lda Bonus
    clc 
    adc #10
    sta SCREEN_RAM + 459
    lda #10
    sta SCREEN_RAM + 460
    sta SCREEN_RAM + 461
    lda #$07 
    sta COLOR_RAM + 459
    sta COLOR_RAM + 460
    sta COLOR_RAM + 461
   
    rts

ClearBonusLogo:
    ldy #$00
-    
    lda #$00
    sta SCREEN_RAM + 377, y
    sta SCREEN_RAM + 417, y
    sta SCREEN_RAM + 457, y
    iny
    cpy #$06
    bne -
    
    rts

Explosion:
.LoopCounter:   !byte $00, $00
    ldx Expl_Index

    lda COLLISION_Y 
    sec
    sbc #$01 
    tay
    
    lda ScreenRowLSB,  y
    sta COLLISION_LOOKUP
    lda ScreenRowMSB, y
    sta COLLISION_LOOKUP + 1
   
    lda ColorRowLSB,  y
    sta COLOR_LOOKUP
    lda ColorRowMSB, y
    sta COLOR_LOOKUP + 1
   
    lda COLLISION_X 
    sec
    sbc #$01  
    tay 
    ldx #$00
    stx TEMPX

.loop_small:
    lda Expl_Index
    cmp #$00
    bne +
    lda EXPLOSION_1, x
+
    cmp #$01
    bne +
    lda EXPLOSION_2, x
+
    cmp #$02
    bne +
    lda EXPLOSION_3, x
+
    cmp #$03
    bne +
    lda EXPLOSION_4, x
+
    cmp #$04
    bne +
    lda EXPLOSION_5, x
+
  
    sta (COLLISION_LOOKUP), y 
    stx TEMPX

    tax 
    lda CHAR_COLORS, x
    sta (COLOR_LOOKUP), y
    
    ldx TEMPX
    iny
    inx
    stx TEMPX
    inc .LoopCounter
    lda .LoopCounter
    cmp #04
    bne .loop_small

    lda #$00
    sta .LoopCounter
    tya
    clc
    adc #$24
    tay
    inc .LoopCounter + 1
    lda .LoopCounter + 1
    cmp #05
    bne .loop_small
   
    lda #$00
    sta .LoopCounter + 1
    
    lda COLLISION_X
    sec
    sbc #$01
    tay
    ldx #$00

.color_change
    lda CODE_FLAG
    beq .color_change
    dec CODE_FLAG

    dec Color_Timer
    bne .color_change
    
.color_loop:
    lda ColorTable, x
    sta (COLOR_LOOKUP), y
    iny
    inc .LoopCounter
    lda .LoopCounter
    cmp #$04  
    bne .color_loop
    
    lda #$00
    sta .LoopCounter
    
    tya
    clc
    adc #$24
    tay
    
    inc .LoopCounter + 1
    lda .LoopCounter + 1
    cmp #$05
    bne .color_loop
    lda Color_Timer + 1
    sta Color_Timer
    
    lda #$00
    sta .LoopCounter + 1
    inx
    cpx #$02
    bne .color_change
    
    lda #$00
    sta .LoopCounter
    sta .LoopCounter + 1
    
    inc Expl_Index
    lda Expl_Index
    cmp #$05
    beq +
    lda #$00
    sta .LoopCounter
    sta .LoopCounter + 1
    lda Color_Timer + 1
    sta Color_Timer


    jmp Explosion
+
    
    lda #$00
    sta .LoopCounter + 1
    sta Expl_Index
    sta COUNTER
    sta MILISEC
    sta SECONDS

-
    lda CODE_FLAG
    beq -
    dec CODE_FLAG
    
    jsr Timer
    lda SECONDS
    cmp #$03
    bne -
    rts
    
}

