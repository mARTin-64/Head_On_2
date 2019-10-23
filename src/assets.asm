; Load Sprite, and Map data into defined memory locations

* = $D000
PLAYER_SPRITE:
    !binary "../sprites/player_sprites.bin"

ENEMY_SPRITE:
    !binary "../sprites/enemy_sprites.bin"

* = $8000       ; Map and Color data starts at $8000
MAP: 
    !binary "../maps/map.bin"

CHAR_COLORS:
    !binary "../char_set/char_attributes.bin"

* = $F000       ; Character set starts at $F000
CHAR_SET:
    !binary "../char_set/char_set_collision.bin"


