.syntax unified

.global arithmatic_div
.type arithmatic_div, %function
@perfomrs arithmetic division return qoutient and remainder
@args:
@   r0: numerator
@   r1: divisor
@ret:
@   r0: qoutient
@   r1: remainder
arithmatic_div:
    push {r4 - r9, lr}
    mov r4, r0
    mov r5, r1
    mov r6, #0
    mov r7, #0
    mov r8, #0
    mov r9, #0
arithmatic_div_for_loop_1_begin:
    mov r0, r4
    bl most_sig_bit
    mov r6, r0
    mov r0, r5
    bl most_sig_bit
    mov r7, r0
    subs r6, r7 @r7:= sig bit of numerator - divisor
    ble arithmatic_div_for_loop_1_end
    mov r8, #1
    lsl r8, r6 @r8:= 2^(sig bit of numerator - divisor)
    add r9, r8 @qoutient += 2^(sig bit of numerator - divisor)
    mul r8, r5 
    sub r4, r8
    b arithmatic_div_for_loop_1_begin 
arithmatic_div_for_loop_1_end:
arithmatic_div_for_loop_2_begin:
    cmp r4, r5
    ble arithmatic_div_for_loop_2_end
    sub r4, r5
    add r9, #1
    b arithmatic_div_for_loop_2_begin
arithmatic_div_for_loop_2_end:
    mov r0, r9
    mov r1, r4
    pop {r4 - r9, lr}
    bx lr
.size arithmatic_div, . - arithmatic_div

.global most_sig_bit
.type most_sig_bit, %function
@return the most significant bit == smallest power of two it is smaller than
@args:
@   r0: value
@ret:
@   r0: most significant bit
most_sig_bit:
    ldr r1, =(1 << 32)
    mov r2, #32
most_sig_bit_for_loop_begin:
    tst r1, r0
    bne most_dig_bit_for_loop_end
    lsr r1, #1
    sub r2, #1
    b most_sig_bit_for_loop_begin
most_dig_bit_for_loop_end:
    mov r0, r2
    bx lr
.size most_sig_bit, . - most_sig_bit