STD=
WARN= -Wall
# -O2, not -Os: at -Os GCC declines constant-divisor strength reduction, so the
# constant divisors in generate_digits() still emit DIV.  fpconv is 373 lines on
# a hot reply path (every RESP double); code size here is irrelevant and the
# divider stall is not.  See generate_digits() below.
OPT= -O2

R_CFLAGS= $(STD) $(WARN) $(OPT) $(DEBUG) $(CFLAGS)
R_LDFLAGS= $(LDFLAGS)
DEBUG= -g

R_CC=$(CC) $(R_CFLAGS)
R_LD=$(CC) $(R_LDFLAGS)

AR= ar
ARFLAGS= rcs

libfpconv.a: fpconv_dtoa.o
	$(AR) $(ARFLAGS) $@ $+

fpconv_dtoa.o: fpconv_dtoa.h fpconv_dtoa.c

.c.o:
	$(R_CC) -c  $< 

clean:
	rm -f *.o
	rm -f *.a


