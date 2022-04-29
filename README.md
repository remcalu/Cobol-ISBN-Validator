# Cobol ISBN Validator

## Author
Remus Calugarescu

## Last Major Modification
April 29, 2022

## Purpose
Program made to practice programming in Cobol, it will read potential ISBNs from a text file and will perform validation on them, including the usage of valid characters (0-9 and X), and the ISBN checksum algorithm. 

## Installing dependencies
First you must have cobol installed, you can do so by running
~~~~
sudo apt install open-cobol -y
~~~~

## Input file
An input file must be formatted in the following way
~~~~
1856266532
0864500572
0201314525
159486781X
159486781x
0743287290
081185213X
1B56266532
159A86781Z
1856266537
~~~~

## Running the program
After running the following commands, you may view the output in the terminal
~~~~
1. cobc -free -x -Wall isbn.cob
2. ./isbn
~~~~

## Output example
This output is based off of testFile.txt
~~~~
1856266532  Valid ISBN
0864500572  Valid ISBN
0201314525  Valid ISBN
159486781X  Valid ISBN
159486781x  Valid ISBN
0743287290  Valid ISBN
081185213X  Valid ISBN
1B56266532  Invalid ISBN - (Invalid char 'B' at 02/10)
159A86781Z  Invalid ISBN - (Invalid char 'A' at 04/10) (Invalid char 'Z' at 10/10)
1856266537  Invalid ISBN - (Calculated checksum is '02' instead of '07')
~~~~