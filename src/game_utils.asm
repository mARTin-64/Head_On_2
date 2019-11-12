!zone GameUtilities {
SetIRQ:
    sei

    lda #$7f            ;\Disable interrupts from CIA chip
    sta $DC0D           ; used by kernal to blink cursor
    sta $DD0D           ;/and scan keyboard so it can't crash C64

    lda $D01A
    ora #%00000001
    sta $D01A           ; Enable raster Interrupt
    
    lda #<Irq
    sta $fffe
    lda #>Irq
    sta $ffff

    lda #$ff
    sta $D012

    lda $D011
    and #%01111111
    sta $D011

    cli

    asl $D019           ; ACK Interrupt
    
    rts

Irq:
    +SaveState
    
    lda #YES
    sta CODE_FLAG
   
    lda Enable_Blink
    beq .skip 

    dec Blink_Timer
    lda Blink_Timer
    cmp #$0B
    bcs +
    jsr DrawHighScore
    jmp .check_t
+
    jsr ClearHighScore

.check_t:    
    lda Blink_Timer
    bne .skip

    lda Blink_Timer + 1
    sta Blink_Timer

.skip:    
    asl $D019           ; ACK Interrupt
    +LoadState
    
    rti

IfWin:
    jsr AddBonus
;-----Set game state
    lda #BONUS_SCR
    sta GAME_STATE

    dec Speed_Flag

;-----Reset enemy speed
    ldx #$00
-   
    dec Enemy_Speed, x
    inx
    cpx ACTIVE_ENEMIES
    bne - 

;-----Update Level variables
    inc ACTIVE_ENEMIES
    inc PlayerLives
    inc Bonus

;-----Increase point values and reset if above 20 and 100
    sed

;-----Check if small point is allready worth 20 and skip
;-----otherwise add 5 to it
    lda Value_Small
    cmp #$20
    beq +
    clc 
    adc #$05
    sta Value_Small
+

;-----Compare if big point is worth 75, if yes add 24 to it and set carry
    lda Value_Big
    cmp #$75
    bne +

;-----Skip if carry is allready set
    lda Value_Big + 1
    cmp #$01
    beq ++

;-----Add 24 so Big point is now worth 99
    lda Value_Big
    clc
    adc #$24
    sta Value_Big

;-----This is gonna be used to set carry in Score routine so it adds 99 + 1 = 100    
    lda Value_Big + 1
    clc 
    adc #$01
    sta Value_Big + 1
    bne ++
+    

;-----Skip if big point is worth 99 + 1 (carry)
    cmp #$99
    beq ++
    clc
    adc #$25
    sta Value_Big
++   
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
    dec Speed_Flag
;-----Reset enemy speed
    lda Enemy_Speed
    cmp #$01
    beq +
    ldx #$00
-   
    dec Enemy_Speed, x
    inx
    cpx ACTIVE_ENEMIES
    bne - 
+

;-----Disable sprite rendering    
    lda #%00000000
    and ENABLE_SPRITES
    sta ENABLE_SPRITES

;-----Play explosion animation    
    jsr Explosion_1
    jsr Explosion_2
    jsr Explosion_3
    jsr Explosion_4
    jsr Explosion_5
    
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
    lda #$00
    sta Value_Big + 1

;-----Reset bonus per level
    lda #$02
    sta Bonus
;-----Store Score
    ldx #$00
-
    lda Score2, x
    sta Score3, x
    lda Score1, x
    sta Score2, x
    lda Score, x
    sta Score1, x
    inx 
    cpx #$03
    bne -

;-----Draw game over screen
    jsr GetHighScore
    jsr DrawGameOver

;-----Reset score    
    lda #$00
    sta Score
    sta Score + 1
    sta Score + 2

;-----Reset player lives
    lda #$04
    sta PlayerLives

    rts

GetHighScore:
;-----Check high digits    
.check_1_3:
    lda Score1 + 2
    beq .check_2_3
    
    lda Score1 + 2
    cmp HighScore + 2
    bcc .check_2_3
    sta HighScore + 2
    lda Score1 + 1
    sta HighScore + 1
    lda Score1
    sta HighScore
    rts

.check_2_3:    
    lda Score2 + 2
    beq .check_3_3
    
    lda Score2 + 2
    cmp HighScore + 2
    bcc .check_3_3
    sta HighScore + 2
    lda Score2 + 1
    sta HighScore + 1
    lda Score2
    sta HighScore
    rts

.check_3_3:
    lda Score3 + 2
    beq +
    
    lda Score3 + 2
    cmp HighScore + 2
    bcc + 
    sta HighScore + 2
    sta HighScore + 2
    lda Score3 + 1
    sta HighScore + 1
    lda Score3
    sta HighScore
    rts
+
;-----Check middle digits
.check_1_2:
    lda Score1 + 1
    cmp HighScore + 1
    beq .check_2_2
    cmp HighScore + 1
    bcc .check_2_2
    sta HighScore + 1
    lda Score1
    sta HighScore
    rts

.check_2_2:    
    lda Score2 + 1 
    cmp HighScore + 1
    beq .check_3_2
    cmp HighScore + 1
    bcc .check_3_2
    sta HighScore + 1
    lda Score2
    sta HighScore
    rts

.check_3_2:
    lda Score3 + 1
    cmp HighScore + 1
    beq +
    cmp HighScore + 1
    bcc + 
    sta HighScore + 1
    lda Score3
    sta HighScore
    rts
+
    ;-----Check middle digits
.check_1_1:
    lda Score1
    cmp HighScore
    bcc .check_2_1
    sta HighScore
    rts

.check_2_1:    
    lda Score2 
    cmp HighScore
    bcc .check_3_1
    sta HighScore
    rts

.check_3_1:
    lda Score3
    sta HighScore
    rts

ReadKey:
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
    cmp #5
    bne +
    inc MILISEC
+   
    cmp #10
    bne +
    inc MILISEC
+
    cmp #15
    bne + 
    inc MILISEC
+
    cmp #21
    bne +
    inc MILISEC
+
    cmp #26
    bne +
    inc MILISEC
+
    cmp #32
    bne +
    inc MILISEC
+
    cmp #37
    bne + 
    inc MILISEC
+
    cmp #43
    bne +
    inc MILISEC
+
    cmp #48
    bne +
    inc MILISEC
+   
    cmp #55
    bne +
    inc MILISEC 
    inc SECONDS
    lda #$00
    sta COUNTER
+
    lda MILISEC
    cmp #10
    bne +
    lda #$00
    sta MILISEC
+
    rts

;-----Display Timer code (comment the rts above to run it)
    ldy #2

    lda SECONDS 
    pha
    and #$0f
    jsr ShowCounter
    pla
    lsr
    lsr
    lsr
    lsr
    jsr ShowCounter
   
    rts

ShowCounter:
    clc
    adc #10
    sta SCREEN_RAM, y
    lda #$01
    sta COLOR_RAM, y
    dey
    rts

}
