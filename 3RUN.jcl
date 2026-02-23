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