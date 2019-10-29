!zone GameStates {
IfWin:
    inc ACTIVE_ENEMYES
    inc PlayerLives

    lda ACTIVE_ENEMYES
    cmp #$03
    beq +
    rts
+
    lda #$01
    sta ACTIVE_ENEMYES
    
    rts

IfLoose:
    dec PlayerLives
    ;lda PlayerLives
    ;bne +
    lda #NO
    rts
;+
    ;lda #YES
    ;rts

GameOver:

StartMenu:

NextLevelMenu:

CrashMenu:

LooseMenu:

}
