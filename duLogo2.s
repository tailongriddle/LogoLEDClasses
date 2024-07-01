#include <riscv.h>
# lab6

# The a0 register code needed to turn on an LED is 0x100
# The a1 register sets the (x,y) location in the grid to turn on
# The a2 register sets the color of the LED
# Red is in bits 23-16, g in bits 15-8, and b in bits 7-0
# li is a pseudo instruction that loads the immediate value into the register

# la: loads the address of the label into the register
# li: loads the immediate value into the register
# lw: loads the value at the address in the register into the register
# bq: branch if equal, jumps to the label if the two registers are equal
# beqz: branch if equal to zero, jumps to the label if the register is zero


# li a0, 0x100
# li a1, 0x00050012 # (5, 18) because 5*32 + 18 = 178
# li a2, 0x00FF0000

# ecall

# nop


.data
grid:
 .word 0xFFFFFC00
 .word 0xFFFFFE00
 .word 0xFFFFFF00
 .word 0x3FFFFF00

 .word 0x3F003F00
 .word 0x3F003F00
 .word 0x3F3F3F3F
 .word 0x3F3F3F3F

 .word 0x3F3F3F3F
 .word 0x3F3F3F3F
 .word 0x3F3F3F3F
 .word 0x3F3F3F3F

 .word 0x3F3F3F3F
 .word 0x3F3F3F3F
 .word 0x3F3F3F3F
 .word 0x3F3F3F3F

 .word 0x3F3F3F3F
 .word 0x3F3F3F3F
 .word 0x3F003F3F
 .word 0x3F003F3F

 .word 0x3FFFFF3F
 .word 0xFFFFFF3F
 .word 0xFFFFFE3F
 .word 0xFFFFFC3F
 
 .word 0x0000007F
 .word 0x000000FF
 .word 0x003FFFFF
 .word 0x003FFFFF
 
 .word 0x001FFFFE
 .word 0x000FFFFC

.text

# main function
main: 
    addi sp, sp, -16      # allocate space on stack
    sw ra, 12(sp)         # save return address on stack

    jal ra, drawBackground  # call drawBackground 
    li a0, 10             # exit with status code 10
    ecall

drawBackground:
    addi sp, sp, -20      # allocate space on stack
    sw ra, 16(sp)         # save return address on stack
    sw s0, 12(sp)         # save s0 on stack
    sw s1, 8(sp)          # save s1 on stack
    sw s2, 4(sp)          # save s2 on stack
    sw s3, 0(sp)          # save s3 on stack

    la s0, grid           # load the address of the grid into s0
    li s1, 0              # row counter
    li s3, 30             # row limit
    li s6, 1

rowLoop:
    beq s1, s3, endDraw   # if row counter == row limit, end drawing
    lw t0, 0(s0)          # load the value at the address in s0 into t0

    li s2, 0              # column counter
columnLoop:
    li s4, 32             # column limit
    beq s2, s4, nextRow   # if column counter == column limit, go to next row

    srli t1, t0, 31       # shift the value in t0 right by 31 bits and store in t1

    mv a0, s2             # pass x (column) to a0
    mv a1, s1             # pass y (row) to a1
    jal ra, lightLED      # call lightLED

    addi s2, s2, 1        # increment the column counter
    slli t0, t0, 1        # shift the value in t0 left by 1 bit and store in t0
    j columnLoop          # jump to column loop

nextRow:
    addi s1, s1, 1        # increment the row counter
    addi s0, s0, 4        # increment the grid address by 4 bytes
    j rowLoop             # jump to row loop

endDraw:
    lw s3, 0(sp)          # restore s3 from stack
    lw s2, 4(sp)          # restore s2 from stack
    lw s1, 8(sp)          # restore s1 from stack
    lw s0, 12(sp)         # restore s0 from stack
    lw ra, 16(sp)         # restore return address from stack
    addi sp, sp, 20       # deallocate space on stack
    ret

lightLED:
    addi sp, sp, -12      # allocate space on stack
    sw ra, 8(sp)          # save return address on stack
    sw a0, 4(sp)          # save a0 on stack
    sw a1, 0(sp)          # save a1 on stack

    # call lightColor to get the color
    jal ra, lightColor

    # retrieve the color from a0
    mv t2, a0

    # LED control code
    li t1, 0x100          # LED code
    li t3, 0              # initialize t3
    lw a0, 0(sp)          # load x value from stack
    lw a1, 4(sp)          # load y value from stack
    slli t3, a1, 16       # shift y value left by 16 bits
    or t3, t3, a0         # combine x and y

    # set a0-a2 for ecall
    mv a0, t1             # LED code
    mv a1, t3             # (x, y) location
    mv a2, t2             # color

    # turn on the LED
    ecall

    lw a1, 0(sp)          # restore a1 from stack
    lw a0, 4(sp)          # restore a0 from stack
    lw ra, 8(sp)          # restore return address from stack
    addi sp, sp, 12       # deallocate space on stack
    ret

lightColor:
    # load the word from grid
    mv t3, t0

    # extract the color from the grid value
    srli t4, t3, 31       # shift the value to get the first bit
    beqz t4, gold         # if the bit is 0, it's gold
    beq t4, s6, red       # if the bit is 1, it's red

gold:
    li a0, 0xA89968       # Load the gold color
    ret

red:
    li a0, 0xBA0C2F       # Load the red color
    ret
