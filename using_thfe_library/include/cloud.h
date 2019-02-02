#ifndef CLOUD_H
#define CLOUD_H

#include <tfhe/tfhe.h>
#include <tfhe/tfhe_io.h>

void apply_h_function(char* dir_cloud_key, char* dir_input_data, char* dir_output_data,
    	              void (*circuit)(LweSample*, const LweSample*, const LweSample*, 
			              const TFheGateBootstrappingCloudKeySet*));

#endif /* CLOUD_H */
