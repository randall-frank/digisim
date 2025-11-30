         ORG   $8D00
         DSK   ../bin/LOGIC2#068D00
         TYP   $06        ; /BIN file
         LST   OFF

         PUT   COMMON.S

PTRS     =     0
TEMP1    =     2
TEMP2    =     4
INPUT1   =     6
INPUT2   =     7

         LDY   #7
L1       LDA   $8000,Y
         EOR   #$FF
         STA   $8008,Y
         DEY
         BPL   L1
         LDA   #0
         STA   TEMP1
         STA   TEMP1+1
L2       LDX   TEMP1
         LDY   TEMP1+1
         JSR   SETPTRS
         LDX   #0
         LDA   #4
         STA   (PTRS,X)
         LDY   #7
         LDA   #0
         STA   (PTRS),Y
         INC   TEMP1
         LDA   TEMP1
         CMP   #32
         BNE   L2
         LDA   #0
         STA   TEMP1
         INC   TEMP1+1
         LDA   TEMP1+1
         CMP   #32
         BNE   L2
         LDA   #190
         STA   COUNT
         LDA   #0
         STA   FLAGGER
BIGLOOP  LDA   #0
         STA   TEMP1
         STA   TEMP1+1
         STA   FLAG
L3       JSR   DOGATE
         INC   TEMP1
         LDA   TEMP1
         CMP   #32
         BNE   L3
         LDA   #0
         STA   TEMP1
         INC   TEMP1+1
         LDA   TEMP1+1
         CMP   #32
         BNE   L3
         INC   COUNT
         BEQ   DONE2
         LDA   FLAG
         BNE   BIGLOOP
         INC   FLAGGER
         LDA   FLAGGER
         CMP   #3
         BNE   BIGLOOP
         LDA   #0
         STA   0
DONE     RTS
DONE2    LDA   #1
         STA   0
         RTS
SETPTRS  TYA
         ORA   #$60
         STA   PTRS+1
         TXA
         ASL
         ASL
         ASL
         STA   PTRS
         LDA   PTRS+1
         CMP   #$FF
         BEQ   SPEC
         RTS
SPEC     LDA   #<EXTRA
         STA   PTRS
         LDA   #>EXTRA
         STA   PTRS+1
         RTS
EXTRA    HEX   01000000000000FF
COUNT    DFB   0
FLAG     DFB   0
DOGATE   LDX   TEMP1
         LDY   TEMP1+1
         JSR   SETPTRS
         LDA   PTRS
         STA   TEMP2
         LDA   PTRS+1
         STA   TEMP2+1
         LDY   #1
         LDA   (TEMP2),Y
         BPL   GATE
         AND   #$7F
         LSR
         BCS   WAVENOT
         TAY
         LDA   $8000,Y
         LDY   #2
         STA   (TEMP2),Y
OK       LDY   #0
         LDA   #0
         STA   (TEMP2),Y
         LDY   #7
         LDA   #$FF
         STA   (TEMP2),Y
         RTS
WAVENOT  TAY
         LDA   $8008,Y
         LDY   #2
         STA   (TEMP2),Y
         JMP   OK
GATE     BNE   REAL
         LDY   #2
         LDA   #0
         STA   (TEMP2),Y
         JMP   OK
REAL     LDY   #3
         LDA   (TEMP2),Y
         TAX
         INY
         LDA   (TEMP2),Y
         TAY
         JSR   SETPTRS
         LDY   #7
         LDA   (PTRS),Y
         STA   VALID1
         LDY   #2
         LDA   (PTRS),Y
         STA   INPUT1
         LDY   #5
         LDA   (TEMP2),Y
         TAX
         INY
         LDA   (TEMP2),Y
         TAY
         JSR   SETPTRS
         LDY   #7
         LDA   (PTRS),Y
         STA   VALID2
         LDY   #2
         LDA   (PTRS),Y
         STA   INPUT2
         LDY   #0
         LDA   VALID1
         BEQ   DIRTY
         LDA   VALID2
         BEQ   DIRTY
         JMP   CLEAN
DIRTY    INY
CLEAN    STY   FLAG2
         LDA   VALID1
         AND   VALID2
         STA   VALIDF
         LDY   #1
         LDA   (TEMP2),Y
         PHA
         AND   #$0E
         CMP   #0
         BEQ   GOR
         CMP   #2
         BEQ   GAND
         CMP   #4
         BEQ   GOR
         CMP   #6
         BEQ   GEOR
GAND     LDA   INPUT1
         EOR   #$FF
         AND   VALID1
         ORA   VALIDF
         STA   VALIDF
         LDA   INPUT2
         EOR   #$FF
         AND   VALID2
         ORA   VALIDF
         STA   VALIDF
         LDA   INPUT1
         AND   INPUT2
         STA   INPUTF
         JMP   HANDLE
GOR      LDA   INPUT1
         AND   VALID1
         ORA   VALIDF
         STA   VALIDF
         LDA   INPUT2
         AND   VALID2
         ORA   VALIDF
         STA   VALIDF
         LDA   INPUT1
         ORA   INPUT2
         STA   INPUTF
         JMP   HANDLE
GEOR     LDA   INPUT1
         EOR   INPUT2
         STA   INPUTF
HANDLE   PLA
         LSR
         BCC   OK2
         LDA   INPUTF
         EOR   #$FF
         STA   INPUTF
OK2      LDA   #0
         STA   PREV
         LDA   VALIDF
         STA   VALID1
         CMP   #$FF
         BEQ   JJ1
         LDX   #7
IT1      ASL   VALID1
         BCS   IT2
         LDA   MASK,X
         ORA   INPUTF
         STA   INPUTF
         LDA   MASK,X
         AND   PREV
         STA   VALID2
         LDA   MASK,X
         EOR   #$FF
         ORA   VALID2
         AND   INPUTF
         STA   INPUTF
         JMP   NEXTBIT
IT2      LDA   MASK,X
         AND   INPUTF
         BEQ   IT3
         LDA   #$FF
         STA   PREV
         JMP   NEXTBIT
IT3      LDA   #0
         STA   PREV
NEXTBIT  DEX
         BPL   IT1
JJ1      LDY   #0
         LDA   VALIDF
         CMP   #$FF
         BNE   JJJ
         TYA
         STA   (TEMP2),Y
         JMP   ONWEGO
JJJ      LDA   (TEMP2),Y
         LDY   FLAG2
         BNE   ONWEGO2
         TAY
         DEY
         BEQ   JJ2
         TYA
         LDY   #0
         STA   (TEMP2),Y
ONWEGO2  STA   FLAG
         JMP   ONWEGO
JJ2      LDA   #$FF
         STA   VALIDF
         TYA
         STA   (TEMP2),Y
ONWEGO   LDY   #2
         LDA   INPUTF
         STA   (TEMP2),Y
         LDY   #7
         LDA   VALIDF
         STA   (TEMP2),Y
         RTS
MASK     DFB   1,2,4,8,16,32,64,128
FLAG2    DFB   0
VALID2   DFB   0
VALID1   DFB   0
INPUTF   DFB   0
VALIDF   DFB   0
PREV     DFB   0
FLAGGER  DFB   0
