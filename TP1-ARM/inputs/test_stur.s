.text
movz x0, 0x1000
lsl x0, x0, 16
movz x1, 0x20
stur x1, [x0, 0xf]

HLT 0
