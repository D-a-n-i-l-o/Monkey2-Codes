# Realtime window resizing with mojox #

In this mojox (the Monkey2 gui) test we install a handler to check SDL window resize events.<br>
In this handler we update the Monkey2 window frame size and request rendering of the updated window.<br>
The handler prevents the stretching of the window content while resizing the window. The window content is updated in realtime.
