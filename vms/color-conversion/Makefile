CFLAGS+=-g -fsanitize=address -Wall -pedantic
LDFLAGS+=-lasan

all: hls rgb hsv

hls: color-driver.c color-conversion.c color-conversion.h
	${CC} ${CFLAGS} -o hls $^ ${LDFLAGS}

rgb: hls
	cp hls rgb

hsv: hls
	cp hls hsv

clean:
	rm hls hsv rgb 2>/dev/null || true
