#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "user.h"

long
main(int argc, char *argv[])

{
    printf("---------------------------------\n");
    printf("xv6 system memory: ");
    printf("%d byte.\n", 128*1024*1024);
    printf("xv6 free   memory: ");
    printf("%d byte.\n",kfreemem());
    printf("xv6 busy   memory: ");
    printf("%d    byte.\n",128*1024*1024-kfreemem());
    printf("---------------------------------\n");

    exit(0);

}