  /* FIR filter peripheral
*/

#include "fir_filt.h"

/*void fir_filt_reset(uint32_t data){
  FIR_FILT_CTRL-> reset = data;
}

void fir_filt_enable(uint32_t data){
  FIR_FILT_CTRL-> enable = data;
}*/

void fir_filter_coefficient0(uint32_t coefficient){

    FIR_FILT_CTRL-> coef0 = coefficient;
  
}

void fir_filter_coefficient1(uint32_t coefficient){

    FIR_FILT_CTRL-> coef1 = coefficient;
  
}

void fir_filter_coefficient2(uint32_t coefficient){

    FIR_FILT_CTRL-> coef2 = coefficient;
  
}

void fir_filter_coefficient3(uint32_t coefficient){

    FIR_FILT_CTRL-> coef3 = coefficient;
  
}

uint32_t fir_filt_get_output(){
  return (FIR_FILT_OUT);
}