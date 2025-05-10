#include "directory.h"
#include "inode.h"
#include "diskimg.h"
#include "file.h"
#include <stdio.h>
#include <string.h>
#include <assert.h>

/**
 * TODO
 */
int directory_findname(struct unixfilesystem *fs, const char *name,
  int dirinumber, struct direntv6 *dirEnt) {
  
  struct inode inp;
  if (inode_iget(fs, dirinumber, &inp) == -1) return -1;
  if (!(inp.i_mode & IFDIR)) return -1; // si no es un directorio
  
  int dirSize = inode_getsize(&inp);
  int numBlocks = (dirSize + DISKIMG_SECTOR_SIZE - 1) / DISKIMG_SECTOR_SIZE;
  
  for (int i = 0; i < numBlocks; i++) { 
    char blockData[DISKIMG_SECTOR_SIZE];
    int bytesRead = file_getblock(fs, dirinumber, i, blockData);
    if (bytesRead == -1) return -1;
    
    struct direntv6 *dirEnts = (struct direntv6 *) blockData;
    int numEntries = bytesRead / sizeof(struct direntv6);  
    
    for (int j = 0; j < numEntries; j++) {
    
      if (dirEnts[j].d_inumber == 0) continue; // skipeamos entradas vacías
      
      if (strcmp(dirEnts[j].d_name, name) == 0) {
        *dirEnt = dirEnts[j];
        return 0;
      }
    }
  }
  return -1;  
}
