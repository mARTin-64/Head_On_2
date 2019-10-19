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
    
    lda #$7f            ;\Disable interrupts from CIA chip
    sta $DC0D           ; used by kernal to blink cursor
    sta $DD0D           ;/and scan keyboard so it can't crash C64

    lda $01             ;\
    and #%11111000      ; Turn bit 0 and 2 in location $0001
    ora #%00000101      ; off to bank out BASIC and Kernal ROM
    sta $01             ;/
    
    lda $DD00           ;\
    and #%11111100      ; Set VIC bank to 1 $(C000-FFFF)
    sta $DD00           ;/
    
    lda #%00001100      ;\
    sta MEMORY_REGISTER ; Set screen and character location. See "labels.asm"
    lda #$43
    sta SPRITE_POINTERS + 0
    lda ENABLE_SPRITES
    ora %00000001
    sta ENABLE_SPRITES
    
}

!macro GetRaster .line {
    lda #.line
    cmp RASTER_Y
    bne *-3

}

!macro GameInit {
    jsr ClearScreen    ; Call to macro for clearing screen
    jsr DrawMap
    jsr PlayerInit
    lda #PLAY
    sta GAME_STATE
    lda #$00
    sta BORDER_COLOR
}
