        IDENTIFICATION DIVISION.
        PROGRAM-ID.    REALIDX.
        AUTHOR.        BURAK OZDEMIR.
        ENVIRONMENT DIVISION.
        INPUT-OUTPUT SECTION.
        FILE-CONTROL.
            SELECT OUT-FILE   ASSIGN TO OUTFILE
                              STATUS    OUT-ST.
            SELECT INP-FILE   ASSIGN TO INPFILE
                              STATUS    INP-ST.
        DATA DIVISION.
        FILE SECTION.
      *
        FD  INP-FILE RECORDING MODE F.
        01  INP-REC.
            05  INP-PROC-TYPE         PIC X(01).
            05  INP-ID                PIC S9(05).
            05  INP-DVZ               PIC S9(03).
        FD  OUT-FILE RECORDING MODE F.
        01  OUT-REC.
            05  OUT-KEY.
                07  OUT-ID            PIC 9(05).
                07  OUT-SPACE-0       PIC X(01).
                07  OUT-DVZ           PIC 9(03).
            05  OUT-SPACE-1           PIC X(01).
            05  OUT-PROC-TYPE         PIC X(06).
            05  OUT-SPACE-2           PIC X(01).
            05  OUT-RETURN-CODE       PIC 9(02).
            05  OUT-SPACE-3           PIC X(01).
            05  OUT-EXPLAIN           PIC X(42).
            05  OUT-SPACE-4           PIC X(01).
            05  OUT-FNAME-FROM        PIC X(15).
            05  OUT-SPACE-5           PIC X(01).
            05  OUT-FNAME-TO          PIC X(15).
            05  OUT-SPACE-6           PIC X(01).
            05  OUT-LNAME-FROM        PIC X(15).
            05  OUT-SPACE-7           PIC X(01).
            05  OUT-LNAME-TO          PIC X(15).
            05  OUT-SPACE-8           PIC X(01).
            05  OUT-BUDGET            PIC $,$$$,$$$,$$$,$$$9.99.
        WORKING-STORAGE SECTION.
        01  WS-WORK-AREA.
            05 OUT-ST               PIC 9(02).
               88 OUT-SUCCESS               VALUE 00 97.
            05 INP-ST               PIC 9(02).
               88 INP-EOF                   VALUE 10.
               88 INP-SUCCESS               VALUE 00 97.
            05 WS-PBEGIDX           PIC X(08) VALUE 'SUBPROGR'.
            05 TEMP-REC-62          PIC X(62).
            05  TEMP-REC-113        PIC X(126).
            05  TMP-DATE            PIC 9(07).
            05  TMP-INT-JULIAN      PIC 9(07).
            05  TMP-GREG            PIC 9(08).
        01  FLAG.
            05 GO-HOME               PIC 9(01).
               88 GO-SUCCESS         VALUE 1.
      * Alt programa olarak yollayacagimiz alan.
        01  WS-SUB-AREA.
            07 WS-SUB-FUNC       PIC X(01).
              88 WS-FUNC-WRITE                 VALUE 'W'.
              88 WS-FUNC-UPDATE                VALUE 'U'.
              88 WS-FUNC-READ                  VALUE 'R'.
              88 WS-FUNC-DELETE                VALUE 'D'.
            07 WS-KEY.
               09 WS-SUB-ID      PIC S9(05) COMP-3.
               09 WS-SUB-DVZ     PIC S9(03) COMP.
            07 WS-SUB-DATA       PIC X(30).
            07 WS-DATE           PIC 9(07) COMP-3.
            07 WS-BUDGET         PIC S9(13)V99 COMP-3.
            07 WS-SUB-RC         PIC 9(02).
            07 WS-ERROR-EXPLAIN  PIC X(42).
            07 WS-ALLNAME-BEFORE PIC X(30).
        01  HEADER-NOTE.
            05  FILLER         PIC X(20) VALUE 'Note : If EVENT is '.
            05  FILLER         PIC X(16) VALUE 'READ(R), use the'.
            05  FILLER         PIC X(21) VALUE ' parenthesis section.'.
            05  FILLER         PIC X(91) VALUE SPACES.
        01  HEADER-0.
            05  FILLER         PIC X(62) VALUE SPACES.
            05  FILLER         PIC X(16) VALUE '|    (NAME)     '.
            05  FILLER         PIC X(16) VALUE '|   (SURNAME)   '.
            05  FILLER         PIC X(16) VALUE '|  (BIRTH DATE) '.
            05  FILLER         PIC X(16) VALUE '|               '.
            05  FILLER         PIC X(22) VALUE '|      (BUDGET)      |'.
        01  HEADER-1.
            05  FILLER         PIC X(05) VALUE ' ID  '.
            05  FILLER         PIC X(04) VALUE '|DVZ'.
            05  FILLER         PIC X(07) VALUE '|EVENT '.
            05  FILLER         PIC X(03) VALUE '|RC'.
            05  FILLER         PIC X(22) VALUE '|                  MES'.
            05  FILLER         PIC X(04) VALUE 'SAGE'.
            05  FILLER         PIC X(17) VALUE SPACES.
            05  FILLER         PIC X(16) VALUE '|  BEFORE NAME  '.
            05  FILLER         PIC X(16) VALUE '|  AFTER NAME   '.
            05  FILLER         PIC X(16) VALUE '| BEFORE L.NAME '.
            05  FILLER         PIC X(17) VALUE '| AFTER L.NAME  |'.
            05  FILLER         PIC X(21) VALUE '                    |'.
        01  HEADER-2.
            05  FILLER         PIC X(05) VALUE '-----'.
            05  FILLER         PIC X(04) VALUE ' ---'.
            05  FILLER         PIC X(07) VALUE ' ------'.
            05  FILLER         PIC X(03) VALUE ' --'.
            05  FILLER         PIC X(22) VALUE ' ---------------------'.
            05  FILLER         PIC X(21) VALUE '---------------------'.
            05  FILLER         PIC X(16) VALUE ' ---------------'.
            05  FILLER         PIC X(16) VALUE ' ---------------'.
            05  FILLER         PIC X(16) VALUE ' ---------------'.
            05  FILLER         PIC X(16) VALUE ' ---------------'.
            05  FILLER         PIC X(12) VALUE ' -----------'.
            05  FILLER         PIC X(10) VALUE '--------- '.
        PROCEDURE DIVISION.
        0000-MAIN.
           PERFORM H100-OPEN-FILES.
           WRITE OUT-REC FROM HEADER-NOTE.
           WRITE OUT-REC FROM HEADER-0.
           WRITE OUT-REC FROM HEADER-1.
           WRITE OUT-REC FROM HEADER-2.
      * Ilk record okumamizi burada yapiyoruz, cunku H200'u calistiran
      * perform INPUT dosyamiz bos ise calismamali, yani input dosyamiz
      * bos ise INP-EOF TRUE'ya donusmeli. O yuzden once burada bir kez
      * okuma yaptik ve INP-EOF'u ayarlamis olduk.
           PERFORM READ-RECORD.
           EVALUATE TRUE
             WHEN INP-EOF
               INITIALIZE WS-ERROR-EXPLAIN
               DISPLAY 'ERROR: INPUT FILE IS EMPTY.'
               STRING 'ERROR: GO TO [RUN:SYSOUT] PLEASE'
               DELIMITED BY SIZE INTO WS-ERROR-EXPLAIN
               WRITE OUT-REC FROM WS-ERROR-EXPLAIN
           END-EVALUATE.
           PERFORM H200-PROCESS UNTIL INP-EOF.
           PERFORM H999-PROGRAM-EXIT.
        0000-END-MAIN. EXIT.
      *
        H100-OPEN-FILES.
            OPEN INPUT  INP-FILE
            OPEN OUTPUT OUT-FILE
            PERFORM STATUS-CONTROL
            SET GO-SUCCESS TO TRUE.
        H100-END. EXIT.
      *
        STATUS-CONTROL.
            IF NOT (OUT-SUCCESS AND INP-SUCCESS) THEN
               DISPLAY 'FILE OR FILES NOT OPENED.'
               DISPLAY 'F.STATUS =>  INP: ' INP-ST ' OUT: ' OUT-ST
               IF OUT-SUCCESS THEN CLOSE OUT-FILE
               IF INP-SUCCESS THEN CLOSE INP-FILE
               STOP RUN.
        STATUS-CONTROL-END. EXIT.
      *
        H200-PROCESS.
            INITIALIZE WS-SUB-AREA
            MOVE INP-PROC-TYPE     TO WS-SUB-FUNC
            MOVE INP-ID            TO WS-SUB-ID
            MOVE INP-DVZ           TO WS-SUB-DVZ
            CALL WS-PBEGIDX USING BY REFERENCE WS-SUB-AREA
            PERFORM H250-COND-CONTROL
            PERFORM READ-RECORD.
        H200-END. EXIT.
      *
        H250-COND-CONTROL.
            INITIALIZE OUT-REC TEMP-REC-62 TEMP-REC-113
            EVALUATE TRUE
      * Buradaki ilk WHEN ifadesi IDX-FILE acilamazsa sadece
      * hata aciklamasi yazilsin diye var. Aksi takdirde ID,DVZ,WRITE
      * gibi degerler de yaziliyor. Ayrica programi durduruyoruz.
              WHEN (NOT WS-SUB-RC = 0 AND NOT WS-SUB-RC = 91)
                   AND NOT WS-FUNC-READ AND
                   NOT WS-FUNC-DELETE AND NOT WS-FUNC-UPDATE AND
                   NOT WS-FUNC-WRITE
                WRITE OUT-REC FROM WS-ERROR-EXPLAIN
                PERFORM H999-PROGRAM-EXIT
              WHEN NOT WS-SUB-RC = 0
                PERFORM H275-FILL-PART1
      * Burada bir TEMP'e aktarim yapilmasinin sebebi OUT-REC'in
      * sadece 62 karakterini sadece DISPLAY ile yazdirabiliyoruz.
      * Ama bizim amacimiz WRITE ile dosyamiza yazdirmak. Bu yuzden
      * gecici bir degiskene attik, daha sonra yazdirdik.
                MOVE OUT-REC(1:62) TO TEMP-REC-62
                WRITE OUT-REC FROM TEMP-REC-62
      * Bu ust satirdaki kullanim DISPLAY ile yapilirsa ekranda NULL
      * karakterler belirecektir.
              WHEN WS-FUNC-READ
                PERFORM H275-FILL-PART1
                PERFORM H290-FILL-AS-READ
                WRITE OUT-REC
              WHEN OTHER
      * Basarili bir UPTADE, DELETE, WRITE isleminin OUTPUT'a
      * yazdirilmasi burada gerceklesir.
                PERFORM H275-FILL-PART1
                PERFORM H285-FILL-PART2
                MOVE OUT-REC(1:126) TO TEMP-REC-113
                WRITE OUT-REC FROM TEMP-REC-113
            END-EVALUATE.
        H250-COND-CONTROL-END. EXIT.
      *
        H275-FILL-PART1.
            MOVE WS-SUB-ID        TO OUT-ID
            MOVE '-'              TO OUT-SPACE-0
            MOVE WS-SUB-DVZ       TO OUT-DVZ
            MOVE '-'              TO OUT-SPACE-1
            EVALUATE TRUE
              WHEN WS-FUNC-WRITE
                 MOVE 'WRITE '    TO OUT-PROC-TYPE
              WHEN WS-FUNC-UPDATE
                 MOVE 'UPDATE'    TO OUT-PROC-TYPE
              WHEN WS-FUNC-READ
                 MOVE 'READ  '    TO OUT-PROC-TYPE
              WHEN WS-FUNC-DELETE
                 MOVE 'DELETE'    TO OUT-PROC-TYPE
              WHEN OTHER
                 MOVE 'EMPTY '    TO OUT-PROC-TYPE
            END-EVALUATE
            MOVE '-'              TO OUT-SPACE-2
            MOVE WS-SUB-RC        TO OUT-RETURN-CODE
            MOVE '-'              TO OUT-SPACE-3
            MOVE WS-ERROR-EXPLAIN TO OUT-EXPLAIN.
        H275-FILL-PART1-END. EXIT.
      *
        H285-FILL-PART2.
            MOVE '-'                      TO OUT-SPACE-4
            MOVE WS-ALLNAME-BEFORE(1:15)  TO OUT-FNAME-FROM
            MOVE '-'                      TO OUT-SPACE-5
            MOVE WS-SUB-DATA(1:15)        TO OUT-FNAME-TO
            MOVE '-'                      TO OUT-SPACE-6
            MOVE WS-ALLNAME-BEFORE(16:15) TO OUT-LNAME-FROM
            MOVE '-'                      TO OUT-SPACE-7
            MOVE WS-SUB-DATA(16:15)       TO OUT-LNAME-TO.
        H285-FILL-PART2-END. EXIT.
      *
        H290-FILL-AS-READ.
           MOVE '-'                      TO OUT-SPACE-4
           MOVE WS-SUB-DATA(1:15)        TO OUT-FNAME-FROM
           MOVE '-'                      TO OUT-SPACE-5
           MOVE WS-SUB-DATA(16:15)       TO OUT-FNAME-TO
           MOVE '-'                      TO OUT-SPACE-6
           PERFORM GREGORIAN-DATE
           MOVE '-'                      TO OUT-SPACE-7
           MOVE '               '        TO OUT-LNAME-TO
           MOVE ' '                      TO OUT-SPACE-8
           MOVE WS-BUDGET                TO OUT-BUDGET.
        H290-FILL-AS-READ-END. EXIT.
      *
        GREGORIAN-DATE.
      * JCL'de GREGORIAN olan kullanici dogum tarihlerini JULIAN tarihe
      * cevirmistik. OUTPUT dosyamiza bu tarihi GREGORIAN olarak 
      * yazdirmak istedigimiz icin burada donusum islemi 
      * gerceklestirdik.
            INITIALIZE TMP-DATE TMP-INT-JULIAN TMP-GREG
            MOVE WS-DATE TO TMP-DATE
            COMPUTE TMP-INT-JULIAN = FUNCTION INTEGER-OF-DAY(TMP-DATE)
            COMPUTE TMP-GREG = FUNCTION DATE-OF-INTEGER(TMP-INT-JULIAN)
            MOVE TMP-GREG TO OUT-LNAME-FROM.
        GREGORIAN-DATE-END. EXIT.
      *
        READ-RECORD.
            READ INP-FILE.
        END-READ-RECORD. EXIT.
      *
        H999-PROGRAM-EXIT.
            IF GO-SUCCESS
              CLOSE INP-FILE
                    OUT-FILE
              STOP RUN.
        H999-END. EXIT.
