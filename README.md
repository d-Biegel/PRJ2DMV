# PRJ2DMV - DMV Batch License Processing
A sample program that simulates what government mainframe offices do to process records like license requests. Takes a sequential input file with participants looking to obtain or renew their license and determines their eligiablity based on factors like: age, proof of insurance, test status, etc.
Also collects errors/failed license requests into an error log and concatenates them together into one report for easy transport and reading.

COMPILES ON MVS 3.8 TK5 - FITS COBOL 68 STANDARD

You will need to have the following folders/files created:
- PRJ2.DEV.BCOB - for source files
- PRJ2.DEV.JCL  - for jcl files
- PRJ2.DEV.COPYBOOk - for copybooks
- PRJ2.DEV.LOADLIB - for output binaries
- PRJ2.DEV.INPUT.LICTRNS - for input license transaction dataset
(NOTE: if you use the 0-FULL-PRJ2-SETUP.jcl, you wont have to create all these manually)

## How to setup:
### SHORT WAY:
- copy 0-FULL-PRJ2-SETUP.jcl to your mainframe and run, it will create all the files you need
- submit the COMPILE.jcl in your PRJ1.DEV.JCL to compile
- submit the RUN.jcl in your PRJ1.DEV.JCL to run
- Voila! You can view the JES2 Output by going to 3.8 and finding your job name.

### LONG WAY: 
- Transfer the 0PRJ2STUP.jcl to a pre existing JCL folder and run it, this will create all the locations you need for the following program (if you want to create them manually, allocate the datasets based on the pictures in BACKGROUND INFO and the link (Read input file + allocate input file dataset: https://youtu.be/7hTuDMUjssg )
- Once done, copy the contents of the INPUT Files (after deleting the header lines) to the corresponding folders in PRJ2.DEV.INPUT.filename
- Then copy the cobol copybooks to to the PRJ2.DEV.COPYBOOK folder 
- Then copy the cobol file 1LICENSEB.cob to the PRJ2.DEV.BCOB folder and the 2COMPILE.jcl and 3RUN.jcl files to the PRJ2.DEV.JCL folder
- To compile the program, open up the PRJ2.DEV.JCL(COMPILE) JCL file on the mainframe and submit it (make sure you dont get an error greater than 0004)
- Once compiled, you can run the program by opening the PRJ2.DEV.JCL(RUN) on the mainframe and submit it (make sure you dont get an error greater than 0004)
- Check the output to the spool at =3.8 and you should see the output under the job name from PRJ2.DEV.JCL(RUN)
- You should also be able to see the output files DMVOUTPT, ERRORLOG and COMBINE3
Congrats, you have just run your program! (orig written for the mvs 3.8 hercules emulator tk5)

## Code:
- If you want to just view the code that went into this in a more seemless manner, you can dig into the CODE folder to each component part

## Sources:
- Inspired by code snippets and examples from Jay Moseley: https://www.jaymoseley.com/hercules/


## Data Layout:
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