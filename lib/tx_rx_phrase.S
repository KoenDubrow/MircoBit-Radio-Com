.syntax unified

@Function to set up radio use parameter
.type set_up_radio, %function
set_up_radio:
    nop
    bx lr
.size set_up_radio, . - set_up_radio


@Function to send a word in a packet form
