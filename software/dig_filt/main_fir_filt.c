/* 
	fir filter peripheral
*/

#include "fir_filt.h"
#include "../gpio/gpio.h"
#include <stdio.h>

int main(){
	uint32_t data = 0;
	
    printf("entrou");
	fir_filt_enable(1);						// habilitada filtro
	
	int i;
	
	int coefficients[4] = {1,2,3,4};
	
	for (i = 0 ; i <= 3 ; i++)
	{
	       fir_filter_coefficients(coefficients[i]);
	}

	while (1){

        /* Read input bus */
        if (INBUS)
            /* Resets data when any input is high */
            data = 0;


        SEGMENTS_BASE_ADDRESS = fir_filt_get_output();  // get output function
        OUTBUS = data;
		
		data++;
		      
		//delay_(100000);						// for human interaction
		
	
	}

	return 0;
}
