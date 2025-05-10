#include <stdio.h>
#include <assert.h>
#include <stdlib.h>
#include "file.h"
#include "inode.h"
#include "diskimg.h"
#include "string.h"


/**
 * TODO
 */
int file_getblock(struct unixfilesystem *fs, int inumber, int blockNum, void *buf) {
    
    // primero fecheamos el inode
    struct inode inp;
    if (inode_iget(fs, inumber, &inp) == -1) return -1;
    if (!(inp.i_mode & IALLOC)) return -1; // si no está asignado el inode 
    
    // ahora busco el bloque y lo leo
    int blockAddr = inode_indexlookup(fs, &inp, blockNum); // esta función ataja el caso de que el bloque no exista
    if (blockAddr == -1) return -1;
    char blockData[DISKIMG_SECTOR_SIZE];
    if (diskimg_readsector(fs->dfd, blockAddr, blockData) == -1) return -1;
    
    // copio el bloque al buffer
    memcpy(buf, blockData, DISKIMG_SECTOR_SIZE);

    // calculamos cuantos bytes son "válidos" en el bloque, osea cuantos bytes son datos de mi archivo
    // chequemos si estoy en el último bloque y si esta parcialmente lleno, devolvemos el modulo, sino devuelvo el tamaño del bloque
    int fileSize = inode_getsize(&inp);
    return (blockNum == (fileSize - 1) / DISKIMG_SECTOR_SIZE && fileSize % DISKIMG_SECTOR_SIZE != 0) ? 
            fileSize % DISKIMG_SECTOR_SIZE : DISKIMG_SECTOR_SIZE;
}

