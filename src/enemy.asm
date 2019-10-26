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
    sta Enemy_Dir
    
    lda #$01
    sta CheckZone
   
    lda SPRITE_MSB
    and #%11111101
    sta SPRITE_MSB
    sta Enemy_MSB

    rts

EnemyUpdate:
ENEMY_X     = POINTER4
ENEMY_X_MSB = POINTER5
ENEMY_Y     = POINTER6
EN_DIR      = POINTER7
EN_TURBO    = POINTER8
EN_MSB      = POINTER9

    lda #ENEMY0_ACTIVE
    sta ENTITY_TO_UPDATE
    
SetupEnemy0:
    lda #<Enemy_X
    sta ENEMY_X
    lda #>Enemy_X
    sta ENEMY_X + 1
    
    lda #<Enemy_X_MSB 
    sta ENEMY_X_MSB
    lda #>Enemy_X_MSB 
    sta ENEMY_X_MSB + 1 
    
    lda #<Enemy_Y
    sta ENEMY_Y
    lda #>Enemy_Y
    sta ENEMY_Y + 1
    
    lda #<Enemy_Dir
    sta EN_DIR
    lda #>Enemy_Dir
    sta EN_DIR + 1

    lda #<Enemy_MSB
    sta EN_MSB
    lda #>Enemy_MSB
    sta EN_MSB + 1
       
    ;jsr GetBehaviour
    
    ldy CurrentEnemy

EGoUp:
    lda (EN_DIR), y   
    cmp MV_UP 
    bne EGoDown 
   
    lda #$44
    sta SPRITE_POINTERS + 1, y  
    jsr CheckMoveUp
    bne EC_UP 
   
    ldy CurrentEnemy
    lda (ENEMY_Y), y
    sec
    sbc #$01
    sta (ENEMY_Y), y
    
    lda (EN_TURBO), y 
    cmp .Turbo 
    bne EGoDown
    
    lda (ENEMY_Y), y
    sec
    sbc #$01
    sta (ENEMY_Y), y
    jmp EEnd

EC_UP:
    lda (ENEMY_Y), y 
    and #$f8
    ora #$02
    sta (ENEMY_Y), y
	
    jsr CheckMoveRight
    bne +
    ldy CurrentEnemy
    lda MV_RT
    sta (EN_DIR), y 
    jmp EGoRight
    
+   
    jsr CheckMoveLeft
    bne +
    ldy CurrentEnemy
    lda MV_LT
    sta (EN_DIR), y
    jmp EGoLeft
+

EGoDown:
    lda (EN_DIR), y 
    cmp MV_DN
    bne EGoLeft
    
    lda #$45
    sta SPRITE_POINTERS + 1, y
    
    jsr CheckMoveDown
    bne EC_DN 
    
    ldy CurrentEnemy
    lda (ENEMY_Y), y
    clc
    adc #$01
    sta (ENEMY_Y), y

    lda (EN_TURBO), y
    cmp .Turbo 
    bne EGoLeft 
    
    lda (ENEMY_Y), y
    clc
    adc #$01
    sta (ENEMY_Y), y
    jmp EEnd

EC_DN:
    lda (ENEMY_Y), y 
    and #$f8
    ora #$02
    sta (ENEMY_Y), y

    jsr CheckMoveLeft
    bne +
    ldy CurrentEnemy
    lda MV_LT
    sta (EN_DIR), y
    jmp EGoLeft
+
    jsr CheckMoveRight
    bne +
    ldy CurrentEnemy
    lda MV_RT
    sta (EN_DIR), y
    jmp EGoRight
+   
    jmp EEnd

EGoLeft:    
    ldy CurrentEnemy
    lda (EN_DIR), y 
    cmp MV_LT
    bne EGoRight
    
    lda #$46    
    sta SPRITE_POINTERS + 1, y
    
    jsr CheckMoveLeft
    bne EC_LT

    ldy CurrentEnemy
    clc
    lda (EN_TURBO), y
    cmp .Turbo 
    bne ENoturbo
    
    lda (ENEMY_X), y
    sec
    sbc #02
    sta (ENEMY_X), y
    bcs EGoRight
    jmp ESetMSB0

ENoturbo:
    lda (ENEMY_X), y
    sec
    sbc #$01
    sta (ENEMY_X), y
    bcs EGoRight 

ESetMSB0:
    lda (ENEMY_X_MSB), y
    asl
    and #%11111101 
    sta (EN_MSB), y
    ora Player_MSB
    sta SPRITE_MSB
    
    jmp EEnd 

EC_LT:
    lda (ENEMY_X), y 
    sec
    sbc #$02
    and #$f8
    clc
    adc #$08
    sta (ENEMY_X), y
    
    jsr CheckMoveUp
    bne +
    ldy CurrentEnemy
    lda MV_UP
    sta (EN_DIR), y
    jmp EGoUp
+
    jsr CheckMoveDown
    bne +
    ldy CurrentEnemy
    lda MV_DN
    sta (EN_DIR), y
    jmp EGoDown
+
    jmp EEnd

EGoRight: 
    lda (EN_DIR), y 
    cmp MV_RT
    bne EEnd
    
    lda #$47
    sta SPRITE_POINTERS + 1, y 
    
    jsr CheckMoveRight
    bne EC_RT 
    
    ldy CurrentEnemy
    lda (EN_TURBO), y
    cmp .Turbo 
    clc
    bne ENoturbo1 
    
    lda (ENEMY_X), y
    adc #$01
    sta (ENEMY_X), y
    bcc EEnd 
    jmp ESetMSB1

ENoturbo1:
    lda (ENEMY_X), y
    adc #$01
    sta (ENEMY_X), y
    bcc EEnd 

ESetMSB1: 
    lda (ENEMY_X_MSB), y
    asl 
    ora #%00000010 
    sta (ENEMY_X_MSB), y
    sta (EN_MSB), y
    ora Player_MSB
    sta SPRITE_MSB
    jmp EEnd 

EC_RT:
    lda (ENEMY_X), y 
    sec
    sbc #$02
    and #$f8
    clc
    adc #$08
    sta (ENEMY_X), y

    jsr CheckMoveUp
    bne +
    ldy CurrentEnemy
    lda MV_UP
    sta (EN_DIR), y
    jmp EGoUp
+
    jsr CheckMoveDown
    bne +
    ldy CurrentEnemy
    lda MV_DN
    sta (EN_DIR), y
    jmp EGoDown
+   

EEnd:
    lda (ENEMY_X), y
    sta EN0_X 
    lda (ENEMY_Y), y
    sta EN0_Y
    
    inc CurrentEnemy
    ldx CurrentEnemy
    cpx ACTIVE_ENEMYES
    bcs +
    rts
+
    lda #$00
    sta CurrentEnemy
    rts

;--------------------------------------------------------
;--Update Enemy Behaviours    
;--------------------------------------------------------
GetBehaviour:
    jmp EDown
EUp:
    ldy CurrentEnemy
    lda (EN_DIR), y 
    cmp MV_UP
    beq +  
    cmp MV_DN
    beq + 

    lda #NO
    sta CheckZone
    jsr CheckMoveUp
    bne + 
    
    ldy CurrentEnemy
    lda (ENEMY_Y), y
    sec
    sbc #$01
    sta (ENEMY_Y), y
+
    rts

EDown:
    ldy CurrentEnemy
    lda (EN_DIR), y
    cmp MV_UP
    beq ETurbo 
    cmp MV_DN
    beq ETurbo

    lda #NO
    sta CheckZone
    jsr CheckMoveDown
    bne ETurbo

    ldy CurrentEnemy
    lda (ENEMY_Y), y
    clc 
    adc #$01
    sta (ENEMY_Y), y
    
    rts

ELeft:
    lda (EN_DIR), y 
    cmp MV_LT
    beq ETurbo
    cmp MV_RT
    beq ETurbo
    
    lda #NO
    sta CheckZone
    jsr CheckMoveLeft
    bne ETurbo
    
    ldy CurrentEnemy
    lda (ENEMY_X), y
    sec
    sbc #01
    sta (ENEMY_X), y
    bcs ETurbo 
    
    lda (ENEMY_X_MSB),y 
    and #%11111101
    sta (ENEMY_X_MSB), y 
    ora Player_MSB
    sta SPRITE_MSB
    
    rts

ERight:
    lda (EN_DIR), y
    cmp MV_LT
    beq ETurbo
    cmp MV_RT
    beq ETurbo
   
    lda #NO
    sta CheckZone
    jsr CheckMoveRight
    bne ETurbo
    
    ldy CurrentEnemy
    lda (ENEMY_X), y
    clc
    adc #$01
    sta (ENEMY_X), y
    bcc ETurbo 

    lda #%00000010
    lda (ENEMY_X_MSB), y
    ora #%00000010
    sta (ENEMY_X_MSB), y
    sta (EN_MSB), y
    ora Player_MSB
    sta SPRITE_MSB
    rts

ETurbo:    

    rts

ETurboOff:

    rts

}
