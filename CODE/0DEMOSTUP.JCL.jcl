//SETUPP2 JOB  (SETUP),                                               
//             'SETUP LICENSEB',                                      
//             CLASS=A,                                               
//             MSGCLASS=X,                                            
//             MSGLEVEL=(0,0),                                        
//             NOTIFY=&SYSUID                                         
//********************************************************************
//*                                                                   
//* JOBNAME SETUPP2                                                   
//*                                                                   
//* DESC: SEVERAL STEPS TO ALLOCATE PARTITION DATA SETS               
//*                                                                   
//********************************************************************
//STEP01  EXEC PGM=IEFBR14                                            
//ALLOC1   DD  DSN=PRJ2.DEV.BCOB,                                  
//             DISP=(NEW,CATLG,DELETE),                               
//             UNIT=TSO,                                              
//             SPACE=(CYL,(1,1,15),RLSE),                             
//             DCB=(LRECL=80,RECFM=FB,BLKSIZE=27920,DSORG=PO)         
//SYSPRINT DD  SYSOUT=*                                               
//SYSOUT   DD  SYSOUT=*                                               
//*                                                                  
//STEP02  EXEC PGM=IEFBR14                                            
//ALLOC2   DD  DSN=PRJ2.DEV.COPYBOOK,                              
//             DISP=(NEW,CATLG,DELETE),                               
//             UNIT=TSO,                                              
//             SPACE=(CYL,(1,1,15),RLSE),                             
//             DCB=(LRECL=80,RECFM=FB,BLKSIZE=27920,DSORG=PO)         
//SYSPRINT DD  SYSOUT=*                                               
//SYSOUT   DD  SYSOUT=*                                               
//*                                                                  
//STEP03  EXEC PGM=IEFBR14                                            
//ALLOC3   DD  DSN=PRJ2.DEV.JCL,                                   
//             DISP=(NEW,CATLG,DELETE),                               
//             UNIT=TSO,                                              
//             SPACE=(CYL,(1,1,15),RLSE),                             
//             DCB=(LRECL=80,RECFM=FB,BLKSIZE=27920,DSORG=PO)         
//SYSPRINT DD  SYSOUT=*                                               
//SYSOUT   DD  SYSOUT=*                                               
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
//* INPUT FILES (SEQUENTIAL, 80 BYTE RECORDS)                         
//********************************************************************
//STEP05  EXEC PGM=IEFBR14                                            
//INFILE1  DD  DSN=PRJ2.DEV.INPUT.LICTRNS,                           
//             DISP=(NEW,CATLG,DELETE),                               
//             UNIT=TSO,                                              
//             SPACE=(CYL,(1,1),RLSE),                                
//             DCB=(LRECL=80,RECFM=FB,BLKSIZE=27920,DSORG=PS)         
//SYSPRINT DD  SYSOUT=*                                               
//SYSOUT   DD  SYSOUT=*                                               
//*                                                                  
                                                              
