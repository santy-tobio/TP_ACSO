// test_cbz.s
// Test cases for CBZ instruction

.text
// Test case 1: Standard case - branch should be taken
movz X1, 0         // X1 = 0
cbz X1, branch1    // Should branch to branch1
movz X10, 10       // Should be skipped
branch1:
movz X2, 2         // X2 = 2

// Test case 2: Branch should not be taken
movz X3, 5         // X3 = 5
cbz X3, branch2    // Should not branch
movz X4, 4         // Should be executed
branch2:
movz X5, 5         // X5 = 5

// Test case 3: Test with result of computation
movz X6, 10        // X6 = 10
movz X7, 10        // X7 = 10
subs X8, X6, X7    // X8 = 0, Z=1
cbz X8, branch3    // Should branch to branch3
movz X11, 11       // Should be skipped
branch3:
movz X9, 9         // X9 = 9

// Test case 4: Test with negative value
movz X12, 0xFFFF   // X12 = 65535
cbz X12, branch4   // Should not branch
movz X13, 13       // Should be executed
branch4:
movz X14, 14       // X14 = 14

HLT 0