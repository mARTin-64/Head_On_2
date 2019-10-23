!zone Enemy {

.Turbo: !byte $01

EnemyInit:
    lda #$46
    sta SPRITE_POINTERS + 1

    lda #175
    sta Enemy_X 
    lda #234
    sta Enemy_Y
    
    lda MV_LT
    sta EN_DIR
    
    lda #$01
    sta CheckZone
    
    rts

EnemyUpdate:
    lda #ENEMY0_ACTIVE
    sta ENTITY_TO_UPDATE
    
    jsr GetBehaviour

EGoUp:
    lda EN_DIR 
    cmp MV_UP 
    bne EGoDown 
   
    lda #$44
    sta SPRITE_POINTERS + 1 
    
    jsr CheckMoveUp
    bne EC_UP 

    dec Enemy_Y
    lda EN_TURBO
    cmp .Turbo 
    bne EGoDown
     
    dec Enemy_Y
    jmp EEnd

EC_UP:
    lda Enemy_Y 
    and #$f8
    ora #$02
    sta Enemy_Y
	
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

    inc Enemy_Y
    lda EN_TURBO
    cmp .Turbo 
    bne EGoLeft 
    
    inc Enemy_Y
    jmp EEnd

EC_DN:
    lda Enemy_Y 
    and #$f8
    ora #$02
    sta Enemy_Y 

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
    
    lda Enemy_X
    sec
    sbc #02
    sta Enemy_X
    bcs EGoRight
    jmp ESetMSB0

ENoturbo:
    lda Enemy_X
    sec
    sbc #$01
    sta Enemy_X
    bcs EGoRight 

ESetMSB0:
    lda #%00000010
    eor #%11111111
    asl Enemy_X + 1
    and Enemy_X + 1
    sta ENEMY_MSB
    ora PLAYER_MSB
    sta SPRITE_MSB
    
    jmp EEnd 

EC_LT:
    lda Enemy_X
    sec
    sbc #$02
    and #$f8
    clc
    adc #$08
    sta Enemy_X
    
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
    
    lda Enemy_X
    adc #$01
    sta Enemy_X
    bcc EEnd 
    jmp ESetMSB1

ENoturbo1:
    lda Enemy_X
    adc #$01
    sta Enemy_X
    bcc EEnd 

ESetMSB1:    
    lda #%00000010
    asl Enemy_X + 1
    ora Enemy_X + 1
    sta Enemy_X + 1
    sta ENEMY_MSB
    ora PLAYER_MSB
    sta SPRITE_MSB
    jmp EEnd 

EC_RT:
    lda Enemy_X 
    sec
    sbc #$02
    and #$f8
    clc
    adc #$08
    sta Enemy_X
 
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
    lda Enemy_X
    sta EN0_X 
    lda Enemy_Y
    sta EN0_Y
    
    rts

;--------------------------------------------------------
;--Update Enemy Behaviours    
;--------------------------------------------------------
GetBehaviour:
    jmp EUp
EUp:
    lda EN_DIR
    cmp MV_UP
    beq +  
    cmp MV_DN
    beq + 

    lda #NO
    sta CheckZone
    jsr CheckMoveUp
    bne + 
    dec Enemy_Y
+
    jmp ETurbo

EDown:
    lda EN_DIR
    cmp MV_UP
    beq ELeft 
    cmp MV_DN
    beq ETurbo

    lda #NO
    sta CheckZone
    jsr CheckMoveDown
    bne ETurbo
    inc Enemy_Y

ELeft:
    lda EN_DIR
    cmp MV_LT
    beq ETurbo
    cmp MV_RT
    beq ETurbo
    
    lda #NO
    sta CheckZone
    jsr CheckMoveLeft
    bne ETurbo
    
    lda Enemy_X
    sec
    sbc #01
    sta Enemy_X
    bcs ETurbo 
    
    lda #%00000010
    eor #%11111111
    and Enemy_X + 1
    sta ENEMY_MSB
    ora PLAYER_MSB
    sta SPRITE_MSB

ERight:
    lda EN_DIR
    cmp MV_LT
    beq ETurbo
    cmp MV_RT
    beq ETurbo
   
    lda #NO
    sta CheckZone
    jsr CheckMoveRight
    bne ETurbo
  
    lda Enemy_X
    clc
    adc #$01
    sta Enemy_X
    bcc ETurbo 

    lda #%00000010
    ora Enemy_X + 1
    sta Enemy_X + 1
    sta ENEMY_MSB
    ora PLAYER_MSB
    sta SPRITE_MSB
    rts
ETurbo:    
    ;lda JOY_P_2
    ;and #.JOY_FR
    ;bne TurboOff 
    ;lda Turbo
    ;sta PL_TURBO
    rts

ETurboOff:
    ;lda #$00
    ;sta PL_TURBO
    
    rts


   rts

}
