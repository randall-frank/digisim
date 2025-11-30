         ORG   $8100
         DSK   ../bin/DRAWING2#068100
         TYP   $06        ; /BIN file
         LST   OFF

         PUT   COMMON.S

*      START OF THE PAC ROUTINES
TEMP0    =     0
TEMP1    =     1
TEMP2    =     2
TEMP3    =     3
TEMP4    =     4
CURX     =     TEMP3
CURY     =     TEMP4
TEMP5    =     5
TEMP6    =     6
TEMP7    =     7
FLAG     =     8
INDEX    =     $FE
PTR      =     $FC

*       JUMPS TO START OF ROUTINES

         JMP   TEXT
         JMP   BLOCKS
         JMP   PRINTG
         JMP   PRINTP
         JMP   PRINTW

CALC     TAX
         LDA   LOWS,X
         STA   $26
         LDA   HIGHS,X
         STA   $27
         RTS

* SET TAKES X & Y AND POINTS THE CURRENT TEXT TO THAT POINT
* IT ALSO RESETS THE COUNTER FOR LOOPING AT ACC CHARS
TEXT     LDA   $200
         STA   CURX
         LDA   $201
         STA   CURY
         LDA   #0
         STA   INDEX
TOPPER   LDY   INDEX
         LDA   $202,Y
         CMP   #$FF
         BNE   TEX2
         RTS
TEX2     INC   INDEX
         CMP   #$FE
         BEQ   MOVEONLY
         PHA
*    PRINT CHARACTER IN ACC AT CURRENT X,Y AND UPDATE
         LDA   CURY
         STA   TEMP1
         LDY   CURX
         PLA
         AND   #$3F         ; 64 characters
         LDX   #%01001001   ; $49 -> $9200-$93FF
         STX   MOD+2
         ASL
         ASL
         ASL
         ROL   MOD+2
         STA   MOD+1
         LDX   #8
         STX   TEMP2
PL6      LDA   TEMP1
         JSR   CALC
MOD      LDA   $FFFF
         STA   ($26),Y
         INC   MOD+1
         INC   TEMP1
         DEC   TEMP2
         BNE   PL6
MOVEONLY INC   CURX
         JMP   TOPPER

**********BLOCKS:DRAW BLOCK OF TEMP0 AT TEMP1,TEMP2 ********

BLOCKS   LDY   TEMP1
         LDA   XSTOP,Y
         STA   TEMP1
         LDY   TEMP2
         LDA   YSTOP,Y
         STA   TEMP2
         LDA   TEMP0
         CMP   #$FF
         BNE   BL2
         LDA   #3
         STA   FLAG
         JMP   DRAW
BL2      LDA   #0
         STA   FLAG
         LDA   TEMP0
         BMI   WAVES
         BNE   BL1
         LDA   #1
         STA   FLAG
         JMP   DRAW
BL1      LDA   #0
         DEC   TEMP0
         ASL   TEMP0
         ASL   TEMP0
         ASL   TEMP0
         ASL   TEMP0
         ASL   TEMP0
         ROL
         ORA   #$90
         STA   MOR+2
         LDA   TEMP0
         STA   MOR+1
         JMP   DRAW
WAVES    AND   #$7F
         PHA
         LSR
         CLC
         ADC   #7
         STA   MOR+1
         ASL   MOR+1
         ASL   MOR+1
         ASL   MOR+1
         ASL   MOR+1
         ASL   MOR+1
         BCC   W2
         LDA   #$91
         BNE   W3
W2       LDA   #$90
W3       STA   MOR+2
         JSR   DRAW
         PLA
         AND   #1
         BEQ   W4
         LDA   #$91
         STA   MOR+2
         LDA   #$E0
         STA   MOR+1
         INC   FLAG
         INC   FLAG
         JMP   DRAW
W4       RTS
DRAW     LDA   #9
         STA   TEMP5
         LDA   TEMP2
         STA   TEMP6
D3       LDA   TEMP6
         JSR   CALC
         LDA   #3
         STA   TEMP7
         LDY   TEMP1
MOR      LDA   $9000
         INC   MOR+1
         LDX   FLAG
         BEQ   D1
         CPX   #1
         BNE   D4
         LDA   #0
         JMP   D1
D4       CPX   #3
         BNE   D2
         LDA   #$FF
D2       EOR   ($26),Y
D1       STA   ($26),Y
         INY
         DEC   TEMP7
         BNE   MOR
         INC   TEMP6
         DEC   TEMP5
         BNE   D3
         RTS
XSTOP    DFB   2,6,10,14,18,22,26,30,36
YSTOP    DFB   8,24,40,56,72,88,104,120
ADDR     TYA
         ORA   #$60
         STA   PTR+1
         TXA
         ASL
         ASL
         ASL
         STA   PTR
         RTS
PRINTG   LDA   TEMP0
         TAX
         LDY   TEMP1
         JSR   ADDR
         LDY   #0
G1       LDA   LINE,Y
         STA   $200,Y
         INY
         CMP   #$FF
         BNE   G1
         LDY   #1
         LDA   (PTR),Y
         BMI   WAVE
         BEQ   NONE
         TAY
         DEY
         TYA
         ASL
         ASL
         TAY
         LDA   GATES,Y
         STA   $207
         LDA   GATES+1,Y
         STA   $208
         LDA   GATES+2,Y
         STA   $209
         LDA   GATES+3,Y
         STA   $20A
         JMP   A1
GATES    ASC   'NOT AND NANDOR  NOR EOR NEOR'
LINE     DFB   0,164
         ASC   'GATE:              WAVEFORM:         '
         DFB   255
WT       ASC   'WAVE'
NT       ASC   'NONE'
WAVE     LDX   #3
         LDA   WT,X
         STA   $207,X
         DEX
         BPL   WAVE+2
         JMP   A1
NONE     LDX   #3
         LDA   NT,X
         STA   $207,X
         DEX
         BPL   NONE+2
         JMP   A2
A1       LDY   #2
         LDX   #0
         LDA   (PTR),Y
         BPL   AA1
         INX
AA1      STX   PREV
         LDX   #0
         STA   INDEX
A3       ASL   INDEX
         BCC   A4
         LDA   PREV
         BNE   AA2
         LDA   #1
         STA   PREV
         LDA   #'\'
         JMP   A5
AA2      LDA   #'^'
         JMP   A5
A4       LDA   PREV
         BEQ   AA4
         LDA   #0
         STA   PREV
         LDA   #']'
         JMP   A5
AA4      LDA   #'_'
A5       STA   542,X
         INX
         CPX   #8
         BNE   A3
A2       JSR   TEXT
         LDY   #0
A6       LDA   LINE2,Y
         STA   $200,Y
         INY
         CMP   #$FF
         BNE   A6
         LDY   #1
         LDA   (PTR),Y
         BEQ   A9
         BMI   A9
         LDY   #3
         LDA   (PTR),Y
         TAX
         LDA   HI,X
         STA   $208
         LDA   LO,X
         STA   $209
         INY
         LDA   (PTR),Y
         TAX
         LDA   HI,X
         STA   $20B
         LDA   LO,X
         STA   $20C
         LDX   #$19
         LDY   #3
         JSR   UIO
         LDY   #1
         LDA   (PTR),Y
         CMP   #1
         BEQ   A9
         LDY   #5
         LDA   (PTR),Y
         TAX
         LDA   HI,X
         STA   $20F
         LDA   LO,X
         STA   $210
         INY
         LDA   (PTR),Y
         TAX
         LDA   HI,X
         STA   $212
         LDA   LO,X
         STA   $213
         LDX   #$22
         LDY   #5
         JSR   UIO
A9       JSR   TEXT
         RTS
UIO      LDA   PTR
         PHA
         LDA   PTR+1
         PHA
         TXA
         PHA
         LDA   (PTR),Y
         TAX
         INY
         LDA   (PTR),Y
         TAY
         JSR   ADDR
         LDA   #7
         STA   ROTATE
         PLA
         TAX
         LDY   #2
         LDA   (PTR),Y
         LDY   #0
         CMP   #0
         BPL   ROT5
         INY
ROT5     STY   PREV
ROT1     ASL
         BCC   ROT2
         PHA
         LDA   PREV
         BNE   ROT6
         LDA   #1
         STA   PREV
         LDA   #'\'
         JMP   ROT3
ROT6     LDA   #'^'
         JMP   ROT3
ROT2     PHA
         LDA   PREV
         BEQ   ROT7
         LDA   #0
         STA   PREV
         LDA   #']'
         JMP   ROT3
ROT7     LDA   #'_'
ROT3     STA   $200,X
         PLA
         INX
         DEC   ROTATE
         BPL   ROT1
         PLA
         STA   PTR+1
         PLA
         STA   PTR
         RTS
ROTATE   DFB   0
LINE2    DFB   0,176
         ASC   'LINKS:  ,      ,    IN:        :        '
         DFB   255
PRINTP   LDX   #0
         TXA
         LDY   #0
E1       JSR   CALC+1
         LDY   #0
         LDA   #0
         STA   ($26),Y
         INY
         CPY   #34
         BNE   E1+5
         INX
         CPX   #134
         BNE   E1
         LDA   TEMP0
         PHA
         LDA   TEMP1
         PHA
         LDA   TEMP2
         PHA
         LDA   TEMP0
         STA   XP
         STA   XSAVE
         LDA   TEMP1
         STA   YP
         STA   YSAVE
         LDA   #0
         STA   COUNT1
         LDA   #0
         STA   COUNT2
E2       LDX   XP
         LDY   YP
         JSR   ADDR
         LDY   #1
         LDA   (PTR),Y
         LDX   COUNT1
         STA   TEMP0
         LDY   COUNT2
         STY   TEMP2
         STX   TEMP1
         JSR   BLOCKS
         INC   COUNT2
         INC   YP
         LDA   COUNT2
         CMP   #8
         BNE   E2
         LDA   #0
         STA   COUNT2
         LDA   YSAVE
         STA   YP
         INC   XP
         INC   COUNT1
         LDA   COUNT1
         CMP   #8
         BNE   E2
         LDA   #2
         STA   $200
         LDA   #0
         STA   $201
         LDY   #0
E5       LDX   XSAVE
         LDA   HI,X
         STA   $202,Y
         INY
         LDA   LO,X
         STA   $202,Y
         LDA   #' '
         INY
         STA   $202,Y
         INY
         STA   $202,Y
         INY
         INC   XSAVE
         CPY   #32
         BNE   E5
         LDA   #$FF
         STA   $202,Y
         JSR   TEXT
         LDA   #8
         STA   XP
E6       LDA   XP
         STA   $201
         LDA   #0
         STA   $200
         LDA   YSAVE
         TAX
         LDA   HI,X
         STA   $202
         LDA   LO,X
         STA   $203
         LDA   #$FF
         STA   $204
         JSR   TEXT
         INC   YSAVE
         LDA   XP
         CLC
         ADC   #16
         STA   XP
         CMP   #136
         BNE   E6
         PLA
         BNE   E7
         PLA
         PLA
         RTS
E7       PLA
         STA   TEMP1
         PLA
         STA   TEMP0
         STA   XSAVE
         LDA   TEMP1
         STA   YSAVE
         CLC
         ADC   #8
         STA   YP
         LDA   TEMP0
         CLC
         ADC   #8
         STA   XP
         LDA   #0
         STA   XOFF
         STA   XOFF+1
         STA   YOFF
         STA   YOFF+1
         LDA   TEMP0
         JSR   MULT28
         LDA   X1
         STA   XOFF
         LDA   X1+1
         STA   XOFF+1
         LDA   TEMP1
         JSR   MULT16
         LDA   Y1
         STA   YOFF
         LDA   Y1+1
         STA   YOFF+1
F1       LDA   TEMP0
         JSR   MULT28
         LDA   #16
         CLC
         ADC   X1
         STA   X2
         LDA   #0
         ADC   X1+1
         STA   X2+1
         LDA   TEMP1
         JSR   MULT16
         LDA   #10
         CLC
         ADC   Y1
         STA   Y2
         LDA   #0
         ADC   Y1+1
         STA   Y2+1
         LDX   TEMP0
         LDY   TEMP1
         JSR   ADDR
         LDY   #1
         LDA   (PTR),Y
         BEQ   NO
         BMI   NO
         LDY   #3
         LDA   (PTR),Y
         CMP   XP
         BGE   NO
         CMP   XSAVE
         BLT   NO
         JSR   MULT28
         LDA   #32
         CLC
         ADC   X1
         STA   X1
         LDA   #0
         ADC   X1+1
         STA   X1+1
         LDY   #4
         LDA   (PTR),Y
         CMP   YP
         BGE   NO
         CMP   YSAVE
         BLT   NO
         JSR   MULT16
         LDA   #11
         ADC   Y1
         STA   Y1
         LDA   #0
         ADC   Y1+1
         STA   Y1+1
         JSR   PLOTIT
NO       LDY   #1
         LDA   (PTR),Y
         CMP   #1
         BEQ   NO2
         CMP   #0
         BEQ   NO2
         BMI   NO2
         LDA   Y2
         ADC   #3
         STA   Y2
         LDY   #5
         LDA   (PTR),Y
         CMP   XP
         BGE   NO2
         CMP   XSAVE
         BLT   NO2
         JSR   MULT28
         LDA   #32
         CLC
         ADC   X1
         STA   X1
         LDA   #0
         ADC   X1+1
         STA   X1+1
         LDY   #6
         LDA   (PTR),Y
         CMP   YP
         BGE   NO2
         CMP   YSAVE
         BLT   NO2
         JSR   MULT16
         LDA   Y1
         ADC   #11
         STA   Y1
         LDA   Y1+1
         ADC   #0
         STA   Y1+1
         JSR   PLOTIT
NO2      INC   TEMP1
         LDA   TEMP1
         CMP   YP
         BEQ   F5
         JMP   F1
F5       LDA   YSAVE
         STA   TEMP1
         INC   TEMP0
         LDA   TEMP0
         CMP   XP
         BEQ   F6
         JMP   F1
F6       RTS
MULT28   TAX
         LDA   #0
         STA   X1
         STA   X1+1
         LDY   #28
F2       TXA
         CLC
         ADC   X1
         STA   X1
         LDA   X1+1
         ADC   #0
         STA   X1+1
         DEY
         BNE   F2
         LDA   X1
         SEC
         SBC   XOFF
         STA   X1
         LDA   X1+1
         SBC   XOFF+1
         STA   X1+1
         RTS
MULT16   STA   Y1
         LDA   #0
         STA   Y1+1
         ASL   Y1
         ROL   Y1+1
         ASL   Y1
         ROL   Y1+1
         ASL   Y1
         ROL   Y1+1
         ASL   Y1
         ROL   Y1+1
         LDA   Y1
         SEC
         SBC   YOFF
         STA   Y1
         LDA   Y1+1
         SBC   YOFF+1
         STA   Y1+1
         RTS
PLOTIT   LDA   Y1
         LDX   X1
         LDY   X1+1
         JSR   $F457
         LDY   Y1
         LDA   X2
         LDX   X2+1
         JSR   $F53A
         LDY   Y2
         LDA   X2
         LDX   X2+1
         JSR   $F53A
         RTS
X1       DS    2
Y1       DS    2
X2       DS    2
Y2       DS    2
XOFF     DS    2
YOFF     DS    2
COUNT1   DFB   0
COUNT2   DFB   0
XP       DFB   0
YP       DFB   0
XSAVE    DFB   0
YSAVE    DFB   0
HI       ASC   '000000000011111111112222222222333333'
LO       ASC   '012345678901234567890123456789012345'
PRINTW   LDY   #0
         LDA   #1
         STA   $200,Y
         INY
         LDA   #140
         STA   $200,Y
         INY
         LDX   #1
         STX   COUNT1
R2       LDX   COUNT1
         TXA
         ORA   #$B0
         STA   $200,Y
         INY
         LDA   $7FFF,X
         LDX   #7
         STA   COUNT2
         AND   #$80
         ASL
         ROL
         STA   PREV
R3       ASL   COUNT2
         BCC   R1
         LDA   PREV
         BEQ   GGGG1
         LDA   #'^'
         JMP   R5
GGGG1    INC   PREV
         LDA   #'\'
         JMP   R5
R1       LDA   PREV
         BNE   GGGG2
         LDA   #'_'
         JMP   R5
GGGG2    DEC   PREV
         LDA   #']'
R5       STA   $200,Y
         INY
         DEX
         BPL   R3
         LDA   #' '
         STA   $200,Y
         INY
         INC   COUNT1
         LDA   COUNT1
         CMP   #5
         BNE   R2
         LDA   #$FF
         STA   $200,Y
         JSR   TEXT
         LDY   #0
         LDA   #1
         STA   $200,Y
         INY
         LDA   #152
         STA   $200,Y
         INY
         LDX   #5
         STX   COUNT1
T2       LDX   COUNT1
         TXA
         ORA   #$B0
         STA   $200,Y
         INY
         LDA   $7FFF,X
         LDX   #7
         STA   COUNT2
         AND   #$80
         ASL
         ROL
         STA   PREV
T3       ASL   COUNT2
         BCC   T1
         LDA   PREV
         BEQ   GGGG3
         LDA   #'^'
         JMP   T5
GGGG3    INC   PREV
         LDA   #'\'
         JMP   T5
T1       LDA   PREV
         BNE   GGGG4
         LDA   #'_'
         JMP   T5
GGGG4    DEC   PREV
         LDA   #']'
T5       STA   $200,Y
         INY
         DEX
         BPL   T3
         LDA   #' '
         STA   $200,Y
         INY
         INC   COUNT1
         LDA   COUNT1
         CMP   #9
         BNE   T2
         LDA   #$FF
         STA   $200,Y
         JMP   TEXT
PREV     DFB   0
