!zone GameStates {
IfWin:
    inc ACTIVE_ENEMYES
    inc PlayerLives
    
    lda #%00000000
    and ENABLE_SPRITES
    sta ENABLE_SPRITES
    
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
    ldx #$03
    stx PlayerLives
+   
    cmp #$07
    bne +
    ldx #$06
    stx PlayerLives
+
    ;bne +
    lda #%00000000
    and ENABLE_SPRITES
    sta ENABLE_SPRITES
    
    lda #NO
    rts
;+
    ;lda #YES
    ;rts

GameOver:
        
LooseMenu:

}
