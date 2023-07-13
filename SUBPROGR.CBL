        IDENTIFICATION DIVISION.
        PROGRAM-ID. SUBPROGR.
        AUTHOR.     BURAK OZDEMIR.
        ENVIRONMENT DIVISION.
        INPUT-OUTPUT SECTION.
        FILE-CONTROL.
            SELECT IDX-FILE   ASSIGN TO IDXFILE
                              ORGANIZATION INDEXED
                              ACCESS RANDOM
                              RECORD KEY IDX-KEY
                              STATUS IDX-ST.
        DATA DIVISION.
        FILE SECTION.
        FD  IDX-FILE.
        01  IDX-RECORD.
            03  IDX-KEY.
                05 IDX-ID            PIC S9(05) COMP-3.
                05 IDX-DVZ           PIC S9(03) COMP.
            03  IDX-ALLNAME          PIC X(30).
            03  IDX-DATE             PIC 9(07) COMP-3.
            03  IDX-BUDGET           PIC S9(13)V99 COMP-3.
      *
        WORKING-STORAGE SECTION.
        01  WS-WORK-AREA.
            05 IDX-ST                PIC 9(02).
               88 IDX-SUCCESS        VALUE 00 97.
               88 IDX-DUPLICATE      VALUE 22.
               88 IDX-NOTFND         VALUE 23.
            05 TEMP-NAME             PIC X(15).
            05 TEMP-LASTNAME         PIC X(15).
            05 I                     PIC 9(02).
            05 J                     PIC 9(02).
       01   FLAG.
		      05 GO-HOME               PIC 9(01).
               88 GO-SUCCESS         VALUE 1.
        LINKAGE SECTION.
        01 WS-SUB-AREA.
           07 WS-SUB-FUNC            PIC X(01).
              88 WS-FUNC-WRITE                 VALUE 'W'.
              88 WS-FUNC-UPDATE                VALUE 'U'.
              88 WS-FUNC-READ                  VALUE 'R'.
              88 WS-FUNC-DELETE                VALUE 'D'.
           07 WS-KEY.
              09 WS-SUB-ID           PIC S9(05) COMP-3.
              09 WS-SUB-DVZ          PIC S9(03) COMP.
           07 WS-SUB-DATA            PIC X(30).
           07 WS-DATE                PIC 9(07) COMP-3.
           07 WS-BUDGET              PIC S9(13)V99 COMP-3.
           07 WS-SUB-RC              PIC 9(02).
           07 WS-ERROR-EXPLAIN       PIC X(42).
           07 WS-ALLNAME-BEFORE      PIC X(30).
       PROCEDURE DIVISION USING WS-SUB-AREA.
       0000-MAIN.
           PERFORM H100-OPEN-FILES
           EVALUATE TRUE
             WHEN WS-FUNC-WRITE
                PERFORM WRT-PROCESS
             WHEN WS-FUNC-UPDATE
                PERFORM UPT-PROCESS
             WHEN WS-FUNC-READ
                PERFORM READ-PROCESS
             WHEN WS-FUNC-DELETE
                PERFORM DEL-PROCESS
             WHEN OTHER
               STRING 'ERROR: FROM INPUT, UNDEFINED LETTER: '
               WS-SUB-FUNC
               DELIMITED BY SIZE INTO WS-ERROR-EXPLAIN
               PERFORM H999-PROGRAM-EXIT
           END-EVALUATE
      * Bu satira gelmesi mumkun degil fakat yine de EXIT satiri
      * ekledim.
           PERFORM H999-PROGRAM-EXIT.
       0000-END. EXIT.
      *
       H100-OPEN-FILES.
           OPEN I-O IDX-FILE
           PERFORM IDX-STATUS-CONTROL
           SET GO-SUCCESS TO TRUE.
       H100-OPEN-FILES-END. EXIT.
      *
       IDX-STATUS-CONTROL.
           IF NOT IDX-SUCCESS THEN
              MOVE IDX-ST TO WS-SUB-RC
              STRING 'ERROR: IDX-FILE WAS NOT OPENED RC: ' WS-SUB-RC
              DELIMITED BY SIZE INTO WS-ERROR-EXPLAIN
              GOBACK.
       IDX-STATUS-CONTROL-END. EXIT.
      *
       IS-ID-EXIST.
           MOVE WS-KEY TO IDX-KEY
           READ IDX-FILE KEY IS IDX-KEY
           PERFORM STATUS-CONTROL.
       IS-ID-EXIST-END. EXIT.
      *
       WRT-PROCESS.
           MOVE WS-SUB-ID                        TO IDX-ID
           MOVE WS-SUB-DVZ                       TO IDX-DVZ
           MOVE 'U N N A M E D  UNSURNAMED     ' TO IDX-ALLNAME
           MOVE '1901001'                        TO IDX-DATE
           MOVE '000000000001000'                TO IDX-BUDGET
           WRITE IDX-RECORD
           PERFORM STATUS-CONTROL
           MOVE IDX-ALLNAME                      TO WS-SUB-DATA
      *    Buradan goback yaptigimizda ana programda sadece 
      *    WS-SUB-DATA'yi kullaniyorum. Fakat BUDGET VE DATE'i 
      *    kullanmamiz durumunda bir hata olusmasin diye burada 
      *    onlari da doldurduk.
           MOVE IDX-DATE                         TO WS-DATE 
           MOVE IDX-BUDGET                       TO WS-BUDGET 
           PERFORM H999-PROGRAM-EXIT.
       WRT-PROCESS-END. EXIT.
      *
       READ-PROCESS.
           PERFORM IS-ID-EXIST
           MOVE IDX-ID       TO WS-SUB-ID
           MOVE IDX-DVZ      TO WS-SUB-DVZ
           MOVE IDX-ALLNAME  TO WS-SUB-DATA
           MOVE IDX-DATE     TO WS-DATE
           MOVE IDX-BUDGET   TO WS-BUDGET
           PERFORM H999-PROGRAM-EXIT.
       READ-PROCESS-END. EXIT.
      *
       UPT-PROCESS.
           PERFORM IS-ID-EXIST
           PERFORM IS-UPDATED
      *    TEMP-NAME'i boslukla dolduruyoruz, cunku isim 'CEM' gibi 
      *    kisa bir isim olabilir. Ve TEMP-NAME'i yukarida kullandim
      *    diye.
           MOVE SPACES TO TEMP-NAME 
           MOVE 1 TO I 
           MOVE 1 TO J
           MOVE IDX-ALLNAME  TO WS-ALLNAME-BEFORE
           PERFORM VARYING I FROM 1 BY 1 UNTIL I > 15
             IF NOT IDX-ALLNAME(I:1) = SPACE
               MOVE IDX-ALLNAME(I:1) TO TEMP-NAME(J:1)
               ADD 1 TO J
             END-IF
           END-PERFORM
           MOVE TEMP-NAME TO IDX-ALLNAME(1:15).
           MOVE IDX-ALLNAME(15:15) TO TEMP-LASTNAME 
           INSPECT TEMP-LASTNAME REPLACING ALL 'E' BY 'I'
           INSPECT TEMP-LASTNAME REPLACING ALL 'e' BY 'i'
           INSPECT TEMP-LASTNAME REPLACING ALL 'A' BY 'E'
           INSPECT TEMP-LASTNAME REPLACING ALL 'a' BY 'e'
           MOVE TEMP-LASTNAME TO IDX-ALLNAME(15:15)
           REWRITE IDX-RECORD
           REWRITE IDX-RECORD
           PERFORM STATUS-CONTROL.
           MOVE IDX-ALLNAME TO WS-SUB-DATA
           PERFORM H999-PROGRAM-EXIT.
       UPT-PROCESS-END. EXIT.
      *
       IS-UPDATED.
            MOVE 0 TO I.
            MOVE 0 TO J.
      *     Record daha once UPDATE edildi mi diye bu kisimda bakiyorum.
      *     Ismimizin sonundaki bosluklari saydigimizda sondaki 
      *     bosluklarin sayisi ismimizin icindeki tum bosluk sayisina
      *     esitse ismimiz daha once UPDATE edilmistir. Sondaki bosluk
      *     sayisi ismimizin icindeki tum bosluk sayisina esit degilse
      *     o zaman ismimizin karakterleri arasinda hala bosluk vardir.
      *     Burada bunu yapiyorum. Fakat bu durumda '_________MEHMET' 
      *     gibi ismi sona yazdigimizda da bosluk sayilari esitlenir.
      *     Bu yuzden IF kontrolumuzun yanında ilk karakterin bosluk
      *     olup olmadigini da kontrol ediyoruz.
            MOVE FUNCTION REVERSE(IDX-ALLNAME(1:15)) TO TEMP-NAME 
            INSPECT TEMP-NAME TALLYING I FOR LEADING SPACES.
            INSPECT TEMP-NAME TALLYING J FOR ALL SPACES.
            IF I = J AND NOT IDX-ALLNAME(1:1) = SPACE 
              INITIALIZE WS-ERROR-EXPLAIN
              MOVE IDX-ST TO WS-SUB-RC
              STRING 'ERROR, ALREADY WAS UPDATED BEFORE.'
              DELIMITED BY SIZE INTO WS-ERROR-EXPLAIN
              PERFORM H999-PROGRAM-EXIT.
       IS-UPDATED-END. EXIT.
      *
       DEL-PROCESS.
           MOVE WS-KEY TO IDX-KEY
           READ IDX-FILE KEY IS IDX-KEY
           IF IDX-NOTFND THEN
              MOVE IDX-ST TO WS-SUB-RC
              STRING 'ERROR, ALREADY WAS DELETED.'
              DELIMITED BY SIZE INTO WS-ERROR-EXPLAIN
              PERFORM H999-PROGRAM-EXIT.
           MOVE IDX-ALLNAME  TO WS-ALLNAME-BEFORE
           DELETE IDX-FILE RECORD
           IF NOT IDX-SUCCESS THEN
              INITIALIZE WS-ERROR-EXPLAIN
              MOVE IDX-ST TO WS-SUB-RC
              STRING '!ERROR! RECORD EXIST, BUT WAS NOT DELETED.'
              DELIMITED BY SIZE INTO WS-ERROR-EXPLAIN
              PERFORM H999-PROGRAM-EXIT.
           MOVE SPACES TO WS-SUB-DATA.
           PERFORM STATUS-CONTROL.
           PERFORM H999-PROGRAM-EXIT.
       DEL-PROCESS-END. EXIT.
      *
       STATUS-CONTROL.
      * En basta initialize etmemizin sebebi bazi fonksiyonlarda
      * STATUS-CONTROL'u 2 kez cagiriyorum. İlk cagirista SUCCESSFULL 
      * olup ikinci cagirista baska bir hata mesaji ile dolum olacaksa
      * karakterlerde sorun olmasin diye en basta sifirliyoruz hep.
           INITIALIZE WS-ERROR-EXPLAIN
           EVALUATE TRUE
             WHEN IDX-SUCCESS AND WS-FUNC-READ
                   MOVE IDX-ST TO WS-SUB-RC
                   STRING 'SUCCESSFULL, RECORD WAS READ.'
                   DELIMITED BY SIZE INTO WS-ERROR-EXPLAIN
             WHEN IDX-SUCCESS AND WS-FUNC-WRITE
                   MOVE IDX-ST TO WS-SUB-RC
                   STRING 'SUCCESSFULL, RECORD WAS ADDED.'
                   DELIMITED BY SIZE INTO WS-ERROR-EXPLAIN
             WHEN IDX-SUCCESS AND WS-FUNC-DELETE
                   MOVE IDX-ST TO WS-SUB-RC
                   STRING 'SUCCESSFULL, RECORD WAS DELETED.'
                   DELIMITED BY SIZE INTO WS-ERROR-EXPLAIN
             WHEN IDX-SUCCESS AND WS-FUNC-UPDATE
                   MOVE IDX-ST TO WS-SUB-RC
                   STRING 'SUCCESSFULL, RECORD WAS UPDATED.'
                   DELIMITED BY SIZE INTO WS-ERROR-EXPLAIN
      * YENI EKLENDI
             WHEN IDX-NOTFND AND WS-FUNC-UPDATE
                   MOVE IDX-ST TO WS-SUB-RC
                   STRING 'ERROR, RECORD NOT FOUND FOR UPDATE.'
                   DELIMITED BY SIZE INTO WS-ERROR-EXPLAIN
                   PERFORM H999-PROGRAM-EXIT
             WHEN IDX-NOTFND
                   MOVE IDX-ST TO WS-SUB-RC
                   STRING 'ERROR, RECORD WAS NOT READ.'
                   DELIMITED BY SIZE INTO WS-ERROR-EXPLAIN
                   MOVE SPACES TO WS-SUB-DATA
                   PERFORM H999-PROGRAM-EXIT
             WHEN IDX-DUPLICATE
                   MOVE IDX-ST TO WS-SUB-RC
                   STRING 'ERROR, DUPLICATE KEY.'
                   DELIMITED BY SIZE INTO WS-ERROR-EXPLAIN
                   PERFORM H999-PROGRAM-EXIT
             WHEN OTHER
                   MOVE IDX-ST TO WS-SUB-RC
                   STRING 'ERROR, ANOTHER PROBLEM.'
                   'MAY REWRITE PROBLEM'
                   DELIMITED BY SIZE INTO WS-ERROR-EXPLAIN
                   PERFORM H999-PROGRAM-EXIT
           END-EVALUATE.
       STATUS-CONTROL-END. EXIT.
      *
       H999-PROGRAM-EXIT.
            IF GO-SUCCESS
              CLOSE IDX-FILE
              GOBACK.
       H999-END. EXIT.
      *
       END PROGRAM SUBPROGR.
