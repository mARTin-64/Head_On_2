!zone Enemy {

EnemyX:   !byte $00, $00
EnemyY:   !byte $00

.Turbo: !byte $01

EnemyInit:
    lda #$46
    sta SPRITE_POINTERS + 1

    lda #175
    sta EnemyX 
    lda #234
    sta EnemyY
    
    lda MV_LT
    sta EN_DIR
    
    lda #$01
    sta CheckZone
    
    rts

EnemyUpdate:
    lda #ENEMY0_ACTIVE
    sta ENTITY_TO_UPDATE
    

EGoUp:
    lda EN_DIR 
    cmp MV_UP 
    bne EGoDown 
   
    lda #$44
    sta SPRITE_POINTERS + 1 
    
    jsr CheckMoveUp
    bne EC_UP 

    dec EnemyY
    lda EN_TURBO
    cmp .Turbo 
    bne EGoDown
     
    dec EnemyY
    jmp EEnd

EC_UP:
    lda EnemyY 
    and #$f8
    ora #$02
    sta EnemyY
	
    jsr CheckMoveRight
    bne +
    lda MV_RT
    sta EN_DIR
    jmp EGoRight
    
+   
    jsr CheckMoveLeft
    bne +
    lda MV_LT
    sta EN_DIR
    jmp EGoLeft
+

EGoDown:
    lda EN_DIR
    cmp MV_DN
    bne EGoLeft
    
    lda #$45
    sta SPRITE_POINTERS + 1
    
    jsr CheckMoveDown
    bne EC_DN 

    inc EnemyY
    lda EN_TURBO
    cmp .Turbo 
    bne EGoLeft 
    
    inc EnemyY
    jmp EEnd

EC_DN:
    lda EnemyY 
    and #$f8
    ora #$02
    sta EnemyY 

    jsr CheckMoveLeft
    bne +
    lda MV_LT
    sta EN_DIR
    jmp EGoLeft
+
    jsr CheckMoveRight
    bne +
    lda MV_RT
    sta EN_DIR
    jmp EGoRight
+   
    jmp EEnd

EGoLeft:    
    lda EN_DIR
    cmp MV_LT
    bne EGoRight
    
    lda #$46    
    sta SPRITE_POINTERS + 1
    
    jsr CheckMoveLeft
    bne EC_LT

    clc
    lda EN_TURBO
    cmp .Turbo 
    bne ENoturbo
    
    lda EnemyX
    sec
    sbc #02
    sta EnemyX
    bcs EGoRight
    jmp ESetMSB0

ENoturbo:
    lda EnemyX
    sec
    sbc #$01
    sta EnemyX
    bcs EGoRight 

ESetMSB0:
    lda #%00000010
    eor #%11111111
    asl EnemyX + 1
    and EnemyX + 1
    sta ENEMY_MSB
    ora PLAYER_MSB
    sta SPRITE_MSB
    
    jmp EEnd 

EC_LT:
    lda EnemyX
    sec
    sbc #$02
    and #$f8
    clc
    adc #$08
    sta EnemyX
    
    jsr CheckMoveUp
    bne +
    lda MV_UP
    sta EN_DIR
    jmp EGoUp
+
    jsr CheckMoveDown
    bne +
    lda MV_DN
    sta EN_DIR
    jmp EGoDown
+
    jmp EEnd

EGoRight: 
    lda EN_DIR
    cmp MV_RT
    bne EEnd
    
    lda #$47
    sta SPRITE_POINTERS + 1 
    
    jsr CheckMoveRight
    bne EC_RT 
    
    clc
    lda EN_TURBO
    cmp .Turbo 
    bne ENoturbo1 
    
    lda EnemyX
    adc #$01
    sta EnemyX
    bcc EEnd 
    jmp ESetMSB1

ENoturbo1:
    lda EnemyX
    adc #$01
    sta EnemyX
    bcc EEnd 

ESetMSB1:    
    lda #%00000010
    asl EnemyX + 1
    ora EnemyX + 1
    sta EnemyX + 1
    sta ENEMY_MSB
    ora PLAYER_MSB
    sta SPRITE_MSB
    jmp EEnd 

EC_RT:
    lda EnemyX 
    sec
    sbc #$02
    and #$f8
    clc
    adc #$08
    sta EnemyX
 
    jsr CheckMoveUp
    bne +
    lda MV_UP
    sta EN_DIR
    jmp EGoUp
+
    jsr CheckMoveDown
    bne +
    lda MV_DN
    sta EN_DIR
    jmp EGoDown
+   

EEnd:
    lda EnemyX
    sta EN0_X 
    lda EnemyY
    sta EN0_Y
    
    rts

}
