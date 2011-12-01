
#include <stdio.h>
#include <math.h>
#include <stdint.h>

void av_dbl2int(double d, int64_t *target){
    int64_t val;
    int e;
    if     ( !d) val = 0;
    else if(d-d) val = 0x7FF0000000000000LL + ((int64_t)(d<0)<<63) + (d!=d);
    else {
        d= frexp(d, &e);
        val =  (int64_t)(d<0)<<63 | (e+1022LL)<<52 | (int64_t)((fabs(d)-0.5)*(1LL<<53));
    }
    fprintf(stdout, "val = %lld\n", val);
    *target = val;
}
