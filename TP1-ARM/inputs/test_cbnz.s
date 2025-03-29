// test_cbnz.s
// Test cases for CBNZ instruction

.text
// Test case 1: Standard case - branch should not be taken
movz X1, 0         // X1 = 0
cbnz X1, branch1   // Should not branch
movz X2, 2         // Should be executed
branch1:
movz X3, 3         // X3 = 3

// Test case 2: Branch should be taken
movz X4, 5         // X4 = 5
cbnz X4, branch2   // Should branch to branch2
movz X10, 10       // Should be skipped
branch2:
movz X5, 5         // X5 = 5

// Test case 3: Test with result of computation
movz X6, 15        // X6 = 15
movz X7, 10        // X7 = 10
subs X8, X6, X7    // X8 = 5, Z=0
cbnz X8, branch3   // Should branch to branch3
movz X11, 11       // Should be skipped
branch3:
movz X9, 9         // X9 = 9

// Test case 4: Test with negative value
movz X12, 0xFFFF   // X12 = 65535
subs X12, X12, X12 // X12 = 0, Z=1
cbnz X12, branch4  // Should not branch
movz X13, 13       // Should be executed
branch4:
movz X14, 14       // X14 = 14

// Test case 5: Test with negative result
movz X15, 10       // X15 = 10
movz X16, 15       // X16 = 15 
subs X17, X15, X16 // X17 = -5, N=1, Z=0
cbnz X17, branch5  // Should branch to branch5
movz X19, 19       // Should be skipped
branch5:
movz X18, 18       // X18 = 18

HLT 0