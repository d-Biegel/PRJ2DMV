//FULLP2 JOB  (SETUP),                                               
//             'FULL PRJ2 STUP',                                      
//             CLASS=A,                                               
//             MSGCLASS=X,                                            
//             MSGLEVEL=(0,0),                                        
//             NOTIFY=&SYSUID                                         
//********************************************************************
//*   -----------------    FULL PRJ2 FILE SETUP    ----------------- 
//********************************************************************
//* DELETE PRIOR VERSIONS OF SOURCE AND OBJECT DATASETS               *
//*********************************************************************
//*                                                          
//IDCAMS  EXEC PGM=IDCAMS,REGION=1024K                       
//SYSPRINT DD  SYSOUT=*                                      
//SYSIN    DD  *                                             
    DELETE PRJ2.DEV.BCOB NONVSAM SCRATCH PURGE               
    DELETE PRJ2.DEV.COPYBOOK NONVSAM SCRATCH PURGE           
    DELETE PRJ2.DEV.JCL NONVSAM SCRATCH PURGE                
    DELETE PRJ2.DEV.LOADLIB NONVSAM SCRATCH PURGE 
    DELETE PRJ2.DEV.INPUT.LICTRNS NONVSAM                                 
    SET MAXCC=0
/*                                                           
//*   
//*********************************************************************
//* CREATE A PDS WITH PROGRAM SOURCE                                  *
//*********************************************************************
//*                                                                    
//STEP01 EXEC PGM=IEBUPDTE,REGION=1024K,PARM=NEW                      
//SYSPRINT DD  SYSOUT=*                                                 
//*                                                                     
//SYSUT2   DD  DSN=PRJ2.DEV.BCOB,DISP=(,CATLG,DELETE),             
//             UNIT=TSO,SPACE=(TRK,(15,,2)),                            
//             DCB=(RECFM=FB,LRECL=80,BLKSIZE=800)                      
//SYSPRINT DD  SYSOUT=*                                                 
//SYSIN    DD  DATA,DLM='><'                                            
./ ADD NAME=LICENSEB,LIST=ALL                      
      **************************************************************
      *
      *  PROGRAM ID LICENSEB
      *  DATE CREATED:  22FEB2026
      *
      *  DEMO PROG SHOWS YOU HOW TO 
      *  INPUT AND OUTPUT FILES FROM COBOL
      *  AND USE THE DATA IN BETWEEN
      *
      *  CHANGE LOG
      *  USER ID     DATE     CHANGE DESCRIPTION
      * ---------   ------    -------------------------------------
      *  DAN BIEG   22FEB2026 CODE PROG
      **************************************************************
       IDENTIFICATION DIVISION.   
      **************************************************************

       PROGRAM-ID. LICENSEB.  

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-370.
       OBJECT-COMPUTER. IBM-370. 

       INPUT-OUTPUT SECTION.

       FILE-CONTROL.                                                    
           SELECT FILE-LIC-TRNS ASSIGN TO UT-S-LICTRNS.  
           SELECT FILE-LIC-OUT ASSIGN TO UT-S-LICOUT.  
           SELECT FILE-ERR-LOG ASSIGN TO UT-S-ERRLOG.  


      **************************************************************
       DATA DIVISION.       
      **************************************************************

       FILE SECTION.                                                    
       FD     FILE-LIC-TRNS                                            
              LABEL RECORDS ARE OMITTED                                 
              BLOCK CONTAINS 0 RECORDS                                  
              DATA RECORD IS FIL-LICENSE-TRNS. 

       01  FIL-LICENSE-TRNS     PIC X(80).  
      * --

       FD     FILE-LIC-OUT        
              LABEL RECORDS ARE OMITTED            
              BLOCK CONTAINS 0 RECORDS               
              DATA RECORD IS FIL-LICENSE-OUT. 
       
       01  FIL-LICENSE-OUT      PIC X(80).
      *--

       FD     FILE-ERR-LOG
              LABEL RECORDS ARE OMITTED
              BLOCK CONTAINS 0 RECORDS
              DATA RECORD IS FIL-ERR-LOG.

       01  FIL-ERR-LOG            PIC X(80).

      **************************************************************
       WORKING-STORAGE SECTION. 
      **************************************************************


      * USE THE COPYBOOK
       01  DMV-LICENSE-REC COPY LICCOPY.
       01  DMV-OUT-REC COPY RPRTCOPY.
       01  DMV-ERR-REC COPY ERRCOPY.


      * CURRENT DATE - FOR DEMO -- ADD 5 TO THIS FOR SENIORS,
      *      8 FOR EVERYONE ELSE
       01  WS-CURRENT-DATE.
            02 WS-CURRENT-YY    PIC 9(2) VALUE 26.
            02 WS-CURRENT-MM    PIC 9(2) VALUE 02.
            02 WS-CURRENT-DD    PIC 9(2) VALUE 18.

      * COMPARE IN 260218 AGAINST EXPIRE DATE TO SEE IF LICENSE
      * IS OVERDUE, THEIR DATE SHOULD BE LARGER IF NOT OVERDUE

       01 WS-RENEWAL-DATES.
            02 WS-RENEW-MM      PIC 9(2) VALUE ZEROS.
            02 FILLER            PIC X VALUE '-'.
            02 WS-RENEW-DD      PIC 9(2) VALUE ZEROS.
            02 FILLER            PIC X VALUE '-'.
            02 WS-RENEW-YY      PIC 9(2) VALUE ZEROS.

       01 WS-RENEWAL-YR-SENIOR PIC 9(2) VALUE 05.
       01 WS-RENEWAL-YR-ADULT  PIC 9(2) VALUE 08.


      * SEPERATORS AND MESSAGES
       01  WS-BREAKPT     PIC X(25) VALUE '-=-=-=-=-=-=-=-=-=-=-=-=-'.
       01  WS-MESSAGE     PIC X(25) VALUE 'BATCH LICENSE PROCESSING!'.
       01  WS-LINE-SPACE  PIC X(25) VALUE SPACES.
       01  WS-ERROR-MSG   PIC X(50) VALUE SPACES.

      * FEES
       01 WS-FEES.
           02  WS-INT-FEE       PIC 9(5)V99 VALUE 0003000.
           02  WS-RENEW-FEE     PIC 9(5)V99 VALUE 0007500.
           02  WS-OVERDUE-FEE   PIC 9(5)V99 VALUE 0021500.
           02  WS-TOTAL-FEE     PIC 9(5)V99 VALUE ZEROS.
           02  WS-TEMP-FEE      PIC 9(5)V99 VALUE ZEROS.

      * FLAGS
       01  WS-VAL.
           02 WS-EOF-LICFILE            PIC X VALUE 'N'.
           02 WS-ERROR-MSG-SET          PIC X VALUE 'N'.
           02 WS-SHORT-RENEWAL          PIC X VALUE 'N'.

      * LICENSE MINIMUM AGE NEEDED TO OBTAIN
       01  WS-LICENSE-AGE.
           02 WS-A-LICENSE-AGE          PIC 9(3) VALUE 021.
           02 WS-B-LICENSE-AGE          PIC 9(3) VALUE 018.
           02 WS-C-LICENSE-AGE          PIC 9(3) VALUE 018.
           02 WS-D-LICENSE-AGE          PIC 9(3) VALUE 018.
           02 WS-M-LICENSE-AGE          PIC 9(3) VALUE 018.

      * AGE LIMIT FOR SHORTER LICENSE RENEWAL (2 YEARS INSTEAD OF 5)
       01  WS-SHORT-RENEWAL-AGE         PIC 9(3) VALUE 070.

      * MAX AGE FOR LICENSE RENEWAL (NO MORE DRIVING AFTER THIS)
       01  WS-MAX-RENEWAL-AGE           PIC 9(3) VALUE 100.

      * LICENSE TYPES
       01  WS-LICENSE-TYPES.
           02 WS-A-LICENSE-TYPE PIC X(26)
                     VALUE 'A COMMERCIAL LARGE COMBO  '.
           02 WS-B-LICENSE-TYPE PIC X(26)
                     VALUE 'B COMMERCIAL BUS          '.
           02 WS-C-LICENSE-TYPE PIC X(26)
                     VALUE 'C COMMERCIAL MULT PASSNGER'.
           02 WS-D-LICENSE-TYPE PIC X(26)
                     VALUE 'D STANDARD DRIVER         '.
           02 WS-M-LICENSE-TYPE PIC X(26)
                     VALUE 'M MOTORCYCLE              '.


      **************************************************************
       PROCEDURE DIVISION.                                    
      **************************************************************
          
           DISPLAY WS-BREAKPT.
           DISPLAY WS-MESSAGE.
           DISPLAY WS-BREAKPT.

      *    OPEN FILES AND READ FIRST RECORD
           PERFORM R1000-OPEN-DATASETS.

      *    START PROCESSING LICENSE FILES
           MOVE SPACES TO FIL-LICENSE-OUT.
           MOVE '== START OF DMV PROCESS REPORT =='
                 TO FIL-LICENSE-OUT.
           WRITE FIL-LICENSE-OUT.

           MOVE SPACES TO FIL-ERR-LOG.
           MOVE '## START OF DMV ERROR LOG ##'
                 TO FIL-ERR-LOG.
           WRITE FIL-ERR-LOG.

      *    START MAIN LOOP
           PERFORM R3000-PROCESS-FILE
              UNTIL WS-EOF-LICFILE = 'Y'.

           MOVE SPACES TO FIL-LICENSE-OUT.
           MOVE '== END OF DMV PROCESS REPORT =='
                 TO FIL-LICENSE-OUT.
           WRITE FIL-LICENSE-OUT.

           MOVE SPACES TO FIL-ERR-LOG.
           MOVE '## END OF DMV ERROR LOG ##'
                 TO FIL-ERR-LOG.
           WRITE FIL-ERR-LOG.

      *    CLOSE OUT FILES
           PERFORM R4000-CLOSE-DATASETS.

           STOP RUN.


      *  ------
        R1000-OPEN-DATASETS.
      *  ------
           OPEN INPUT FILE-LIC-TRNS.
           OPEN OUTPUT FILE-LIC-OUT.
           OPEN OUTPUT FILE-ERR-LOG.

      *  ------
        R2000-READ-LIC-ENTRY.
      *  ------
           READ FILE-LIC-TRNS INTO DMV-LICENSE-REC 
                 AT END MOVE 'Y' TO WS-EOF-LICFILE.

      * ------------------
        R2100-CLEAR-OUT-REC.
      * ------------------
      * CLEAR OUT RECORD FIELDS AFTER EVER RUN
           DISPLAY '> CLEARING OUTPUT + ERROR LOG FIELDS...'.
           MOVE SPACES TO OUT-NAME-VAL.
           MOVE SPACES TO OUT-LICTYPE-VAL.
           MOVE SPACES TO OUT-EYECOL-VAL.
           MOVE SPACES TO OUT-HAIRCOL-VAL.
           MOVE ZEROS  TO OUT-AGE-VAL.
           MOVE SPACES TO OUT-CORLENS-VAL.
           MOVE SPACES TO OUT-CARTP-VAL.
           MOVE SPACES TO OUT-RECIP-VAL.
           MOVE ZEROES TO OUT-EXPDT-YY.
           MOVE ZEROES TO OUT-EXPDT-MM.
           MOVE ZEROES TO OUT-EXPDT-DD.
           MOVE ZEROES TO OUT-FEE-VAL.

           MOVE SPACES TO ERR-NAME-VAL.
           MOVE SPACES TO ERR-LICTYPE-VAL.
           MOVE SPACES TO ERR-REASON-VAL.
 



      *  ------
        R3000-PROCESS-FILE.
      *  ------
      *NEXT STEP: GO DOWN THE LIST OF CRITERIA AND CHECK EACH ONE
      * RECOMMEND WEEDING OUT IF THEY HAD TO IDENTITY DOCS
      * THEN AGE RESTRICTIONS
      * THEN TESTS, PAYMENT 

           PERFORM R2000-READ-LIC-ENTRY.
           PERFORM R2100-CLEAR-OUT-REC.

           MOVE 'N' TO WS-ERROR-MSG-SET.
           MOVE SPACES TO WS-ERROR-MSG.
           MOVE 'N' TO WS-SHORT-RENEWAL.
           MOVE ZEROES TO WS-TOTAL-FEE.
           MOVE ZEROES TO WS-TEMP-FEE.
           MOVE ZEROES TO WS-RENEWAL-DATES.

           IF WS-EOF-LICFILE = 'N'

              DISPLAY WS-LINE-SPACE.
              DISPLAY WS-BREAKPT.
              DISPLAY 'PROCESSING DMV LICENSE FOR:'.
              DISPLAY DMV-NAME.

      *       1 CHECK AGES.
              PERFORM R3100-CHECK-AGE.

      *       2 CHECK TESTS AND FEES
              PERFORM R3200-CHK-TESTS-FEES-INSUR.

      *       3 CALCULATE FEES 
              PERFORM R3300-CALC-FEES.

              DISPLAY 'IS ERROR? ' WS-ERROR-MSG-SET.
             
   *  *  * IF THEY PASS ALL CRITERIA, WRITE OUT OTHERWISE DONT
                 IF WS-ERROR-MSG-SET = 'N'
                       DISPLAY WS-BREAKPT
                       DISPLAY '--- LICENSE APPROVED! ---'
                       DISPLAY WS-BREAKPT

                       MOVE SPACES TO FIL-LICENSE-OUT

                       MOVE DMV-NAME TO OUT-NAME-VAL
                       MOVE DMV-EYE-COLOR TO OUT-EYECOL-VAL
                       MOVE DMV-HAIR-COLOR TO OUT-HAIRCOL-VAL
                       MOVE DMV-AGE TO OUT-AGE-VAL
                       MOVE DMV-CORRECTIVE-LENS TO OUT-CORLENS-VAL
                       MOVE DMV-CAR-TYPE  TO OUT-CARTP-VAL
                       MOVE DMV-RECIPROCITY TO OUT-RECIP-VAL
                       MOVE WS-TOTAL-FEE TO OUT-FEE-VAL

                       MOVE OUT-PT1 TO FIL-LICENSE-OUT
                       WRITE FIL-LICENSE-OUT
                       MOVE SPACES TO FIL-LICENSE-OUT

                       MOVE OUT-PT2 TO FIL-LICENSE-OUT
                       WRITE FIL-LICENSE-OUT
                       MOVE SPACES TO FIL-LICENSE-OUT

                       MOVE OUT-PT3 TO FIL-LICENSE-OUT
                       WRITE FIL-LICENSE-OUT
                       MOVE SPACES TO FIL-LICENSE-OUT

                       MOVE OUT-PT4 TO FIL-LICENSE-OUT
                       WRITE FIL-LICENSE-OUT
                       MOVE SPACES TO FIL-LICENSE-OUT


      *     *     * SEPERATOR FOR NEXT RECORD
                       DISPLAY WS-BREAKPT
                 .

                 IF WS-ERROR-MSG-SET = 'Y'
                       DISPLAY '--- ERROR! REQUEST DENIED ---'
                       DISPLAY WS-LINE-SPACE
                       DISPLAY ' USER NAME: ' DMV-NAME
                       DISPLAY WS-LINE-SPACE
                       DISPLAY ' LICENSE TYPE: ' DMV-LICENSE-TYPE
                       DISPLAY WS-LINE-SPACE
                       DISPLAY ' REASON FOR DENIAL: ' WS-ERROR-MSG
                       DISPLAY WS-LINE-SPACE
                       DISPLAY '--- --- --- '

                       MOVE SPACES TO FIL-ERR-LOG
                       MOVE DMV-NAME TO ERR-NAME-VAL
                       MOVE WS-ERROR-MSG TO ERR-REASON-VAL

                       MOVE ERR-PT1 TO FIL-ERR-LOG
                       WRITE FIL-ERR-LOG
                       MOVE SPACES TO FIL-ERR-LOG

                       MOVE ERR-PT2 TO FIL-ERR-LOG
                       WRITE FIL-ERR-LOG
                       MOVE SPACES TO FIL-ERR-LOG

                       MOVE ERR-PT3 TO FIL-ERR-LOG
                       WRITE FIL-ERR-LOG
                       MOVE SPACES TO FIL-ERR-LOG


                       DISPLAY WS-BREAKPT
                  .
       .

       .


      * ------------------
        R3100-CHECK-AGE.
      * ------------------
           DISPLAY '> CHECKING AGE CRITERIA...'.
           DISPLAY '   STRT R3100 ERROR SET? ' WS-ERROR-MSG-SET.
           DISPLAY '   STRT R3100 ERROR MSG: ' WS-ERROR-MSG.
           DISPLAY WS-LINE-SPACE.

           IF DMV-AGE > WS-MAX-RENEWAL-AGE
              MOVE '-NA-' TO ERR-LICTYPE-VAL
              MOVE 'ERROR: TOO OLD FOR LICENSE RENEWAL'
                    TO WS-ERROR-MSG
              MOVE 'Y' TO WS-ERROR-MSG-SET
              DISPLAY WS-ERROR-MSG
           .

           IF DMV-AGE < 018 AND WS-ERROR-MSG-SET = 'N'
              MOVE '-NA-' TO ERR-LICTYPE-VAL
              MOVE 'ERROR: TOO YOUNG FOR ANY LICENSE'
                    TO WS-ERROR-MSG
              MOVE 'Y' TO WS-ERROR-MSG-SET
              DISPLAY WS-ERROR-MSG
           .

           IF WS-ERROR-MSG-SET = 'N'
              IF DMV-LICENSE-TYPE = 'A'
                 DISPLAY ' TYPE A'
                 MOVE WS-A-LICENSE-TYPE TO OUT-LICTYPE-VAL
                 MOVE WS-A-LICENSE-TYPE TO ERR-LICTYPE-VAL
                 IF DMV-AGE < WS-A-LICENSE-AGE
                    MOVE 'ERROR: TOO YOUNG FOR TYPE A LICENSE'
                          TO WS-ERROR-MSG
                    MOVE 'Y' TO WS-ERROR-MSG-SET
                    DISPLAY WS-ERROR-MSG
           .

           IF WS-ERROR-MSG-SET = 'N'
              IF DMV-LICENSE-TYPE = 'B'
                 DISPLAY ' TYPE B'
                 MOVE WS-B-LICENSE-TYPE TO OUT-LICTYPE-VAL
                 MOVE WS-B-LICENSE-TYPE TO ERR-LICTYPE-VAL
                 IF DMV-AGE < WS-B-LICENSE-AGE
                    MOVE 'ERROR: TOO YOUNG FOR TYPE B LICENSE'
                          TO WS-ERROR-MSG
                    MOVE 'Y' TO WS-ERROR-MSG-SET
                    DISPLAY WS-ERROR-MSG
           .

           IF WS-ERROR-MSG-SET = 'N'
              IF DMV-LICENSE-TYPE = 'C'
                 DISPLAY ' TYPE C'
                 MOVE WS-C-LICENSE-TYPE TO OUT-LICTYPE-VAL
                 MOVE WS-C-LICENSE-TYPE TO ERR-LICTYPE-VAL
                 IF DMV-AGE < WS-C-LICENSE-AGE
                    MOVE 'ERROR: TOO YOUNG FOR TYPE C LICENSE'
                          TO WS-ERROR-MSG
                    MOVE 'Y' TO WS-ERROR-MSG-SET
                    DISPLAY WS-ERROR-MSG
           .

           IF WS-ERROR-MSG-SET = 'N'
              IF DMV-LICENSE-TYPE = 'D'
                 DISPLAY ' TYPE D'
                 MOVE WS-D-LICENSE-TYPE TO OUT-LICTYPE-VAL
                 MOVE WS-D-LICENSE-TYPE TO ERR-LICTYPE-VAL
                 IF DMV-AGE < WS-D-LICENSE-AGE
                    MOVE 'ERROR: TOO YOUNG FOR TYPE D LICENSE'
                          TO WS-ERROR-MSG
                    MOVE 'Y' TO WS-ERROR-MSG-SET
                    DISPLAY WS-ERROR-MSG
           .

           IF WS-ERROR-MSG-SET = 'N'
              IF DMV-LICENSE-TYPE = 'M'
                 DISPLAY ' TYPE M'
                 MOVE WS-M-LICENSE-TYPE TO OUT-LICTYPE-VAL
                 MOVE WS-M-LICENSE-TYPE TO ERR-LICTYPE-VAL
                 IF DMV-AGE < WS-M-LICENSE-AGE
                    MOVE 'ERROR: TOO YOUNG FOR TYPE M LICENSE'
                          TO WS-ERROR-MSG
                    MOVE 'Y' TO WS-ERROR-MSG-SET
                    DISPLAY WS-ERROR-MSG
           .

           DISPLAY ' CHECK SHORT RENEWAL (5 YEARS INSTEAD OF 8)'.
           IF DMV-AGE > WS-SHORT-RENEWAL-AGE
              MOVE 'Y' TO WS-SHORT-RENEWAL
              DISPLAY 'SHORT RENEWAL, 5 YEAR RENEWAL INSTEAD OF 8'
              COMPUTE WS-RENEW-YY = WS-CURRENT-YY
                      + WS-RENEWAL-YR-SENIOR
              MOVE WS-CURRENT-MM TO WS-RENEW-MM
              MOVE WS-CURRENT-DD TO WS-RENEW-DD
           ELSE
              DISPLAY 'NOT A SHORT RENEWAL, 8 YEAR RENEWAL'
              COMPUTE WS-RENEW-YY = WS-CURRENT-YY
                      + WS-RENEWAL-YR-ADULT
              MOVE WS-CURRENT-MM TO WS-RENEW-MM
              MOVE WS-CURRENT-DD TO WS-RENEW-DD
           .

           MOVE WS-RENEW-DD TO OUT-EXPDT-DD.
           MOVE WS-RENEW-MM TO OUT-EXPDT-MM.
           MOVE WS-RENEW-YY TO OUT-EXPDT-YY.

           DISPLAY '   END R3100 ERROR SET? ' WS-ERROR-MSG-SET.
           DISPLAY '   END R3100 ERROR MSG: ' WS-ERROR-MSG.
           DISPLAY '  RENEWAL DATE CALCULATED AS: ' WS-RENEWAL-DATES.
           DISPLAY WS-LINE-SPACE.


      * ------------------
        R3200-CHK-TESTS-FEES-INSUR.
      * ------------------
           DISPLAY '> CHECKING TESTS, FEES, INSURANCE...'.
           DISPLAY '   STRT R3200 ERROR SET? ' WS-ERROR-MSG-SET.
           DISPLAY '   STRT R3200 ERROR MSG: ' WS-ERROR-MSG.
           DISPLAY WS-LINE-SPACE.

           IF WS-ERROR-MSG-SET = 'N'
              IF DMV-ROAD-TEST NOT = 'Y'
                 MOVE 'ERROR: DID NOT PASS ROAD TEST'
                       TO WS-ERROR-MSG
                 MOVE 'Y' TO WS-ERROR-MSG-SET
           .

           IF WS-ERROR-MSG-SET = 'N'
              IF DMV-WRITTEN-TEST NOT = 'Y'
                 MOVE 'ERROR: DID NOT PASS WRITTEN TEST'
                       TO WS-ERROR-MSG
                 MOVE 'Y' TO WS-ERROR-MSG-SET
           .

           IF WS-ERROR-MSG-SET = 'N'
              IF DMV-PAID-FEE NOT = 'Y'
                 MOVE 'ERROR: DID NOT PAY REQUIRED FEE'
                       TO WS-ERROR-MSG
                 MOVE 'Y' TO WS-ERROR-MSG-SET
           .

           IF WS-ERROR-MSG-SET = 'N'
              IF DMV-INSURANCE NOT = 'Y'
                 MOVE 'ERROR: DID NOT PROVIDE PROOF OF INSURANCE'
                       TO WS-ERROR-MSG
                 MOVE 'Y' TO WS-ERROR-MSG-SET
           .

           IF WS-ERROR-MSG-SET = 'N'
              IF DMV-IDENTITY-DOC NOT = 'Y'
                 MOVE 'ERROR: DID NOT PROVIDE IDENTITY DOC'
                       TO WS-ERROR-MSG
                 MOVE 'Y' TO WS-ERROR-MSG-SET
           .

           DISPLAY '   END R3200 ERROR SET? ' WS-ERROR-MSG-SET.
           DISPLAY '   END R3200 ERROR MSG: ' WS-ERROR-MSG.
           DISPLAY WS-LINE-SPACE.

      * ------------------
        R3300-CALC-FEES.
      * ------------------
           DISPLAY '> CALCULATING FEES OWED...'.
           MOVE ZEROS TO WS-TOTAL-FEE.
           MOVE ZEROS TO WS-TEMP-FEE.

           IF DMV-EXPIRE-DATE < WS-CURRENT-DATE
              DISPLAY 'LICENSE IS OVERDUE, ADDING OVERDUE FEE'
              COMPUTE WS-TEMP-FEE = WS-INT-FEE + WS-OVERDUE-FEE
           ELSE
              DISPLAY 'LICENSE IS NOT OVERDUE, NO EXTRA FEE'
              COMPUTE WS-TEMP-FEE = WS-INT-FEE
           .

           IF DMV-RENEWAL = 'Y'
              DISPLAY 'THIS WAS A RENEWAL, HIGHER FEE'
              COMPUTE WS-TOTAL-FEE = WS-TEMP-FEE + WS-RENEW-FEE
           ELSE
              DISPLAY 'THIS WAS NOT A RENEWAL, JUST INITIAL FEE'
              COMPUTE WS-TOTAL-FEE = WS-TEMP-FEE
           .


      * ------------------
        R4000-CLOSE-DATASETS.
      * ------------------
           CLOSE FILE-LIC-TRNS.
           CLOSE FILE-LIC-OUT.
           CLOSE FILE-ERR-LOG.
./ ENDUP 
><       
/*  
//*********************************************************************
//* CREATE A PDS WITH COPYBOOKS                                       *
//*********************************************************************
//*                                                                    
//STEP02 EXEC PGM=IEBUPDTE,REGION=1024K,PARM=NEW                     
//SYSPRINT DD  SYSOUT=*                                                
//*                                                                    
//SYSUT2   DD  DSN=PRJ2.DEV.COPYBOOK,DISP=(,CATLG,DELETE),            
//             UNIT=TSO,SPACE=(TRK,(15,,2)),                           
//             DCB=(RECFM=FB,LRECL=80,BLKSIZE=800)                     
//SYSPRINT DD  SYSOUT=*                                                
//SYSIN    DD  DATA,DLM='><'                                           
./ ADD NAME=ERRCOPY,LIST=ALL                                           
      ****************************************************************
      * ERR LICENSE FILE LAYOUT - WRITING OUT ERRORED TRANSACTIONS   *
      * FILE: ERRCOPY.CPY                                            * 
      * RECORD LENGTH: 80 BYTES                                      *
      ****************************************************************
       01 ERROR-LICS.
           02 ERR-PT1.
              03  ERR-NAME-LABEL      PIC X(11) VALUE 'USER NAME:'.
              03  FILLER              PIC X.
              03  ERR-NAME-VAL        PIC X(19) VALUE 'PLACEHOLDER'.
              03  FILLER              PIC XX.
              03  ERR-LICTYPE-LABEL   PIC X(14) VALUE 'LICENSE TYPE:'.
              03  FILLER              PIC X.
              03  ERR-LICTYPE-VAL     PIC X(26) VALUE 'PLACEHOLDER'.
              03  FILLER              PIC X(6).
           02 ERR-PT2.
              03  FILLER              PIC XX.
              03  ERR-REASON-LABEL    PIC X(19) 
                    VALUE 'REASON FOR DENIAL:'.
              03  FILLER              PIC X.
              03  ERR-REASON-VAL      PIC X(58) VALUE 'PLACEHOLDER'.
           02 ERR-PT3.
              03  ERR-DIVIDER PIC X(78) VALUE ALL '~'. 
              03  FILLER   PIC X(2) VALUE SPACES.
./ ADD NAME=LICCOPY,LIST=ALL 
      *****************************************************************
      * DMV LICENSE FILE LAYOUT - READING AND PROCESSING TRANSACTIONS *
      * FILE: LICCOPY.CPY                                             *
      * RECORD LENGTH: 80 BYTES                                       *
      *****************************************************************
       01 DMV-RECORD.
           05  DMV-NAME                PIC X(19).
           05  FILLER                  PIC X.
           05  DMV-EYE-COLOR           PIC X(2).
           05  FILLER                  PIC X.
           05  DMV-HAIR-COLOR          PIC X(2).
           05  FILLER                  PIC X.
           05  DMV-AGE                 PIC 9(3).
           05  FILLER                  PIC X.
           05  DMV-CORRECTIVE-LENS     PIC X.
           05  FILLER                  PIC X.
           05  DMV-LICENSE-TYPE        PIC X.
           05  FILLER                  PIC X.
           05  DMV-ROAD-TEST           PIC X.
           05  FILLER                  PIC X.
           05  DMV-WRITTEN-TEST        PIC X.
           05  FILLER                  PIC X.
           05  DMV-RENEWAL             PIC X.
           05  FILLER                  PIC X.
           05  DMV-EXPIRE-DATE.
              10 DMV-EXPIRE-YY         PIC 9(2).
              10 FILLER                PIC X.
              10 DMV-EXPIRE-MM         PIC 9(2).
              10 FILLER                PIC X.
              10 DMV-EXPIRE-DD         PIC 9(2).
           05  FILLER                  PIC X.
           05  DMV-CAR-TYPE            PIC X(6).
           05  FILLER                  PIC X.
           05  DMV-RECIPROCITY         PIC X.
           05  FILLER                  PIC X.
           05  DMV-INSURANCE           PIC X.
           05  FILLER                  PIC X.
           05  DMV-IDENTITY-DOC        PIC X.
           05  FILLER                  PIC X.
           05  DMV-PAID-FEE            PIC X.
           05  FILLER                  PIC X(17).
./ ADD NAME=RPRTCOPY,LIST=ALL
      ****************************************************************
      * DMV LICENSE FILE LAYOUT - WRITING OUT APPROVED LICENSES      *
      * FILE: RPRTCOPY.CPY                                           *
      * RECORD LENGTH: 80 BYTES                                      *
      ****************************************************************
       01 APPROVED-LICS.
           02 OUT-PT1.
              03  OUT-NAME-LABEL      PIC X(11) VALUE 'USER NAME:'.
              03  FILLER              PIC X.
              03  OUT-NAME-VAL        PIC X(19) VALUE 'PLACEHOLDER'.
              03  FILLER              PIC XX.
              03  OUT-LICTYPE-LABEL   PIC X(14) VALUE 'LICENSE TYPE:'.
              03  FILLER              PIC X.
              03  OUT-LICTYPE-VAL     PIC X(26) VALUE 'PLACEHOLDER'.
              03  FILLER              PIC X(6).
           02 OUT-PT2.
              03  FILLER              PIC XX.
              03  OUT-EYECOL-LABEL    PIC X(11) VALUE 'EYE COLOR:'.
              03  FILLER              PIC X.
              03  OUT-EYECOL-VAL      PIC X(2) VALUE 'PH'.
              03  FILLER              PIC XX.
              03  OUT-HAIRCOL-LABEL   PIC X(12) VALUE 'HAIR COLOR:'.
              03  FILLER              PIC X.
              03  OUT-HAIRCOL-VAL     PIC X(2) VALUE 'PH'.
              03  FILLER              PIC XX.
              03  OUT-AGE-LABEL       PIC X(5) VALUE 'AGE:'.
              03  FILLER              PIC X.
              03  OUT-AGE-VAL         PIC 9(3) VALUE ZEROS.
              03  FILLER              PIC XX.
              03  OUT-CORLENS-LABEL   PIC X(19) 
                    VALUE 'CORRECTIVE LENSES:'.
              03  FILLER              PIC X.
              03  OUT-CORLENS-VAL     PIC X VALUE 'P'.
              03  FILLER              PIC XX.
              03  OUT-FEE-LABEL       PIC X(4) VALUE 'FEE:'.
              03  FILLER              PIC X.
              03  OUT-FEE-VAL         PIC 9(5)V99 VALUE ZEROS.
      *       03  FILLER              PIC X(13).
           02 OUT-PT3.
              03  FILLER              PIC XX.
              03  OUT-CARTP-LABEL     PIC X(10) VALUE 'CAR TYPE:'.
              03  FILLER              PIC X.
              03  OUT-CARTP-VAL       PIC X(6) VALUE 'PLACE'.
              03  FILLER              PIC XX.
              03  OUT-RECIP-LABEL     PIC X(21) 
                    VALUE 'LICENSE RECIPROCITY:'.
              03  FILLER              PIC X.
              03  OUT-RECIP-VAL       PIC X VALUE 'P'.
              03  FILLER              PIC XX.
              03  OUT-EXPDT-LABEL     PIC X(17) 
                    VALUE 'EXPIRATION DATE:'.
              03  FILLER              PIC X.
              03  OUT-EXPDT-VAL.
                 04 OUT-EXPDT-YY       PIC 9(2).
                 04 FILLER            PIC X VALUE '-'. 
                 04 OUT-EXPDT-MM       PIC 9(2).
                 04 FILLER            PIC X VALUE '-'.
                 04 OUT-EXPDT-DD       PIC 9(2).
              03  FILLER              PIC X(6).
           02 OUT-PT4.
              03  OUT-DIVIDER PIC X(78) VALUE ALL '*'. 
              03  FILLER   PIC X(2) VALUE SPACES.
./ ENDUP 
><       
/*  
//*********************************************************************
//* CREATE A PDS WITH JCL                                             *
//*********************************************************************
//*                                                                    
//STEP03 EXEC PGM=IEBUPDTE,REGION=1024K,PARM=NEW                     
//SYSPRINT DD  SYSOUT=*                                                
//*                                                                    
//SYSUT2   DD  DSN=PRJ2.DEV.JCL,DISP=(,CATLG,DELETE),            
//             UNIT=TSO,SPACE=(TRK,(15,,2)),                           
//             DCB=(RECFM=FB,LRECL=80,BLKSIZE=800)                     
//SYSPRINT DD  SYSOUT=*                                                
//SYSIN    DD  DATA,DLM='><'                                           
./ ADD NAME=COMPILE,LIST=ALL  
//CMPLIC1 JOB (001),'COMPILE LICENSEB',                            
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),                     
//             NOTIFY=&SYSUID                                   
//********************************************************************
//* STEP 1: COMPILE THE COBOL PROGRAM                                 
//********************************************************************
//COBSTEP EXEC PGM=IKFCBL00,REGION=4096K,                             
//             PARM='LIB,LOAD,LIST,NOSEQ,SIZE=2048K,BUF=1024K'        
//STEPLIB  DD DSN=SYS1.COBLIB,DISP=SHR                                
//SYSLIB   DD DSN=PRJ2.DEV.COPYBOOK,DISP=SHR                         
//SYSIN    DD DSN=PRJ2.DEV.BCOB(LICENSEB),DISP=SHR                 
//SYSPRINT DD SYSOUT=*                                                
//SYSPUNCH DD SYSOUT=B                                                
//SYSLIN   DD DSN=&&LOADSET,UNIT=SYSDA,DISP=(MOD,PASS),               
//            SPACE=(80,(500,100))                                    
//SYSUT1   DD UNIT=SYSDA,SPACE=(460,(700,100))                        
//SYSUT2   DD UNIT=SYSDA,SPACE=(460,(700,100))                        
//SYSUT3   DD UNIT=SYSDA,SPACE=(460,(700,100))                        
//SYSUT4   DD UNIT=SYSDA,SPACE=(460,(700,100))                        
//********************************************************************
//* STEP 2: LINK-EDIT THE OBJECT CODE                                 
//********************************************************************
//LKED    EXEC PGM=IEWL,REGION=256K,PARM='LIST,XREF,LET',             
//             COND=(5,LT,COBSTEP)                                    
//SYSLIN   DD DSN=&&LOADSET,DISP=(OLD,DELETE)                         
//         DD DDNAME=SYSIN                                            
//SYSLMOD  DD DSN=PRJ2.DEV.LOADLIB(LICENSEB),DISP=SHR              
//SYSUT1   DD UNIT=SYSDA,SPACE=(1024,(50,20))                      
//SYSPRINT DD SYSOUT=*                                                
//SYSLIB   DD DSN=SYS1.COBLIB,DISP=SHR                                
//SYSIN    DD DUMMY                                                   
//                                                                    
./ ADD NAME=RUN,LIST=ALL  
//RUNLIC1 JOB  'RUN COMBINE LIC',          
//        CLASS=A,
//        MSGCLASS=X,
//        MSGLEVEL=(1,1),                            
//        NOTIFY=&SYSUID               
//********************************************************************
//* DELETE OLD OUTPUT IF EXISTS (DO THIS FIRST)
//********************************************************************
//CLEANUP1 EXEC PGM=IEFBR14 
//LICOUT   DD DSN=PRJ2.DEV.OUTPUT.DMVOUTPT,DISP=(MOD,DELETE,DELETE),
//         SPACE=(TRK,(0,0)),UNIT=SYSDA
//* 
//CLEANUP2 EXEC PGM=IEFBR14 
//LICOUT   DD DSN=PRJ2.DEV.OUTPUT.ERRORLOG,DISP=(MOD,DELETE,DELETE),
//         SPACE=(TRK,(0,0)),UNIT=SYSDA
//* 
//CLEANUP3 EXEC PGM=IEFBR14
//LICOUT   DD DSN=PRJ2.DEV.OUTPUT.COMBINE3,
//         DISP=(MOD,DELETE,DELETE),
//         SPACE=(TRK,(0,0)),UNIT=SYSDA
//********************************************************************
//* STEP 1: RUN LICENSEB BINARY
//* INPUT FROM PRJ2.DEV.INPUT   
//* OUTPUT RESULTS TO DMVOUTPT AND ERRORLOG                     
//********************************************************************
//STEP1    EXEC PGM=LICENSEB             
//STEPLIB  DD DSN=PRJ2.DEV.LOADLIB,DISP=SHR 
//         DD DSN=SYS1.COBLIB,DISP=SHR
//LICTRNS  DD DSN=PRJ2.DEV.INPUT.LICTRNS,DISP=SHR   
//* 
//LICOUT   DD DSN=PRJ2.DEV.OUTPUT.DMVOUTPT,DISP=(NEW,CATLG,DELETE),
//         SPACE=(TRK,(1,1)),UNIT=SYSDA,
//         DCB=(RECFM=FB,LRECL=80,BLKSIZE=800) 
//* 
//ERRLOG   DD DSN=PRJ2.DEV.OUTPUT.ERRORLOG,DISP=(NEW,CATLG,DELETE),
//         SPACE=(TRK,(1,1)),UNIT=SYSDA,
//         DCB=(RECFM=FB,LRECL=80,BLKSIZE=800) 
//* 
//SYSOUT   DD SYSOUT=*      
//SYSUDUMP DD SYSOUT=*
//********************************************************************
//* STEP 2: COMBINE DMVOUTPT AND ERRORLOG INTO COMBINE3
//* IEBGENER READS CONCATENATED SYSUT1 AND WRITES TO SYSUT2
//********************************************************************
//STEP2    EXEC PGM=IEBGENER,COND=(0,NE,STEP1)
//SYSUT1   DD DSN=PRJ2.DEV.OUTPUT.DMVOUTPT,DISP=SHR
//         DD DSN=PRJ2.DEV.OUTPUT.ERRORLOG,DISP=SHR
//SYSUT2   DD DSN=PRJ2.DEV.OUTPUT.COMBINE3,DISP=(NEW,CATLG,DELETE),
//         SPACE=(TRK,(2,1)),UNIT=SYSDA,
//         DCB=(RECFM=FB,LRECL=80,BLKSIZE=800)
//SYSIN    DD DUMMY
//SYSPRINT DD SYSOUT=*
//
./ ENDUP 
><       
/*  
//*                                                                  
//********************************************************************
//* SETUP YOUR LOADLIB NOTE RECFM=U                                   
//********************************************************************
//STEP04  EXEC PGM=IEFBR14                                            
//ALLOC4   DD  DSN=PRJ2.DEV.LOADLIB,                               
//             DISP=(NEW,CATLG,DELETE),                               
//             UNIT=TSO,                                              
//             SPACE=(CYL,(5,5,15),RLSE),                             
//             DCB=(LRECL=0,RECFM=U,BLKSIZE=6144,DSORG=PO)            
//SYSPRINT DD  SYSOUT=*                                               
//SYSOUT   DD  SYSOUT=*                                               
//*                                                                  
//********************************************************************
//* CREATE INPUT FILES (SEQUENTIAL, 80 BYTE RECORDS)                         
//********************************************************************
//* LICTRNS
//STEP05 EXEC PGM=IEBGENER,REGION=128K                      
//SYSIN    DD  DUMMY                                           
//SYSPRINT DD  SYSOUT=*                                        
//*                                                            
//SYSUT2   DD  DSN=PRJ2.DEV.INPUT.LICTRNS,DISP=(,CATLG,DELETE),  
//             UNIT=TSO,SPACE=(CYL,(1,1),RLSE),          
//             DCB=(LRECL=80,RECFM=FB,BLKSIZE=27920,DSORG=PS)     
//SYSUT1   DD  *                                                  
BRIAN SMITH         bl rd 018 Y D Y Y N 00-00-00 sedan  N Y Y N                 
JOE MCCANDLESS      br bo 049 N D Y Y Y 01-23-26 truck  N Y Y Y                 
ALICE JOHNSON       gr bl 022 Y C Y Y N 00-00-00 sedan  N Y Y N                 
MICHAEL TURNER      br br 034 N B Y Y Y 05-14-27 suv    N Y Y N                 
KAREN LOPEZ         bu rd 061 Y D Y Y Y 11-02-25 sedan  N Y Y N                 
ROBERT HALL         bl br 082 N A Y Y Y 09-30-24 truck  N Y Y Y                 
LINDA ALLEN         gr rd 029 Y M Y Y N 00-00-00 cYcle  N Y Y Y                 
DAVID YOUNG         br bo 038 N D Y Y Y 03-18-27 sedan  N Y Y Y                 
PATRICIA KING       bu bl 041 Y B Y Y Y 12-11-25 suv    N Y Y Y                 
CHARLES WRIGHT      br br 067 N D Y Y Y 02-22-24 truck  N Y Y Y                 
BARBARA SCOTT       gr rd 055 Y C Y Y Y 08-08-26 sedan  Y Y Y N                 
DANIEL GREEN        bl bo 024 N D Y Y N 00-00-00 sedan  N Y Y N                 
SUSAN ADAMS         br bl 033 Y D Y Y Y 06-15-27 suv    N Y Y Y                 
MARK NELSON         gr br 019 N M Y Y N 00-00-00 cYcle  N Y Y Y                 
NANCY BAKER         bu rd 047 Y C Y Y Y 04-09-26 sedan  N Y Y Y                 
STEVEN CARTER       br bo 058 N B Y Y Y 10-17-25 truck  N Y Y Y                 
BETTY MITCHELL      gr bl 031 Y D Y Y N 00-00-00 sedan  N Y Y Y                 
PAUL PEREZ          br rd 044 N A Y Y Y 01-05-26 suv    N Y Y Y                 
JESSICA ROBERTS     bl bo 026 Y C Y Y N 00-00-00 sedan  N Y Y Y                 
KEVIN PHILLIPS      gr br 062 N D Y Y Y 09-09-24 truck  Y Y Y Y                 
DON00 CAMPBELL      bu bl 036 Y B Y Y Y 05-12-26 suv    N Y Y Y                 
JASON PARKER        br rd 028 N D Y Y N 00-00-00 sedan  N Y Y Y                 
SARAH EVANS         gr bo 039 Y C Y Y Y 07-21-27 sedan  N Y Y Y                 
GARY EDWARDS        bl br 053 N A Y Y Y 03-03-25 truck  N Y Y Y                 
KAREN COLLINS       bu rd 021 Y D Y Y N 00-00-00 sedan  N Y Y Y                 
LARRY STEWART       br bo 048 N B Y Y Y 11-29-26 suv    N Y Y Y                 
AMY SANCHEZ         gr bl 035 Y C Y Y Y 08-16-25 sedan  Y Y Y Y                 
FRANK MORRIS        br br 060 N D Y Y Y 12-01-24 truck  N Y Y Y                 
MICHELLE ROGERS     bu rd 027 Y M Y Y N 00-00-00 cYcle  N Y Y Y                 
SCOTT REED          gr bo 046 N D Y Y Y 02-14-26 suv    N Y Y Y                 
LAURA COOK          br bl 032 Y C Y Y Y 06-06-27 sedan  N Y Y Y                 
ERIC MORGAN         bl br 054 N B Y Y Y 09-19-24 truck  N Y Y N                 
ANGELA BELL         bu rd 023 Y D Y Y N 00-00-00 sedan  N Y Y N                 
JEFF MURPHY         gr bo 040 N A Y Y Y 10-10-25 suv    N Y Y N                 
REBECCA BAILEY      br bl 037 Y C Y Y Y 03-27-26 sedan  N Y Y N                 
PATRICK RIVERA      bl rd 051 N D Y Y Y 07-07-24 truck  N Y Y N                 
STEPHANIE COOPER    gr br 030 Y B Y Y Y 05-05-27 suv    N Y Y N                 
BRANDON RICHARDSON  br bo 042 N D Y Y Y 01-31-26 sedan  N Y Y N                 
SHARON COX          bu bl 059 Y C Y Y Y 04-22-25 sedan  Y Y Y N                 
GREGORY HOWARD      gr rd 025 N M Y Y N 00-00-00 cYcle  N Y Y N                 
DEBORAH WARD        br bo 043 Y D Y Y Y 08-28-26 suv    N Y Y N                 
JUSTIN TORRES       bl br 020 N D Y Y N 00-00-00 sedan  N Y Y Y                 
CYNTHIA PETERSON    bu rd 056 Y B Y Y Y 11-11-24 truck  N Y Y Y                 
AARON GRAY          gr bo 034 N C Y Y Y 06-30-27 sedan  N Y Y Y                 
MELISSA RAMIREZ     br bl 029 Y D Y Y N 00-00-00 sedan  N Y Y Y                 
NATHAN JAMES        bl rd 063 N A Y Y Y 09-15-24 truck  Y Y Y Y                 
OLIVIA WATSON       bu bo 018 Y D Y Y N 00-00-00 sedan  N Y Y Y                 
HENRY BROOKS        gr br 050 N B Y Y Y 02-02-25 suv    N Y Y Y                 
/*                                                       
//SYSOUT   DD  SYSOUT=*                            