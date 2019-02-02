#ifndef HOMOMORPHIC_FUNCTIONS_H
#define HOMOMORPHIC_FUNCTIONS_H

#include <tfhe/tfhe.h>
#include <tfhe/tfhe_io.h>

/* result becomes the minimum of a and b that are 2 multibits ciphers 
   of 16 bits */
void minimum(LweSample* result, const LweSample* a, const LweSample* b, 
	     const TFheGateBootstrappingCloudKeySet* bk); 

/* result becomes the sum of a and b that are 2 multibits ciphers 
   of 16 bits */
void sum(LweSample* result, const LweSample* a, const LweSample* b, 
	 const TFheGateBootstrappingCloudKeySet* bk);

#endif /* HOMOMORPHIC_FUNCTIONS_H */
