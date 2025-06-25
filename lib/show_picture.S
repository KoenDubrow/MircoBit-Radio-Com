.syntax unified
.global flash_picture

@An expansion of the LED Library allowing us to flash picture arrays on the Micro:Bit
@flash picture needs to be called in sequence to make the picture appear on the screen
.type flash_picture, %function
@flashes a picture on the LED based on LED array. Assumes all rows directions set to 1
@args:
@   r0: base address of array
flash_picture:
  push {r4, r5, lr}
  mov r4, r0
  mov r5, #0 @begin loop counter
flash_picture_for_loop:
  cmp r5, #5 @check if need to break for loop
  beq flash_picture_for_loop_end
  mov r0, r4
  mov r1, r5
  bl find_rows_in_Col @Find what rows need to be set to high in column
  mov r1, r0
  mov r0, r5
  bl show_col @show the column accordingly
  mov r0, r5
  bl clear_col @clear the column
  add r5, #1
  b flash_picture_for_loop
flash_picture_for_loop_end:
  pop {r4, r5, lr}
  bx lr
.size flash_picture, . - flash_picture

.type show_col, %function
@Will display a column on the LED
@args:
@   r0: column index
@   r1: LED states of rows: led states, least significant 5 bits where a 1 means led on, 0 means led off (bit<0> == row 1 (left), bit<4> == row 5 (right))
show_col:
  push {r4, lr}
  mov r4, r1 @mov values to prepare for function calling
  ldr r1, =OFS_GPIO_OUT
  mov r2, #0
  bl write_column_pin @turn on column
  mov r0, r4
  bl write_row_pins @Set the row pins out direction as specificied by args
  pop {r4, lr}
  bx lr
.size show_col, . - show_col

.type clear_col, %function
@will turn off a columns display
@args:
@   r0: column index
clear_col:
  push {lr}
  ldr r1, =OFS_GPIO_OUT 
  mov r2, #1
  bl write_column_pin  @set column direction to 1
  mov r0, #0
  bl write_row_pins @Set the row pints out direction to 0
  pop {lr}
  bx lr
.size clear_col, . - clear_col

.type find_rows_in_Col, %function
@Will find which rows need to be on in a given column of LED array
@Sensitive to the clock in implementation of PWM
@args:
@   r0: basee address of array
@   r1: column index
@returns
@   r0: LED states of rows: led states, least significant 5 bits where a 1 means led on, 0 means led off (bit<0> == row 1 (left), bit<4> == row 5 (right))
find_rows_in_Col:
  push {r4 - r7, lr} 
  add r0, r1 @adress of row 0 in the column in the LED array
  mov r1, #0 @Set our for loop counter
  mov r3, #0 @Prepare out return value
  mov r4, 0b1 @Prepare bit setting value
  ldr r5, =ADR_SYST_CVR
  ldr r7, =0x3FFFF @bitmask for the clack value so that freuqncy of PWM ~240
find_rows_in_col_for_loop:
  cmp r1, #5 @check if we need to break for loop
  beq find_rows_in_col_end
  ldr r2, [r0] @load byte describing LED at this adress
  and r2, 0xFF @Could use read_bits in utils but this is simpler IMO
  ldr r6, [r5] @Get value the clock is at
  and r6, r7 @bitmask for the clack value so that freuqncy of PWM ~240
  lsr r6, r6, #10 @Scale down clock value to be byte sized
  cmp r2, r6 @find if it should be on
  ble find_rows_in_col_no_if
  orr r3, r4 @Setting bit in our return value to high if the LED should be on
find_rows_in_col_no_if:
  lsl r4, r4, #1 @Move bit setting value to where it should be for next row
  add r1, #1 @increment loop counter
  add r0, #5 @Increment adress to that of next row
  b find_rows_in_col_for_loop
find_rows_in_col_end:
  mov r0, r3
  pop {r4 - r7, lr} 
  bx lr
.size find_rows_in_Col, . - find_rows_in_Col
