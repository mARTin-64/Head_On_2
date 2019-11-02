!zone GameStates {
IfWin:
;-----Increase Level variables
    inc ACTIVE_ENEMYES
    inc PlayerLives
    inc Bonus

;-----Increase point values and reset if above 20 and 100
    sed
    lda Value_Small
    cmp #$20
    beq +
    clc 
    adc #$05
    sta Value_Small
+
    lda Value_Big
    cmp #$fe
    beq +
    clc
    adc #$25
    sta Value_Big
+   
    cld

;-----Reset bonus if above 500
    lda Bonus
    cmp #$06
    bne +
    lda #$05 
    sta Bonus
+
;-----Reset player lives if above 6
    lda PlayerLives
    cmp #$07
    bne +
    ldx #$06
    stx PlayerLives
+
;-----Disable sprite rendering
    lda #%00000000
    and ENABLE_SPRITES
    sta ENABLE_SPRITES

;-----Reset number of enemyes if above 4
    lda ACTIVE_ENEMYES
    cmp #$05
    beq +
    rts
+
    lda #$04
    sta ACTIVE_ENEMYES
    rts

IfCrashed:
    dec PlayerLives
    lda PlayerLives
    cmp #$00
    bne +
    ldx #$01
    stx PlayerLives
+   
    lda #%00000000
    and ENABLE_SPRITES
    sta ENABLE_SPRITES
    
    lda #NO
    rts
;+
    ;lda #YES
    ;rts

ReadKeyboard:
    lda CIA_PORT_A
    and #%10000000
    bne +
    lda CIA_PORT_B
    and #%00000001
    bne +
    lda #CRASHED
    sta GAME_STATE
+
    rts

Timer:
    inc COUNTER
    lda COUNTER
    and #3
    bne +
    lda COUNTER + 1
    clc
    adc #$01
    sta COUNTER + 1
+
    rts
;    ldy #22
;
;    lda COUNTER + 1
;    ;pha
;    ;and #$0f
;    ;jsr ShowCounter
;    ;pla
;    lsr
;    lsr
;    lsr
;    lsr
;    jsr ShowCounter
;    
;    rts
;
;ShowCounter:
;    clc
;    adc #10
;    sta SCREEN_RAM, y
;    dey
;    rts
;
}
