#=========================================================================
# Steganography
#=========================================================================
# Retrive a secret message from a given text.
# 
# Computer Systems
# 
#
#=========================================================================
# DATA SEGMENT
#=========================================================================
.data
#-------------------------------------------------------------------------
# Constant strings
#-------------------------------------------------------------------------

input_text_file_name:         .asciiz  "input_steg.txt"
newline:                      .asciiz  "\n"
addspace:                     .asciiz  " "
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
input_text:                   .space 10001       # Maximum size of input_text_file + NULL
.align 4                                         # The next field will be aligned

# You can add your data here!

#=========================================================================
# TEXT SEGMENT  
#=========================================================================
.text

#-------------------------------------------------------------------------
# MAIN code block
#-------------------------------------------------------------------------

.globl main                     # Declare main label to be globally visible.
                                # Needed for correct operation with MARS
main:
#-------------------------------------------------------------------------
# Reading file block. DO NOT MODIFY THIS BLOCK
#-------------------------------------------------------------------------

# opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, input_text_file_name  # input_text file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP:                              # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # input_text[idx] = c_input
        la   $a1, input_text($t0)             # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(input_text_file);
        blez $v0, END_LOOP              # if(feof(input_text_file)) { break }
        lb   $t1, input_text($t0)          
        beq  $t1, $0,  END_LOOP        # if(c_input == '\0')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP
END_LOOP:
        sb   $0,  input_text($t0)       # input_text[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(input_text_file)


#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------


# You can add your code here!
        move $t0, $0                   # idx = 0
        li   $t5, 32                   # space char
        li   $t6, 10                   # "\n"
        li   $t7, 0                    # Word Counter
        li   $t8, 0                    # Line Counter
        li   $t9, 0                    # First Column Flag
        li   $s7, 0                    # Cursor
        
OUT_LOOP:                              # do {
        lb   $t1, input_text($t0)
        beq  $t1, $0, FINISH           # if(c_input == '\0') { break }
        beq  $t1, $t5, incWord         # if(c_input == " ")
        beq  $t1, $t6, incLine
        beq  $t7, $s7, lspace 
        addi $t0, $t0, 1
        j OUT_LOOP

lspace:
       beq   $t9, $0, pWord
       la    $a0, addspace 
       li    $v0, 4
       syscall
       j pWord 	

pWord:
        add  $a0, $t1, $0
        li   $v0, 11
        syscall
 
        addi $t0, $t0, 1                # idx += 1
        lb   $t1, input_text($t0)
        beq  $t1, $0, FINISH            # if(c_input == '\0') { break }
        beq  $t1, $t5, stopWord         # if(c_input == " ")
        beq  $t1, $t6, incLine
        j    pWord

stopWord:
       addi  $t9, $t9, 1
       j OUT_LOOP

incWord:
       addi  $t7, $t7, 1
       addi  $t0, $t0, 1
       j OUT_LOOP

incLine:                               # print new line "\n"
       beq   $t7, $t8, paddLine
       addi  $t8, $t8, 1               #increment the Line Counter
       addi  $s7, $s7, 1               #increment the Word Cursor for pWord

       li    $t7, 0
       addi  $t0, $t0, 1
       j OUT_LOOP

paddLine:
       addi  $t8, $t8, 1               #increment the Line Counter
       addi  $s7, $s7, 1               #increment the Word Cursor for pWord
       li    $t7, 0
       li    $t9, 0
       li    $a0, 10                   # newline
       li    $v0, 11
       syscall
       addi  $t0, $t0, 1
       j OUT_LOOP

FINISH:
        li   $a0, 10
        li   $v0, 11
        syscall
        j main_end
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
