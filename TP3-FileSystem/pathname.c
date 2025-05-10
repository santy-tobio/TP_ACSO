
#include "pathname.h"
#include "directory.h"
#include "inode.h"
#include "diskimg.h"
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <stdlib.h>

/**
 * TODO
 */
int pathname_lookup(struct unixfilesystem *fs, const char *pathname) {

    if (pathname == NULL || pathname[0] == '\0') return -1; // si no hay pathname
    if (strcmp(pathname, "/") == 0) return ROOT_INUMBER;
    if (pathname[0] != '/') return -1; // si no es absoluto
    
    char *path = strdup(pathname);
    char *token = strtok(path, "/");
    int dirInumber = ROOT_INUMBER; // el directorio raíz

    while (token != NULL) {
        struct direntv6 dirEnt;
        if (directory_findname(fs, token, dirInumber, &dirEnt) == -1) {
            free(path);
            return -1; // si no se encuentra el nombre
        }
        dirInumber = dirEnt.d_inumber;
        token = strtok(NULL, "/");
    }

    free(path);
    return dirInumber;
}
