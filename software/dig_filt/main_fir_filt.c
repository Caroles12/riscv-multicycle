/* 
	fir filter peripheral
*/

#include "fir_filt.h"
#include "../gpio/gpio.h"

int main(){
		
	//fir_filt_enable(1);						// habilitada filtro
	
	int coefficient0 = 1;
	int coefficient1 = 2;
	int coefficient2 = 3;
	int coefficient3 = 4;
	
	//uint32_t coefficients[4] = {1,2,3,4};
			
	uint32_t data = 0;
	
	uint32_t vetor_dados[2];
	
	fir_filter_coefficient0(coefficient0);
    fir_filter_coefficient1(coefficient1);
    fir_filter_coefficient2(coefficient2);
    fir_filter_coefficient3(coefficient3);

	while (1){
	   
	   //fir_filter_coefficients(coefficients);

        /* Read input bus */
        //if (INBUS)
            /* Resets data when any input is high */
           // data = 0;


        //SEGMENTS_BASE_ADDRESS = fir_filt_get_output();  // get output function
      vetor_dados[0] = FIR_FILT_CTRL -> dado1;
      vetor_dados[1] = FIR_FILT_CTRL -> dado2;
        
        //OUTBUS = data;
		
		//data++;
		      
		//delay_(100000);						// for human interaction
		
	
	}

	return 0;
}
