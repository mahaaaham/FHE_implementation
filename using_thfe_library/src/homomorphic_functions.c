#include <homomorphic_functions.h>

/* Used by the minimum circuit: */
/* elementary full comparator gate that is used to compare the i-th bit: */
/*   input: ai and bi the i-th bit of a and b */
/*          lsb_carry: the result of the comparison on the lowest bits */
/*   algo: if (a==b) return lsb_carry else return b */ 
void 
compare_bit(LweSample* result, const LweSample* a, const LweSample* b, const LweSample* lsb_carry, 
	    LweSample* tmp, const TFheGateBootstrappingCloudKeySet* bk) 
{
  bootsXNOR(tmp, a, b, bk);
  bootsMUX(result, tmp, lsb_carry, a, bk);
  return;
}


// this function compares two multibit words, and puts the max in result
void 
minimum(LweSample* result, const LweSample* a, const LweSample* b, const TFheGateBootstrappingCloudKeySet* bk) 
{
  LweSample* tmps = new_gate_bootstrapping_ciphertext_array(2, bk->params);
  const int nb_bits = 16;
  
  //initialize the carry to 0
  bootsCONSTANT(&tmps[0], 0, bk);
  //run the elementary comparator gate n times
  for (int i=0; i<nb_bits; i++) 
    {
      compare_bit(&tmps[0], &a[i], &b[i], &tmps[0], &tmps[1], bk);
    }
  //tmps[0] is the result of the comparaison: 0 if a is larger, 1 if b is larger
  //select the max and copy it to the result
  for (int i=0; i<nb_bits; i++) 
    {
      bootsMUX(&result[i], &tmps[0], &b[i], &a[i], bk);
    }

  delete_gate_bootstrapping_ciphertext_array(2, tmps);    
  return;
}


void 
add_bit(LweSample* result, const LweSample* a, const LweSample* b, 
	LweSample* carry, LweSample* tmp, LweSample* tmp2, LweSample* tmp3,
	const TFheGateBootstrappingCloudKeySet* bk) 
{
  bootsXNOR(tmp, a, b, bk);
  bootsXNOR(result, tmp, carry, bk);

  bootsAND(tmp, a, b, bk);
  bootsAND(tmp2, a, carry, bk);
  bootsAND(tmp3, b, carry, bk);

  bootsOR(carry, tmp, tmp2, bk);
  bootsOR(carry, carry, tmp3, bk);
  return;
}

// this function make the sum of two multibit words, without taking care of the last carry
void 
sum(LweSample* result, const LweSample* a, const LweSample* b, const TFheGateBootstrappingCloudKeySet* bk) 
{
  const int nb_bits = 16;

  LweSample* tmps = new_gate_bootstrapping_ciphertext_array(4, bk->params);
  
  // initialize the carry to 0
  bootsCONSTANT(&tmps[0], 0, bk);

  // run the elementary comparator gate n times
  for (int i = 0; i < nb_bits; i++) 
    {
      add_bit(&result[i], &a[i], &b[i], 
	      &tmps[0], &tmps[1], &tmps[2], &tmps[3], bk);
    }

  delete_gate_bootstrapping_ciphertext_array(4, tmps);    
  return;
}
