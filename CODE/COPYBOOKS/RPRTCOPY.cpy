      ****************************************************************
      * DMV LICENSE FILE LAYOUT - WRITING OUT APPROVED LICENSES      *
      * FILE: RPRTCOPY.DAT                                           *
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
           