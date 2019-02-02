#ifndef HOMOMORPHIC_FUNCTIONS_H
#define HOMOMORPHIC_FUNCTIONS_H

#include <tfhe/tfhe.h>
#include <tfhe/tfhe_io.h>

void minimum(LweSample* result, const LweSample* a, const LweSample* b, 
	     const TFheGateBootstrappingCloudKeySet* bk); 
void sum(LweSample* result, const LweSample* a, const LweSample* b, 
	 const TFheGateBootstrappingCloudKeySet* bk);

#endif /* HOMOMORPHIC_FUNCTIONS_H */
