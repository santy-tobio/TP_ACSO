#include <stdio.h>
#include <assert.h>
#include <stdlib.h>
#include "inode.h"
#include "diskimg.h"
#include "math.h"

#define INODES_PER_SECTOR 16
#define BLOCKS_PER_INDIRECT 256

/**
 * TODO
 */
// esta primero
int inode_iget(struct unixfilesystem *fs, int inumber, struct inode *inp) {
    // el bloque tiene 512 bytes
    // tengo 512/32 inodes en cada bloque = 16 inodes x bloque
    // los inodes arrancan en el bloque [2] 
    // para calcular el bloque esta mi iNode hago iNumber/16 
    // luego hago iNumber % 16 para saber qué numero de iNode del bloque es 
    // los iNodes están indexados desde 1 
    int maxInodes = fs->superblock.s_isize * INODES_PER_SECTOR;
    if (inumber < 1 || inumber > maxInodes) return -1;
    
    int bloqNum = 2 + (inumber-1) / INODES_PER_SECTOR; 
    int iNodeIndex = (inumber-1) % INODES_PER_SECTOR; 
    
    char iNodeSectorData[DISKIMG_SECTOR_SIZE]; 
    if (diskimg_readsector(fs->dfd, bloqNum, iNodeSectorData) == -1) return -1;
    
    struct inode* iNodesData = (struct inode*) iNodeSectorData;
    *inp = iNodesData[iNodeIndex];
    return 0; 
}

/**
 * TODO
 */
// esta segundo
int inode_indexlookup(struct unixfilesystem *fs, struct inode *inp,
    int blockNum) {  
    
    int fileSize = inode_getsize(inp);
    int totalBlocks = (fileSize + DISKIMG_SECTOR_SIZE - 1) / DISKIMG_SECTOR_SIZE;
    if (blockNum < 0 || blockNum >= totalBlocks) return -1;
    if (inp->i_mode & ILARG) { //como el archivo es grande hay que usar indirección
        
        if (blockNum < 7* BLOCKS_PER_INDIRECT) { // indirección simple (usando i_addr[0] a i_addr[6])
            int blockAddr = blockNum / BLOCKS_PER_INDIRECT;
            int blockIndex = blockNum % BLOCKS_PER_INDIRECT;
            char iNodeSectorData[DISKIMG_SECTOR_SIZE]; 
            if (diskimg_readsector(fs->dfd, inp->i_addr[blockAddr], iNodeSectorData) == -1) return -1;
            uint16_t* indirectBlock = (uint16_t*) iNodeSectorData;  
            return indirectBlock[blockIndex];
        } 
        
        else if (blockNum < 7*BLOCKS_PER_INDIRECT + BLOCKS_PER_INDIRECT*BLOCKS_PER_INDIRECT) { //indirección doble
            int relativeBlock = blockNum - 7*BLOCKS_PER_INDIRECT;  // normalizo el bloque
            int level1Index = relativeBlock / BLOCKS_PER_INDIRECT;  // puntero del bloque de nivel 1
            int level2Index = relativeBlock % BLOCKS_PER_INDIRECT;  // puntero del bloque de nivel 2
            char iNodeSectorData[DISKIMG_SECTOR_SIZE];
            if (diskimg_readsector(fs->dfd, inp->i_addr[7], iNodeSectorData) == -1) return -1;
            uint16_t* indirectBlock = (uint16_t*) iNodeSectorData;
            char iNodeSectorData2[DISKIMG_SECTOR_SIZE];
            if (diskimg_readsector(fs->dfd, indirectBlock[level1Index] , iNodeSectorData2) == -1) return -1;
            uint16_t* indirectBlock2 = (uint16_t*) iNodeSectorData2;
            return indirectBlock2[level2Index]; 
        } 
        
        return -1; 
    } 

    if (blockNum < 8) return inp->i_addr[blockNum];
    return -1;
}

int inode_getsize(struct inode *inp) {
  return ((inp->i_size0 << 16) | inp->i_size1); 
}