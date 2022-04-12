#=========================================================================
# XOR Cipher Cracking
#=========================================================================
# Finds the secret key for a given encrypted text with a given hint.
# 
# Computer Systems
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

input_text_file_name:         .asciiz  "input_xor_crack.txt"
hint_file_name:               .asciiz  "hint.txt"
newline:                      .asciiz  "\n"
minus:                        .asciiz  "-1"  
     
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
input_text:                   .space 10001       # Maximum size of input_text_file + NULL
.align 4                                         # The next field will be aligned
hint:                         .space 101         # Maximum size of key_file + NULL
.align 4                                         # The next field will be aligned

# You can add your data here!
cln_text:                     .space 10001
.align 4
cln_hint:                     .space 101
.align 4
xor_text:                     .space 10001
.align 4

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


# opening file for reading (hint)

        li   $v0, 13                    # system call for open file
        la   $a0, hint_file_name        # hint file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP1:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # hint[idx] = c_input
        la   $a1, hint($t0)             # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(key_file);
        blez $v0, END_LOOP1             # if(feof(key_file)) { break }
        lb   $t1, hint($t0)          
        addi $v0, $0, 10                # newline \n
        beq  $t1, $v0, END_LOOP1        # if(c_input == '\n')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP1
END_LOOP1:
        sb   $0,  hint($t0)             # hint[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(key_file)

#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------


# Initialize
Reset:
        li   $t0, 0                         # Xored_Text Idx
        li   $t1, 0                         # Input_Text Idx
        li   $t2, 0                         # Current Input_Text Byte    
        li   $t3, 0                         # Xor Register
        li   $t4, 0                            
        li   $t5, 0
        li   $t6, 0
        li   $t7, 32                        # Space Char
        li   $t8, 0
        li   $t9, 0                         # Hint_Text idx
        li   $s0, 0                         # Keys Idx
        li   $s1, 0                         # Current Loaded Key
        li   $s2, 0                         # Length of the Hint text
        li   $s3, 0                         # Word match counter
        li   $s4, 0                         # cln_text length         

CLN_LOOP:
        lb   $t1, input_text($t0)       
        beq  $t1, $0, paddZero              # if(c_input == '\0')
        beq  $t1, 10, paddSpace
        sb   $t1, cln_text($t2)
        addi $t0, $t0, 1                    # idx += 1
        addi $t2, $t2, 1
        j    CLN_LOOP
        
paddZero:
        sb   $0, cln_text($t2)              # cln_text[idx] = '\0'
        move $s4, $t2
        li   $t0, 0
        li   $t1, 0
        li   $t2, 0
        li   $t4, 0                         # Key value in Binary
        li   $t5, 0
        li   $t6, 0
        li   $t9, 0
        j CLN_HNT
        
paddSpace:
        sb   $t7, cln_text($t2)
        addi $t0, $t0, 1
        addi $t2, $t2, 1
        j    CLN_LOOP
        
CLN_HNT:
        lb   $t1, hint($t0)       
        beq  $t1, $0, paddZeroH               # if(c_input == '\0')
        beq  $t1, 10, paddSpaceH
        beq  $t1, $t7, paddSpaceH
        sb   $t1, cln_hint($t2)
        addi $t0, $t0, 1                      # idx += 1
        addi $t2, $t2, 1
        j    CLN_HNT              

paddZeroH:
        sb   $0, cln_hint($t2)                # cln_text[idx] = '\0'
        move $s2, $t2
        li   $t0, 0
        li   $t1, 0
        li   $t2, 0
        li   $t4, 0                           # Key value in Binary
        li   $t5, 0
        li   $t6, 0
        li   $t9, 0
        j Next_Key                            # load the first key
        
paddSpaceH:
        sb   $t7, cln_hint($t2)
        addi $t0, $t0, 1
        addi $t2, $t2, 1
        j    CLN_HNT

Next_Key:
        beq   $s0, 128, Terminate 
        addu  $s1, $s0, $0
        move  $t0, $s1                       # Current Key
        li    $t1, 0
        li    $t2, 0
        li    $t3, 0
        li    $t4, 0                        
        li    $t5, 0
        li    $t6, 0
        li    $t9, 0
        addiu $s0, $s0, 1                    # load the next key
        j Decrypt

# Decrypt the text
Decrypt:
        lb    $t2, cln_text($t1)
        beq   $t2, $0, Reset_Regs
        beq   $t2, $t7, paddSpaceX
        
        xor   $t3, $t0, $t2
        sb    $t3, xor_text($t1)
        
        addi  $t1, $t1, 1
        j Decrypt

paddSpaceX:
        sb    $t7, xor_text($t1)
        addi  $t1, $t1, 1
        j Decrypt
                
Reset_Regs:
        li    $t0, 0
        li    $t1, 0
        li    $t2, 0
        li    $t3, 0 
        j SEARCH
        
# Match with the hint text        
SEARCH:
        lb    $t1, xor_text($t0)
        lb    $t3, cln_hint($t2)
        beq   $t1, $0, Next_Key
        bne   $t1, $t3, Skip
        
        addi  $t0, $t0, 1
        addi  $t2, $t2, 1
        addi  $s3, $s3, 1                     # Increment match counter
        beq   $s3, $s2, Print                 # if equal to cln_hint length        
        j SEARCH

Skip:   li    $t2, 0
        li    $s3, 0                          # Reset the match counter
        addi  $t0, $t0, 1
        lb    $t1, xor_text($t0)
        beq   $t1, $t3, SEARCH
        addi  $t0, $t0, 1
        beq   $t1, $0,  Next_Key
        j Skip

Print:  move  $s0, $s1
        # set up the loop counter variable
        li    $t0, 8  # 8 digits a byte in the 32 bit number

        sll   $s1, $s0, 24
        
loop:   srl   $t1, $s1, 31  # get leftmost digit by shifting it

        # Convert the number to a char
        addi  $t1, $t1, 48 # ASCII for '0' is 48

        # Print one digit
        li    $v0, 11
        add   $a0, $zero, $t1
        syscall            # Print the ASCII char in $a0

        # next iteration
        sll   $s1, $s1, 1   # Drop current leftmost digit
        addi  $t0, $t0, -1  # Update loop counter
        bne   $t0, $0, loop

        la    $a0, newline
        li    $v0, 4
        syscall
        j main_end
                        
Terminate:
         la   $a0, minus
         li   $v0, 4
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
