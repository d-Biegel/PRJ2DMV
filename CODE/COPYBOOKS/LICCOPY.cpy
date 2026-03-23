      *****************************************************************
      * DMV LICENSE FILE LAYOUT - READING AND PROCESSING TRANSACTIONS *
      * FILE: LICCOPY.DAT                                             *
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

