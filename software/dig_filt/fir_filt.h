/* Digital filter peripheral 
*/
#ifndef _FIR_FILT
#define _FIR_FILT

#include "../_core/hardware.h"
#include "../_core/utils.h"

typedef struct {
  _IO32 enable :1 ;           /*!< Bit habilitação filto */
  _IO32 reset  :1 ;           /*!< Bit de filtro Habilitado. */
  _IO32 coefficients; 
} DIG_FIL_REG_TYPE;

#define FIR_FILT_CTRL ((DIG_FIL_REG_TYPE *) &FIR_FILT_BASE_ADDRESS )
#define FIR_FILT_OUT    *(&FIR_FILT_BASE_ADDRESS + 4)    


void fir_filt_reset(uint32_t);
void fir_filt_enable(uint32_t);
void fir_filter_coefficients(uint32_t);
uint32_t fir_filt_get_output();

#endif
