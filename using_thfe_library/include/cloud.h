#ifndef CLOUD_H
#define CLOUD_H

#include <tfhe/tfhe.h>
#include <tfhe/tfhe_io.h>

void apply_h_function(FILE* cloud_key, FILE* input_data, FILE* output_data,
    	              void (*circuit)(LweSample*, const LweSample*, const LweSample*, 
			              const TFheGateBootstrappingCloudKeySet*));

#endif /* CLOUD_H */
