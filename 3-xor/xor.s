#=========================================================================
# XOR Cipher Encryption
#=========================================================================
# Encrypts a given text with a given key.
# 
# Computer Systems
# 
# 
# 2020
# 
#
#=========================================================================
# DATA SEGMENT
#=========================================================================
.data
#-------------------------------------------------------------------------
# Constant strings
#-------------------------------------------------------------------------

input_text_file_name:         .asciiz  "input_xor.txt"
key_file_name:                .asciiz  "key_xor.txt"
newline:                      .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
input_text:                   .space 10001       # Maximum size of input_text_file + NULL
.align 4                                         # The next field will be aligned
key:                          .space 33          # Maximum size of key_file + NULL
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


# opening file for reading (key)

        li   $v0, 13                    # system call for open file
        la   $a0, key_file_name         # key file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP1:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # key[idx] = c_input
        la   $a1, key($t0)              # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(key_file);
        blez $v0, END_LOOP1             # if(feof(key_file)) { break }
        lb   $t1, key($t0)          
        addi $v0, $0, 10                # newline \n
        beq  $t1, $v0, END_LOOP1        # if(c_input == '\n')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP1
END_LOOP1:
        sb   $0,  key($t0)              # key[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(key_file)

#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------

# Initialize

        li    $t0, 0                         
        li    $t4, 8                         # No of bits
        li    $s5, 0                         # No. of Bytes of the Key
        li    $t9, 0                         # Key idx
        li    $t7, 0                         
        move  $t6, $0                        # Binary word register
        subiu  $sp, $sp, 32
        
PARS_BYTE:
        lb    $t2, key($t9)
        beq   $t2, 49, SHIFT_1               # Shift a 1
        beq   $t2, $0, LOAD_KEY_REGS
        beq   $t2, 10, STORE_KEY
        sll   $t6, $t6, 1                    # Shift a 0
        beq   $t9, 7,  Key_1
        beq   $t9, 15, Key_2 
        beq   $t9, 23, Key_3
        beq   $t9, 31, Key_4              
        addi  $t9, $t9, 1 
        j PARS_BYTE
        
SHIFT_1:
        sll   $t6, $t6, 1                    # Shift first to load zero
        addiu $t6, $t6, 1                    # then add to it 1.
        beq   $t9, 7,  Key_1
        beq   $t9, 15, Key_2 
        beq   $t9, 23, Key_3
        beq   $t9, 31, Key_4        
        addi  $t9, $t9, 1      
        j PARS_BYTE

STORE_KEY:
        beq   $t9, 8, Key_1_P
        beq   $t9, 16, Key_2_P
        beq   $t9, 24, Key_3_P
        beq   $t9, 32, Key_4_P        
        addi  $t9, $t9, 1 
        div   $s5, $t9, $t4
        sw    $s5, 16($sp)       
        j PARS_BYTE

Key_1_P:
        sb    $t6, 0($sp)
        li    $t6, 0
        j LOAD_KEY_REGS
Key_2_P:
        sb    $t6, 4($sp)
        li    $t6, 0
        j LOAD_KEY_REGS
Key_3_P:
        sb    $t6, 8($sp)
        li    $t6, 0
        j LOAD_KEY_REGS
Key_4_P:
        sb    $t6, 12($sp)
        li    $t6, 0
        j LOAD_KEY_REGS
Key_1:
        sb    $t6, 0($sp)
        li    $t6, 0
        addi  $t9, $t9, 1 
        j PARS_BYTE
Key_2:
        sb    $t6, 4($sp)
        li    $t6, 0
        addi  $t9, $t9, 1 
        j PARS_BYTE        
Key_3:
        sb    $t6, 8($sp)
        li    $t6, 0
        addi  $t9, $t9, 1 
        j PARS_BYTE
Key_4:
        sb    $t6, 12($sp)
        li    $t6, 0
        addi  $t9, $t9, 1 
        j PARS_BYTE       

LOAD_KEY_REGS:
        div   $s5, $t9, $t4
        sw    $s5, 16($sp)   
        lb    $s1, 0($sp)
        lb    $s2, 4($sp)
        lb    $s3, 8($sp)
        lb    $s4, 12($sp)
        lb    $s5, 16($sp)                   # No of Keys
        
        li    $t0, 0                         # Input Byte
        li    $t1, 0                         # XOR Key 1
        li    $t2, 0                         # XOR Key 2       
        li    $t3, 0                         # XOR Key 3
        li    $t4, 0                         # XOR Key 4        
        li    $t9, 0                         # Input_Text idx
        li    $t7, 0                         #         
        li    $s6, 1                         # Current No. of the key
        
        beq   $s5, 1, ENC_1
        beq   $s5, 2, ENC_2
        beq   $s5, 3, ENC_3
        beq   $s5, 4, ENC_4  

ENC_1:
         lb   $t1, 0($sp)
         lb   $t0, input_text($t9)
         beq  $t0, 32, Skip
         beq  $t0, 10, Skip
         beq  $t0, $0, FINISH
         xor  $a0, $t0, $t1
         li   $v0, 11
         syscall
         addi $t9, $t9, 1
         j ENC_1

Skip:
         add  $a0, $t0, $0
         li   $v0, 11
         syscall
         addi $t9, $t9, 1
         j ENC_1
                 
ENC_2:
         lb   $t1, 0($sp)
         lb   $t2, 4($sp)
         lb   $t0, input_text($t9)  
                
         beq  $t0, 32, Skip_1
         beq  $t0, 10, Skip_1
         beq  $t0, $0, FINISH
         div  $t7, $t9, 2
         mfhi $t7
         bnez $t7, Xor_Key2
         xor  $a0, $t0, $t1
         
         li   $v0, 11
         syscall
         addi $t9, $t9, 1
         j ENC_2
         
Xor_Key2:
         xor  $a0, $t0, $t2
         li   $v0, 11
         syscall
         
         addi $t9, $t9, 1
         j ENC_2

Skip_1:
         add  $a0, $t0, $0
         li   $v0, 11
         syscall

         addi $t9, $t9, 1
         j ENC_2
          
ENC_3:
         lb   $t1, 0($sp)
         lb   $t2, 4($sp)
         lb   $t3, 8($sp)
         lb   $t0, input_text($t9)  
                
         beq  $t0, 32, Skip_1_3
         beq  $t0, 10, Skip_1_3
         beq  $t0, $0, FINISH
         beq  $s6, 2,  Xor_Key2_3
         beq  $s6, 3,  Xor_Key3_3

         xor  $a0, $t0, $t1
         
         li   $v0, 11
         syscall
         addi $t9, $t9, 1
         addi $s6, $s6, 1
         j ENC_3
         
Xor_Key2_3:
         xor  $a0, $t0, $t2
         li   $v0, 11
         syscall
         
         addi $t9, $t9, 1
         addi $s6, $s6, 1
         j ENC_3

Xor_Key3_3:
         xor  $a0, $t0, $t3
         li   $v0, 11
         syscall
         
         addi $t9, $t9, 1
         li   $s6, 1
         j ENC_3
Skip_1_3:
         add   $a0, $t0, $0
         li    $v0, 11
         syscall
         addi  $t9, $t9, 1
         addiu $s6, $s6, 1
         bgt   $s6, 3, ResetTo1
         j ENC_3
         
ResetTo1:
        li     $s6, 1
        j ENC_3

ENC_4:
         lb    $t1, 0($sp)
         lb    $t2, 4($sp)
         lb    $t3, 8($sp)
         lb    $t4, 16($sp)
         
         lb    $t0, input_text($t9)  
                
         beq   $t0, 32, Skip_1_4
         beq   $t0, 10, Skip_1_4
         beq   $t0, $0, FINISH
         beq   $s6, 2,  Xor_Key2_4
         beq   $s6, 3,  Xor_Key3_4
         beq   $s6, 4,  Xor_Key4_4
         
         xor   $a0, $t0, $t1
         
         li    $v0, 11
         syscall
         addi  $t9, $t9, 1
         addi  $s6, $s6, 1
         j ENC_4
         
Xor_Key2_4:
         xor   $a0, $t0, $t2
         li    $v0, 11
         syscall
         
         addi  $t9, $t9, 1
         addi  $s6, $s6, 1
         j ENC_4

Xor_Key3_4:
         xor   $a0, $t0, $t3
         li    $v0, 11
         syscall
         
         addi  $t9, $t9, 1
         addi  $s6, $s6, 1
         j ENC_4
Xor_Key4_4:
         xor   $a0, $t0, $t4
         li    $v0, 11
         syscall
         
         addi  $t9, $t9, 1
         li    $s6, 1
         j ENC_4
Skip_1_4:
         add   $a0, $t0, $0
         li    $v0, 11
         syscall
         addi  $t9, $t9, 1
         addiu $s6, $s6, 1
         bgt   $s6, 4, ResetTo1_4
         j ENC_4
         
ResetTo1_4:
        li     $s6, 1
        j ENC_4

FINISH:
        addiu  $sp, $sp, 32
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
