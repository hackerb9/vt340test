#ifndef MEDIACOPY_H
#define MEDIACOPY_H

void setup_media_copy();
char *receive_media_copy();
void save_region_to_file(char *filename, int x1, int y1, int x2, int y2);

#endif //MEDIACOPY_H

