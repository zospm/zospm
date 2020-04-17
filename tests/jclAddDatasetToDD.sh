#!/bin/sh
#
# Basic tests to ensure adding datasets to a DD in JCL works
#

. zbrewsetenv

jcl="//STEP1 EXEC PGM=IEFBR14
//MYDD DD DSN=MY.TEST.DATASET,DISP=SHR
//     DD DSN=ANOTHER.TEST.DATASET,DISP=SHR
//*
//     DD DISP=SHR,THIRD.DATASET
//*
//SYSUT1 DD SYSOUT=*
//*
//STEP2 EXEC PGM=FREELOAD,PARM='SOME PARM'
//STDOUT DD DISP=OLD,MY.OUTPUT
//SYSIN DD
 Here
 is 
 Text   
/*
//STEP3 EXEC PGM=LAST
//STDOUT DD SYSOUT=*
//MYOUT  DD DSN=FRED.JACK,DISP=SHR
//SYSIN  DD DSN=MY.MAGIC.FILE,DISP=SHR"

jclMyDDAdd="//STEP1 EXEC PGM=IEFBR14
//MYDD DD DSN=ZBREW.MYDD.DATASET,DISP=SHR
// DD DSN=MY.TEST.DATASET,DISP=SHR
//     DD DSN=ANOTHER.TEST.DATASET,DISP=SHR
//*
//     DD DISP=SHR,THIRD.DATASET
//*
//SYSUT1 DD SYSOUT=*
//*
//STEP2 EXEC PGM=FREELOAD,PARM='SOME PARM'
//STDOUT DD DISP=OLD,MY.OUTPUT
//SYSIN DD
 Here
 is 
 Text   
/*
//STEP3 EXEC PGM=LAST
//STDOUT DD SYSOUT=*
//MYOUT  DD DSN=FRED.JACK,DISP=SHR
//SYSIN  DD DSN=MY.MAGIC.FILE,DISP=SHR"

jclSYSINAdd="//STEP1 EXEC PGM=IEFBR14
//MYDD DD DSN=MY.TEST.DATASET,DISP=SHR
//     DD DSN=ANOTHER.TEST.DATASET,DISP=SHR
//*
//     DD DISP=SHR,THIRD.DATASET
//*
//SYSUT1 DD SYSOUT=*
//*
//STEP2 EXEC PGM=FREELOAD,PARM='SOME PARM'
//STDOUT DD DISP=OLD,MY.OUTPUT
//SYSIN DD
 Here
 is 
 Text   
/*
//STEP3 EXEC PGM=LAST
//STDOUT DD SYSOUT=*
//MYOUT  DD DSN=FRED.JACK,DISP=SHR
//SYSIN DD DSN=ZBREW.MYSYSIN.DATASET,DISP=SHR
//  DD DSN=MY.MAGIC.FILE,DISP=SHR"

jclStdoutAdd="//STEP1 EXEC PGM=IEFBR14
//MYDD DD DSN=MY.TEST.DATASET,DISP=SHR
//     DD DSN=ANOTHER.TEST.DATASET,DISP=SHR
//*
//     DD DISP=SHR,THIRD.DATASET
//*
//SYSUT1 DD SYSOUT=*
//*
//STEP2 EXEC PGM=FREELOAD,PARM='SOME PARM'
//STDOUT DD DSN=ZBREW.MYSTDOUT.DATASET,DISP=SHR
// DD DISP=OLD,MY.OUTPUT
//SYSIN DD
 Here
 is 
 Text   
/*
//STEP3 EXEC PGM=LAST
//STDOUT DD SYSOUT=*
//MYOUT  DD DSN=FRED.JACK,DISP=SHR
//SYSIN  DD DSN=MY.MAGIC.FILE,DISP=SHR"

actual=`jclAddDatasetToDD "STEP1" "MYDD" "ZBREW.MYDD.DATASET" "${jcl}"`
zbrewtest "jclAddDatasetToDD failed for STEP1.MYDD" "0" "$?" 
zbrewtest "jclAddDatasetToDD failed for STEP1.MYDD" "${jclMyDDAdd}" "${actual}"

actual=`jclAddDatasetToDD "STEP3" "SYSIN" "ZBREW.MYSYSIN.DATASET" "${jcl}"`
zbrewtest "jclAddDatasetToDD failed for STEP1.MYSYSIN" "0" "$?" 
zbrewtest "jclAddDatasetToDD failed for STEP1.MYSYSIN" "${jclSYSINAdd}" "${actual}"

actual=`jclAddDatasetToDD "STEP2" "STDOUT" "ZBREW.MYSTDOUT.DATASET" "${jcl}"`
zbrewtest "jclAddDatasetToDD failed for STEP2.MYSTDOUT" "0" "$?" 
zbrewtest "jclAddDatasetToDD failed for STEP2.MYSTDOUT" "${jclStdoutAdd}" "${actual}"


exit 0
