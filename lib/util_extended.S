@ Utility functions and symbols
.syntax unified
@ --------------------- Module Interface --------------------

@ Function exports:
.global write_bits

@ --------------------- Implementation --------------------

.type write_bits, %function
@Will write the width of the data onto the data at address begining from bit index
@ --parameters--
@ r0: address
@ r1: bit index
@ r2: data
@ r3: width of data from LSB to include
write_bits:
  push {r4, r5, lr}
  ldr r5, [r0] @data
  ldr r4, =0xFFFFFFFF @Bit mask
  lsr r2, r2, r1 @prune right edge off of data
  lsr r4, r4, r1 @prune off bit mask too
  rsb r3, #32  @how much to shift to left to remove left side
  lsl r2, r2, r3
  lsl r4, r4, r3
  sub r3, r1 @how much to shift to the right to get m=back to original postion
  lsr r2, r2, r3
  lsr r4, r4, r3
  bic r5, r4
  orr r5, r2
  str r5, [r0]
  pop {r4, r5, lr}
  bx lr
.size write_bits, . - write_bits