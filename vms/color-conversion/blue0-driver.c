/*
 * Color conversions, presuming that BLUE is at zero degrees, instead of RED.
 *
 * hackerb9 2024. CC:0, no rights reserved.
 *
 */

#define _GNU_SOURCE
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "color-conversion.h"

void usage_hls() {
  fprintf(stderr, "Usage:\n"
	  "	   hls <Hue> <Lightness> <Saturation>\n"
	  "\n"	  
	  "  Hue:        0 to 360° (blue is 0°, red is 120°, green is 240°)\n"
	  "  Lightness:  0 to 100%% (black 0%%, shades, pure color 50%%, tints, white 100%%)\n"
	  "  Saturation: 0 to 100%% (grayscale is 0%%, color is 100%%)\n"
	  );
  exit(0);
}

void usage_rgb() {
  fprintf(stderr, "Usage:\n"
	  "      rgb <Red> <Green> <Blue>\t (0.0 to 100%%)\n"
	  );
  exit(0);
}

void usage_hsv() {
  fprintf(stderr, "Usage:\n"
  	  "	hsv <Hue> <Saturation> <Value>\n"
	  "\n"	  
	  "  Hue:        0 to 360° (blue is 0°, red is 120°, green is 240°)\n"
	  "  Saturation: 0 to 100%% (grayscale is 0%%, color is 100%%)\n"
	  "  Value:      0 to 100%% (black is 0%%, full brightness is 100%%)\n"
	  );
  exit(0);
}

void usage(char *cmd) {
  if ( strcmp("blue0hls", cmd) == 0) usage_hls();
  if ( strcmp("blue0rgb", cmd) == 0) usage_rgb();
  if ( strcmp("blue0hsv", cmd) == 0) usage_hsv();
  fprintf(stderr, "Error: This binary should be named blue0hls, blue0rgb, or blue0hsv.\n");
  exit(0);
}

static void  showsixel(int h, int l, int s, int r, int g, int b){
  /* Show both HLS and RGB, which should be exactly the same if the
     terminal is doing the right thing. (Not all of them do.) */
  int width=60; int height6=10;
  printf("\x1BP9;1;0q");
  printf("#0;1;%d;%d;%d#0", h, l, s);
  printf("#1;2;%d;%d;%d#1", r, g, b);
  char *row;
  asprintf(&row,"!120?#0!%d~!150?#1!%d~", width, width);
  while (--height6)
    printf("%s-", row);
  printf(row);
  free(row);
  printf("\x1B\\\n");
}

int main(int argc, char *argv[]) {
  float x, y, z;	/* Input */
  float h, l, s;	/* Hue, Lightness, Saturation */
  float h2, s2, v;	/* Hue, Saturation, Value */
  float r, g, b;	/* Red, Green, Blue */

  /* Get the basename */
  char *p=argv[0];
  while (*p) p++;
  while (--p>argv[0]) {
    if (*p=='/') { p++; break; }
  }
  argv[0] = p;

  if (argc<4) usage(argv[0]);

  sscanf(argv[1], "%f", &x);
  sscanf(argv[2], "%f", &y);
  sscanf(argv[3], "%f", &z);

  if ( strcmp("blue0hls", argv[0]) == 0) {
    h=x-120; l=y/100; s=z/100;
    HLS_to_RGB(&h, &l, &s, &r, &g, &b);
    RGB_to_HSV(&r, &g, &b, &h2, &s2, &v);
    h=h+120;
    h2=h2+120;
  }
  else if ( strcmp("blue0rgb", argv[0]) == 0) {
    r=x/100; g=y/100; b=z/100;
    RGB_to_HLS(&r, &g, &b, &h, &l, &s);
    h=h+120;
    RGB_to_HSV(&r, &g, &b, &h2, &s2, &v);
    h2=h2+120;
  }
  else if ( strcmp("blue0hsv", argv[0]) == 0) {
    h2=x-120; s2=y/100; v=z/100;
    HSV_to_RGB(&h2, &s2, &v, &r, &g, &b);
    h2=h2+120;
    RGB_to_HLS(&r, &g, &b, &h, &l, &s);
    h=h+120;
  }
  else {
    usage(argv[0]);
  }
  while (h<0.0)   h+=360.0;
  while (h2<0.0) h2+=360.0;

  while (h>=360.0)   h-=360.0;
  while (h2>=360.0) h2-=360.0;

  printf("       Hue: %6.2f°\t", h);
  printf("    Red: %6.2f%%\t", r*100);
  printf("       Hue: %6.2f°\n", h2);

  printf(" Lightness: %6.2f%%\t", l*100);
  printf("  Green: %6.2f%%\t", g*100);
  printf("Saturation: %6.2f%%\n", s2*100);

  printf("Saturation: %6.2f%%\t", s*100);
  printf("   Blue: %6.2f%%\t", b*100);
  printf("     Value: %6.2f%%\n", v*100);

  showsixel(h, l*100, s*100, r*100, g*100, b*100);
  return 0;
}
