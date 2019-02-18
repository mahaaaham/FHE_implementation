#ifndef CLOUD_H
#define CLOUD_H

#include <tfhe/tfhe.h>
#include <tfhe/tfhe_io.h>

/* apply h_function to the 2 16 bits ciphers written in DIR_INPUT_DATA */
/* and write the result in DIR_OUTPUT_DATA, using the cloud_key  */
/* stocked in DIR_CLOUD_KEY */
void apply_h_function(char* dir_cloud_key, char* dir_input_data, 
		      char* dir_output_data,
    	              void (*h_function)(LweSample*, const LweSample*, 
				      const LweSample*, 
			              const TFheGateBootstrappingCloudKeySet*));

#endif /* CLOUD_H */
