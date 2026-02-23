      ****************************************************************
      * ERR LICENSE FILE LAYOUT - WRITING OUT ERRORED TRANSACTIONS   *
      * FILE: ERRCOPY.DAT                                           * 
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
           