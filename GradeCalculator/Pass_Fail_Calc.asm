; Pass_Fail_Calc.asm

#include c:\68hcs12\registers.inc

; Author          Mark Kaganovsky
; Student Number: 040-890-903
; Date:           4 December 2015
; Purpose:        Calculate if a student has passed both the Practical and Theory
;                 portions of the course. Display a 'P' if both portions passed,
;                 otherwise, display an 'F' Display the values for 1 second each
;                 (e.g. 4 delay cycles of 250 ms each) Then, blank the display for
;                 the same amount of time and continue on with the values. At the
;                 end, blank the display
;                 Note that there is only ONE 'P' or 'F' displayed per student
;
; Program logic outline:
;   For every student:
;     1. Calculate the pass/fail grade for the practical portion.
;     2. Then the pass/fail grade for the theory portion.
;     3. Then the final pass/fail grade based on the above 2 values.
;     4. Then store that final pass/fail grade in the Students_PF array.
;     5. Then go back to step (1.) until all students have been processed.
;
;   After all grades are calculated and the final pass/fail grades are stored in
;   the Students_PF array, iterate through the Students_PF array and display a
;   P (Pass) or a F (Fail) which would indicate whether the student passed, or
;   failed the course.



; Program Constants
DELAY_VALUE     equ     250     ; 250 milliseconds delay time.
STACK           equ     $2000   ; Start of stack.

DIGIT3_PP0      equ     %0111   ; MSB of the displayed BCD digits (left-most dislay)

BLANK_DISPLAY   equ     2       ; Used for the PF_Hex_Display subroutine.

NUM_PRACTICAL   equ     5       ; The number of practical assessments
NUM_THEORY      equ     3       ; The number of theory assessments.




; data section
             org     $1000

; Read in the student grades data file
Start_Course_Data
#include "Wed_1-3_Marks.txt"
End_Course_Data

Students_PF           ; Array big enough to store final pass/fail grades.
              ds      (End_Course_Data-Start_Course_Data)/(NUM_PRACTICAL+NUM_THEORY)
End_Students_PF




; Code section
             org     $2000                   ; RAM address for Code
             lds     #STACK

             jsr     Config_Hex_Displays

             ldy     #Start_Course_Data

             ldx     #Students_PF

Next_Student
             cpx     #End_Students_PF        ; Have we filled up the students
             bhs     Display_PF              ; pass/fail array?
             pshx


             ldab    #NUM_PRACTICAL          ; Practical marks calculation.
             jsr     Calculate_Average

             jsr     Pass_Fail
             pulx
             staa    0,x
             pshx

             ldab    #NUM_PRACTICAL          ; Move y to point to the theory
             aby                             ; data for this student.


             ldab    #NUM_THEORY             ; Theory marks calculation
             jsr     Calculate_Average

             jsr     Pass_Fail

             ldab    #NUM_THEORY             ; Move y to point to the next
             aby                             ; students's practical data.


             pulx                            ; Save the student's final grades.
             anda    0,x                     ; AND the grade in A with the
             staa    1,x+                    ; student's practical grade.
             pshx

             bra     Next_Student            ; Move on to the next student
        

Display_PF                                   ; Display the final pass/fail marks.
             ldx     #Students_PF
Next_Display
             ldab    #DIGIT3_PP0             ; Select the left most digit.
             cpx     #End_Students_PF
             bhs     Done

             ldaa    1,x+                    ; Display the pass/fail on the LEDs
             pshx
             jsr     PF_HEX_Display

             ldaa    #DELAY_VALUE            ; Keep P/F on display for 1 second.
             jsr     Delay_ms
             ldaa    #DELAY_VALUE
             jsr     Delay_ms
             ldaa    #DELAY_VALUE
             jsr     Delay_ms
             ldaa    #DELAY_VALUE
             jsr     Delay_ms
        
        
             ldaa    #BLANK_DISPLAY          ; Blank the display for 1 second.
             jsr     PF_HEX_Display
             ldaa    #DELAY_VALUE
             jsr     Delay_ms
             ldaa    #DELAY_VALUE
             jsr     Delay_ms
             ldaa    #DELAY_VALUE
             jsr     Delay_ms
             ldaa    #DELAY_VALUE
             jsr     Delay_ms
        
             pulx
        
             bra     Next_Display            ; Go to next student pass/fail mark.
Done         bra     Done                    ; Maintain blank display forever.




; ***** DO NOT CHANGE ANY CODE BELOW HERE *****;
#include Calculate_Average.asm
#include Pass_Fail.asm
#include C:\68HCS12\Lib\Config_Hex_Displays.asm
#include PF_HEX_Display.asm
#include C:\68HCS12\Lib\Delay_ms.asm
        end