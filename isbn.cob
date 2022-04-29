*> NOTES:                  It is expected that the input file will have no more than 1000 lines

identification division.
program-id. isbnValidator.

environment division.
   input-output section.

   *> Determining how the input file will be treated
   file-control.
   select inputFile assign to dynamic fileName
      file status is fileStatus
      organization is line sequential.

data division.
   *> Declaring variables used for file processing
   file section.
   fd inputFile.
   01 curISBN.
      05 ISBN pic x(10).
      
   *> Declaring all other variables
   working-storage section.

   *> Variables that deal with file processing
   01 fileName pic x(50).
   01 fileStatus pic x(2).
   01 fileExists pic 9999.
   01 eofSwitch pic 9999.
   01 readListISBN.
      05 readStringsISBN occurs 1000 times.
         10 readContentISBN pic x(10).

   *> Variables that deal with the processing and storage of potential ISBNs
   01 numISBN pic 9999.
   01 tempProcessedMessageISBN pic x(1000).
   01 processedListISBN.
      05 processedContentInvalid pic 9 occurs 1000.
      05 processedStringsISBN occurs 1000 times.
         10 processedContentISBN pic x(1000).

   *> Variables that deal with the checkSum calculation
   01 curCharToInt pic 99.
   01 curMultiplyFactor pic 99.
   01 totalChecksum pic 9999.
   01 totalChecksumDivision pic 9999.
   01 totalChecksumModulo pic 9999.
   01 totalChecksumSubtracted pic 99.

   *> Counters and temp variables
   01 counter pic 999.
   01 counterJ pic 999.
   01 counterJTemp pic 99.
   01 prevISBN pic x(10).
   01 foundErrorISBN pic 9.
   01 curChar pic x(1).

procedure division.
   *> Print welcome message and instructions
   display "--------------------------------------------------"
   display "|  Welcome to a Cobol ISBN verification program  |"
   display "--------------------------------------------------"
   display "Please enter a file name that contains potential ISBN numbers: " with no advancing.

   *> readISBN Subprogram/Paragraph - Reading the file and placing contents into array of strings
   readISBN.
      *> Get file name from user and prompt until the file can be opened
      move 0 to fileExists
      perform until fileExists is equal to 1

         *> Loop until a file that exists is entered   
         accept fileName
         open input inputFile
         
         *> Checking file status
         if fileStatus is not equal to 00 then
            display "ERROR: Invalid file detected, enter a valid text file that contains potential ISBN numbers: " with no advancing
         else
            display "Valid file detected, checking for potential ISBNs and listing results below..."
            display "------------------------------------------------------------------------------"
            display " "
            move 1 to fileExists
         end-if

         *> Closing file descriptor
         close inputFile
         
      end-perform.

      *> Reopening the closed file to reset the filepointer, and actually reading it this time instead of checking for existance
      open input inputFile
      move 1 to numISBN
      move 0 to eofSwitch
      perform until eofSwitch equals 1
         
         *> Reading a line from the input file
         read inputFile
            at end 
               move 1 to eofSwitch
               close inputFile
         end-read

         *> Checking if it is end of file or not
         if eofSwitch is not equal to 1
            move curISBN to readStringsISBN(numISBN)
            add 1 to numISBN
         end-if

      end-perform.

   *> isValid Subprogram/Paragraph - Determining which ISBN is valid and which is not
   isValid.
      *> Looping until the program has gone through all of the read potential ISBNs
      move 1 to counter
      perform until counter is equal to numISBN
         move readStringsISBN(counter) to curISBN
         move 0 to foundErrorISBN
         move " " to tempProcessedMessageISBN

         *> Looping through each character in the potential ISBN
         move 1 to counterJ
         perform until counterJ is equal to 11
            move curISBN(counterJ:1) to curChar
            
            *> Checking if the current character is a valid character, then printing an error if thats the case
            if curChar is not equal to '0' and curChar is not equal to '1' and curChar is not equal to '2' and curChar is not equal to '3'
            and curChar is not equal to '4' and curChar is not equal to '5' and curChar is not equal to '6' and curChar is not equal to '7'
            and curChar is not equal to '8' and curChar is not equal to '9' and curChar is not equal to 'x' and curChar is not equal to 'X' then
               
               *> Setting up the string that says what invalid character was found
               if foundErrorISBN is equal to 0 then
                  string "            Invalid ISBN - " delimited by size X'00' delimited by size into tempProcessedMessageISBN
               end-if
               move 1 to foundErrorISBN

               *> Moving counter into a 2 digit integer variable for nicer string formatting
               move counterJ to counterJTemp

               *> Appending the error to the string
               string tempProcessedMessageISBN delimited by X'00' "(Invalid char '" curChar "' at " counterJTemp "/10) " delimited by X'00' X'00' delimited by size into tempProcessedMessageISBN
            end-if
            
            add 1 to counterJ
         end-perform

         *> Combining the ISBN + string that says what is invalid
         string curISBN delimited by " ", " ", into tempProcessedMessageISBN 
         move tempProcessedMessageISBN to processedStringsISBN(counter)

         *> Marking which entry in the array of strings has an error that was found with isValid
         if foundErrorISBN is equal to 1 then 
            move 1 to processedContentInvalid(counter)
         else
            move 0 to processedContentInvalid(counter)
         end-if

         add 1 to counter

      end-perform.

   *> checkSUM Subprogram/Paragraph - Determining which ISBN is valid by performing the checksum
   checkSUM.
      *> Looping through each individual saved potential ISBN
      move 1 to counter
      perform until counter is equal to numISBN
         move readStringsISBN(counter) to curISBN

         *> Looping through the first 9 digits of the potential ISBN
         move 0 to totalChecksum
         move 1 to counterJ
         perform until counterJ is equal to 10
            move curISBN(counterJ:1) to curChar

            *> Determining what the current number to deal with is
            if curChar is equal to 'x' or curChar is equal to 'X' then 
               move 10 to curCharToInt
            else 
               move curChar to curCharToInt
            end-if

            *> Determining the multiplication value
            move 11 to curMultiplyFactor
            subtract counterJ from curMultiplyFactor

            *> Accumulating all of the multiplied digits
            multiply curMultiplyFactor by curCharToInt
            add curCharToInt to totalChecksum

            add 1 to counterJ
         end-perform

         *> Getting the 10th digit
         move curISBN(counterJ:1) to curChar
         if curChar is equal to 'x' or curChar is equal to 'X' then 
            move 10 to curCharToInt
         else 
            move curChar to curCharToInt
         end-if

         *> Finding the modulo of the sum, then subtracting 11 from it
         divide totalChecksum by 11 giving totalChecksumDivision remainder totalChecksumModulo
         subtract totalChecksumModulo from 11 giving totalChecksumSubtracted

         *> Dealing with the special case where the modulo was 0 resulting in a difference of 11, so setting the difference to 0
         if totalChecksumSubtracted is equal to 11 then
            move 0 to totalChecksumSubtracted
         end-if 

         *> Checking if the result is equal to the check digit
         if curCharToInt is equal to totalChecksumSubtracted then
            string "            Valid ISBN" delimited by size X'00' delimited by size into tempProcessedMessageISBN
         else 
            string "            Invalid ISBN - (Calculated checksum is '" totalChecksumSubtracted "' instead of '" curCharToInt "') " delimited by size X'00' delimited by size into tempProcessedMessageISBN
         end-if

         *> Checking if the current ISBN has been processed or not inside of the isValid paragraph, if it hasn't then save it
         if processedContentInvalid(counter) is equal to 0 then 
            string curISBN delimited by "_", " ", into tempProcessedMessageISBN 
            move tempProcessedMessageISBN to processedStringsISBN(counter)
         end-if
         
      add 1 to counter

      end-perform.

   *> Printing out the saved ISBNs + their validity status and messages
   move 1 to counter
   perform until counter is equal to numISBN

      *> Looping through each character in the ISBN + validity status and message string until the final character is printed, AKA until reaching the null termination character
      move space to curChar
      move processedStringsISBN(counter) to tempProcessedMessageISBN

      move 1 to counterJ
      perform until curChar is equal to X'00'
         move tempProcessedMessageISBN(counterJ:1) to curChar
         if curChar is not equal to X'00' then 
            display curChar with no advancing
            add 1 to counterJ
         end-if
      end-perform
      display " "
      display " "
      add 1 to counter

   end-perform.

   display "------------------------------------------------------------------------------"
   display "Finished reading, processing, and outputting the data, exiting program".
