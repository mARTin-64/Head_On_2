;   This file contains all the macros for 
;   Head On 2 game for Commodore 64

!macro BasicStart {
    * = $801
    !byte $0c, $08, $0a, $00
    !byte $9e
    !text "2064"
    !byte $00, $00, $00, $00

}

!macro Init6502 {    ; Main graphics chip initialization
    lda #$00            ;\Set border color to black
    sta BORDER_COLOR    ;/

    lda #$06            ;\Set background color to blue
    sta BG_COLOR        ;/You dont need it because it is default
     
    jsr SetIRQ
    
    lda $01             ;\
    and #%11111000      ; Turn bit 0 and 2 in location $0001
    ora #%00000101      ; off to bank out BASIC and Kernal ROM
    sta $01             ;/
    
    lda $DD00           ;\
    and #%11111100      ; Set VIC bank to 1 $(C000-FFFF)
    sta $DD00           ;/
    
    lda #%00001100      ;\
    sta MEMORY_REGISTER ; Set screen and character location. See "labels.asm"
    
    lda #$01
    sta SPRITE_COLOR1
    sta ACTIVE_ENEMIES
    
    ldx #$07
-   
    lda #$02
    sta SPRITE_COLOR2, x
    dex
    bne -
    
    lda #$04
    sta PlayerLives
    
    lda #$00
    sta PLAYER_STATE
}

!macro GetRaster .line {
    lda #.line
    cmp RASTER_Y
    bne *-3

}

!macro SetScreen {
    jsr ClearScreen    ; Call to macro for clearing screen
    jsr DrawGame
    lda #$00
    sta BORDER_COLOR
    sta COUNTER
    sta MILISEC
    sta SECONDS 
}

!macro StartGame {
    lda #PLAY
    sta GAME_STATE
    jsr ClearScreen
    jsr DrawGame
    jsr DrawLives
    jsr PlayerInit
    jsr EnemyInit
    jsr ScoreDisplay
    
    lda #$00
    sta CurrentEnemy
    sta BORDER_COLOR
    sta COUNTER
    sta MILISEC
    sta SECONDS

    jsr GameLoop
}

!macro PushScore1  {
    ldx #$00
-
    lda Score2, x
    sta Score3, x
    lda Score1, x
    sta Score2, x
    inx 
    cpx #$03
    bne -
}

!macro PushScore2 {
    ldx #$00
-
    lda Score2, x
    sta Score3, x
    inx 
    cpx #$03
    bne -
}

!macro SaveState {
    php
    sta IRQ_A
    stx IRQ_X 
    sty IRQ_Y
}

!macro LoadState {
    ldy IRQ_Y
    ldx IRQ_X
    lda IRQ_A
    plp
}


