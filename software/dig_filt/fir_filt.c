/* FIR filter peripheral
*/

#include "fir_filt.h"

void fir_filt_reset(uint32_t data){
  FIR_FILT_CTRL-> reset = data;
}

void fir_filt_enable(uint32_t data){
  FIR_FILT_CTRL-> enable = data;
}

void fir_filter_coefficients(uint32_t data){
  FIR_FILT_CTRL-> coefficients = data;
}

uint32_t fir_filt_get_output(){
  return (FIR_FILT_OUT);
}