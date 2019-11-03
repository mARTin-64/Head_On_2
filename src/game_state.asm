!zone GameStates {
IfWin:
;-----Set game state
    lda #BONUS_SCR
    sta GAME_STATE

;-----Increase Level variables
    inc ACTIVE_ENEMIES
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
    cmp #$75
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
    lda ACTIVE_ENEMIES
    cmp #$05
    beq +
    rts
+
    lda #$04
    sta ACTIVE_ENEMIES
    rts

IfCrashed:
    dec PlayerLives

;-----Disable sprite rendering    
    lda #%00000000
    and ENABLE_SPRITES
    sta ENABLE_SPRITES

;-----Check if player has no lives then goto end
    lda PlayerLives
    cmp #$00
    beq +

;-----Update game state   
    lda #BONUS_SCR
    sta GAME_STATE
    rts
+
;-----Update game state if no more lives
    lda #LOOSE
    sta GAME_STATE

;-----Reset active enemies
    lda #$01
    sta ACTIVE_ENEMIES

;-----Reset point values
    lda #$05
    sta Value_Small
    lda #$25
    sta Value_Big

;-----Reset bonus per level
    lda #$02
    sta Bonus

;-----Reset score    
    lda #$00
    sta Score
    sta Score + 1
    sta Score + 2

;-----Reset player lives
    lda #$04
    sta PlayerLives
    
    rts


ReadKeyboard:
    lda CIA_PORT_A
    and #%10000000
    bne +
    lda CIA_PORT_B
    and #%00000001
    bne +
    lda #BONUS_SCR
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
