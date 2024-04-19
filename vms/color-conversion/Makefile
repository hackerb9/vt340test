CFLAGS+=-g -fsanitize=address -Wall -pedantic
LDFLAGS+=-lasan

all: hls rgb hsv blue0hls blue0rgb

hls: color-driver.c color-conversion.c color-conversion.h
	${CC} ${CFLAGS} -o hls $^ ${LDFLAGS}

rgb: hls
	cp hls rgb

hsv: hls
	cp hls hsv

blue0hls: blue0-driver.c color-conversion.c color-conversion.h
	${CC} ${CFLAGS} -o blue0hls $^ ${LDFLAGS}


blue0rgb: blue0hls
	cp blue0hls blue0rgb


.PHONY: clean
clean:
	rm hls hsv rgb 2>/dev/null || true
	rm blue0hls blue0hsv blue0rgb 2>/dev/null || true
