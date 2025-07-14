.syntax unified
.global main


.type main, %function
main:
  bl init_leds
  ldr r0, =cap_I
@SysTick Setup
  ldr r4, =ADR_SYST_CSR
  mov r5, #0
  @Enable Timer
  mov r0, r4
  mov r1, r5
  mov r2, #0
  bl set_bit
  @Set interrupt status to pending
  mov r0, r4
  mov r1, r5
  mov r2, #1
  bl set_bit
  @Use internal timer
  mov r0, r4
  mov r1, r5
  mov r2, #2
  bl set_bit
  @set time
  ldr r0, =ADR_SYST_RVR
  ldr r2, =2097152 @~30 Hz
  str r2, [r0]
  @init picture
  ldr r0, =picture
  ldr r1, =textstart
  mov r2, #0
  mov r3, #0
  bl render_text
  @Load in pictures adress
  ldr r4, =picture
loop:
  mov r0, r4
  bl flash_picture
  b loop

.type move_frame, %function
@will move the current frame of the texts to the right by one column
move_frame:
  push {lr}
  ldr r0, =textcolumn
  ldr r1, [r0]
  add r1, #1
  cmp r1, #5 
  bne move_frame_if_1_else @Check if the column we are showing has reached 5
  move_frame_if_1_start:
    mov r1, #0 @If so set to 0 store and increment the character we are showing
    str r1, [r0]
    ldr r0, =textletter
    ldr r2, [r0]
    add r2, #1
    ldr r3, =textlength
    ldr r3, [r3]
    cmp r2, r3
    blt move_frame_if_2_end @check if we are at the end of the array
move_frame_if_2_start:
      mov r2, #0 @If so set the character to 0
move_frame_if_2_end:
    str r2, [r0]
    b move_frame_if_1_end
move_frame_if_1_else:
    str r1, [r0]
move_frame_if_1_end:
  mov r3, r1
  ldr r0, =textletter
  ldr r2, [r0]
  ldr r1, =textstart
  ldr r0, =picture
  bl render_text @Create a new picture frame based on these values. 
  pop {lr}
  bx lr
.size move_frame, . - move_frame

.global SysTick_Handler
.type SysTick_Handler, %function
@Handler for timeout
@Will will move the text one column to the right every **20** frame
SysTick_Handler:
  push {r0-r3, lr}
  ldr r0, =frame
  ldr r1, [r0]
  add r1, #1
  cmp r1, #20
  bne SysTick_Handler_if_else
  SysTick_Handler_if_start:
    mov r1, #0
    str r1, [r0]
    bl move_frame
    b SysTick_Handler_if_end
  SysTick_Handler_if_else:
    str r1, [r0]
  SysTick_Handler_if_end:
  pop {r0-r3, lr}
  bx lr
.size SysTick_Handler, . - SysTick_Handler

.data
frame:
.word 0
picture:
.byte 0x00, 0xFF, 0x00, 0xFF, 0x00
.byte 0xFF, 0x80, 0xFF, 0x80, 0xFF
.byte 0xFF, 0x80, 0x80, 0x80, 0xFF
.byte 0x00, 0xFF, 0x80, 0xFF, 0x00
.byte 0x00, 0x00, 0xFF, 0x00, 0x00
text:
textlength:
.word 17
textletter:
.word 0
textcolumn:
.word 0
textstart:
.byte 0x49, 0x20, 0x4C, 0x4F, 0x53, 0x54, 0x20, 0x54, 0x48, 0x45, 0x20, 0x47, 0x41, 0x4D, 0x45, 0x3A, 0x28 