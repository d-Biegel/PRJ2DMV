# PRJ2LIC
Cobol Project for MVS 3.8 that processes batch license transactions and determines eligability.

## HOW TO SETUP AND RUN:

    Transfer the 0PRJ2STUP.jcl to a pre existing JCL folder and run it, this will create all the locations you need for the following program

OR if you want to create them manually, allocate the datasets based on the pictures in BACKGROUND INFO and the link (Read input file + allocate input file dataset: https://youtu.be/7hTuDMUjssg )

    Once done, copy the contents of the INPUT Files (after deleting the header lines) to the corresponding folders in PRJ2.DEV.INPUT.filename

    Then copy the cobol copybooks to to the PRJ2.DEV.COPYBOOK folder 

    Then copy the cobol file 1LICENSEB.cob to the PRJ2.DEV.BCOB folder and the 2COMPILE.jcl and 3RUN.jcl files to the PRJ2.DEV.JCL folder

    To compile the program, open up the PRJ2.DEV.JCL(COMPILE) JCL file on the mainframe and submit it (make sure you dont get an error greater than 0004)

    Once compiled, you can run the program by opening the PRJ2.DEV.JCL(RUN) on the mainframe and submit it (make sure you dont get an error greater than 0004)

    Check the output to the spool at =3.8 and you should see the output under the job name from PRJ2.DEV.JCL(RUN)

    You should also be able to see the output files DMVOUTPT, ERRORLOG and COMBINE3

Congrats, you have just run your program! (orig written for the mvs 3.8 hercules emulator tk5)


## DATA LAYOUT:
- Name		Eye(bu,br,gr) 	Hair(rd,br,bo,bl)	Age		glasses or corrective lens?(y/n)	License type (D,B,C,A,M) 	Passed road test? (y/n) 	Passed Written Exam? (y/n)		is renewal?(y/n)	license expire date(if renewal, if no n/a)	car type	license reciprocity?(ie getting replacement license for out of state - y/n)		proof of insurance?(y/n)		has identity documentation?		
- Brian Smith         bl rd 018 y D y y n NA-NA-NA sedan n y y
- Joe McCandless		br bo 049 n D y y y 01-23-26 truck n y y
- (and so on)


## Checks & Requirements
don't issue certain license types for people under a certain age (ie no full license for people under 18, no cdls under 21)
dont issue license to people unless they pass all their tests and have paid their fee
if person is older than 120 dont issue license and throw out ERROR
if no insurance dont issue license
if no identity documentation dont issue license 

calculate the correct fee based on if its a renewal or not (renewal more expensive)
for renewal dates, see if previous license expired
for people over age of 72, next renewal date needs to be 5 years out instead of 8 years)
at end, map type of license code to full description of license (example: M = Motorcycle License) then print out

add a second output report (one normal, one error report) - ask chat gpt
then concatenate the error and output reports using jcl at then end