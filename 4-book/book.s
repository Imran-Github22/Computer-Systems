#=========================================================================
# Book Cipher Decryption
#=========================================================================
# Decrypts a given encrypted text with a given book.
# 
# Computer Systems
# 
# 
#
# 
#
#=========================================================================
# DATA SEGMENT
#=========================================================================
.data
#-------------------------------------------------------------------------
# Constant strings
#-------------------------------------------------------------------------

input_text_file_name:         .asciiz  "input_book_cipher.txt"
book_file_name:               .asciiz  "book.txt"
newline:                      .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
input_text:                   .space 10001       # Maximum size of input_text_file + NULL
.align 4                                         # The next field will be aligned
book:                         .space 10001       # Maximum size of book_file + NULL
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

# opening file for reading (text)

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


# opening file for reading (book)

        li   $v0, 13                    # system call for open file
        la   $a0, book_file_name        # book file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP1:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # book[idx] = c_input
        la   $a1, book($t0)             # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(book_file);
        blez $v0, END_LOOP1             # if(feof(book_file)) { break }
        lb   $t1, book($t0)          
        beq  $t1, $0,  END_LOOP1        # if(c_input == '\0')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP1
END_LOOP1:
        sb   $0,  book($t0)             # book[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(book_file)

#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------
Reset:
         move $t0, $0                  # idx = 0, Input_Text
         li $t5, 32                    # space char
         li $t6, 10                    # "\n"
         li $t1, 0                     # Current loaded Input Text Byte
         li $t2, 0                     # Current loaded Book Text Byte
         li $t3, 1                     # Current Book Row number
         li $t4, 1                     # Current Book Column number
         li $s3, 0                     # X row
         li $s4, 0                     # Y column
         li $t8, 0                     # padd a leading Space Flag
         li $t9, 0                     # Book word idx
         li $s2, 0                     # Position of the last space char
         li $s7, 2
         li $s0, 10                    # Deci
         
# This loop parses the input_text and
# determines the no. of rows & columns.
OUT_LOOP:
         lb    $t1, input_text($t0)
         beq   $t1, $t5, ROW
         beq   $t1, $t6, COLUMN
         beq   $t1, $0, FINISH
         addi  $t0, $t0, 1
         j OUT_LOOP
         
ROW:
         move  $s2, $t0
         subu  $t7, $t0, $0
         beq   $t7, 2, mDigitsRow
         subiu $t0, $t0, 1 
         lb    $s3, input_text($t0)
         subiu $s3, $s3, 48
         addi  $t0, $t0, 2
         j OUT_LOOP

mDigitsRow:
         subiu $t0, $t0, 1
         lb    $s3, input_text($t0)
         subiu $s3, $s3, 48
         subiu $t0, $t0, 1
         lb    $s5, input_text($t0)
         subiu $s5, $s5, 48
         mult  $s5, $s0
         mflo  $s5
         addu  $s3, $s3, $s5
         addi  $t0, $t0, 4
         j OUT_LOOP
                  
COLUMN:
         sb    $t0, 0($sp)
         subiu $t0, $t0, 1
         subu  $t7, $t0, $s2
         beq   $t7, 2, mDigitsCol
         lb    $s4, input_text($t0)
         subiu $s4, $s4, 48
         lb    $t0, 0($sp)
         addi  $t0, $t0, 1
         j SEEK_ROW            

mDigitsCol:
         lb    $s4, input_text($t0)
         subiu $s4, $s4, 48
         subiu $t0, $t0, 1
         lb    $s5, input_text($t0)
         subiu $s5, $s5, 48
         mult  $s5, $s0
         mflo  $s5
         addu  $s4, $s4, $s5
         lb    $t0, 0($sp)
         addi  $t0, $t0, 1
         j SEEK_ROW

# Locate by the idx of the row for the word.
SEEK_ROW:
         lb    $t2, book($t9)
         beq   $s3, $t3, SEEK_COL        
         beq   $t2, $0, FINISH 
         beq   $t2, $t6, incRow
         addi  $t9, $t9, 1
         j SEEK_ROW

incRow:
         addi  $t3, $t3, 1
         addi  $t9, $t9, 1
         j SEEK_ROW

# Locate by the idx of the column for the word.
SEEK_COL:
         lb    $t2, book($t9)
         beq   $s4, $t4, OUT_PUT
         beq   $t2, $0, FINISH 
         beq   $t2, $t5, incCol
         beq   $t2, $t6, newLine
         addi  $t9, $t9, 1
         j SEEK_COL

incCol:
         addi  $t4, $t4, 1
         addi  $t9, $t9, 1
         j SEEK_COL

newLine:
         li    $a0, 10
         li    $v0, 11
         syscall
         addi  $t0, $t0, 1
         li    $t2, 0                     # Current loaded Book Text Byte
         li    $t3, 1                     # Current Book Row number
         li    $t4, 1                     # Current Book Column number
         li    $t9, 0
         li    $s3, 0
         li    $s4, 0
         li    $t8, 0
         j OUT_LOOP

OUT_PUT:
         addi  $t8, $t8, 1
         bge   $t8, $s7, paddSpace
                                    
printWord:
         lb    $t2, book($t9)
         beq   $t2, $t5, next
         beq   $t2, $t6, nextLine     
         move  $a0, $t2
         li    $v0, 11
         syscall
         addi  $t9, $t9, 1         
         j printWord
         
next:
         addi  $t0, $t0, 1
         li    $t2, 0                     # Current loaded Book Text Byte
         li    $t3, 1                     # Current Book Row number
         li    $t4, 1                     # Current Book Column number
         li    $t9, 0
         li    $s3, 0
         li    $s4, 0
         j OUT_LOOP

paddSpace:
         li    $a0, 32
         li    $v0, 11
         syscall
         j printWord
         
nextLine:
         addi  $t0, $t0, 1
         li    $t2, 0                     # Current loaded Book Text Byte
         li    $t3, 1                     # Current Book Row number
         li    $t4, 1                     # Current Book Column number
         li    $t9, 0
         li    $s3, 0
         li    $s4, 0
         j OUT_LOOP  

FINISH:
         li    $a0, 10
         li    $v0, 11
         syscall
         j main_end                     
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li     $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
