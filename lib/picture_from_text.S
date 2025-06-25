.syntax unified
.global render_text

.type render_text, %function
@Will create picture array to be displayed from an array of text
@args:
@   r0: the adress to store picture array
@   r1: the adress of array of ascii characters to draw  (byte array)
@   r2: the index of the ascii character in the array
@   r3: the column of this character to start from [0,5)
render_text:
    push {r4 - r8, lr}
    mov r4, r0
    mov r5, r1
    mov r6, r2
    mov r7, r3
    mov r8, #0 @for loop counter
render_text_for_loop_begin:
    cmp r8, #5
    beq render_text_for_loop_end
    mov r0, r4
    ldrb r1, [r5, r6]
    mov r2, r7
    mov r3, r8
    bl render_column
    add r8, #1
    add  r7, #1 @Need to wrap around if equal to 5
    cmp r7, #5
    bne render_text_for_loop_if_end
render_text_for_loop_if:
    mov r7, #0
    add r6, #1
render_text_for_loop_if_end:
    b render_text_for_loop_begin
render_text_for_loop_end:
    pop {r4 - r8, lr}
    bx lr
.size render_text, . - render_text

.type render_column, %function
@Will create just a collumn of a picture array from a given character
@args:
@   r0: picture array address
@   r1: ascii character (the code)
@   r2: column of ascii character
@   r3: column of the picture array
render_column:
    push {r4}
    @r4 := (r1 - ascii_offset) * 25 + ascii_start + r2
    ldr r4, =ascii_ref_offset
    ldr r4, [r4]
    sub r4, r1, r4
    mov r1, #25
    mul r4, r4, r1
    ldr r1, =ascii_ref_start
    add r4, r4, r1
    add r4, r2
    @r2 := r0 + r3
    add r2, r0, r3
    mov r3, #0 @for loop index/row
render_column_for_loop_start:
    cmp r3, #5
    beq render_column_for_loop_end

    ldrb r0, [r4] @retrieve the LED value from the ascii character
    strb r0, [r2]

    add r4, #5
    add r2, #5
    add r3, #1
    b render_column_for_loop_start
render_column_for_loop_end:
    pop {r4}
    bx lr
.size render_column, . - render_column