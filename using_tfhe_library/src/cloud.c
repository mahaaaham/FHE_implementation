#include <homomorphic_functions.h>


void
apply_h_function(char* dir_cloud_key, char* dir_input_data, char* dir_output_data,
	         void (*circuit)(LweSample*, const LweSample*, const LweSample*, 
		  	         const TFheGateBootstrappingCloudKeySet*))
{
    FILE* cloud_key = fopen(dir_cloud_key, "rb");
    FILE* input_data = fopen(dir_input_data, "rb");
    FILE* output_data = fopen(dir_output_data, "wb");

    /* reads the cloud key from file */
    TFheGateBootstrappingCloudKeySet* bk = new_tfheGateBootstrappingCloudKeySet_fromFile(cloud_key);
 
    /* if necessary, the params are inside the key */
    const TFheGateBootstrappingParameterSet* params = bk->params;

    /* read the 2x16 ciphertexts */
    LweSample* ciphertext1 = new_gate_bootstrapping_ciphertext_array(16, params);
    LweSample* ciphertext2 = new_gate_bootstrapping_ciphertext_array(16, params);

    /* ads the 2x16 ciphertexts from the cloud file */
    for (int i=0; i<16; i++) import_gate_bootstrapping_ciphertext_fromFile(input_data, &ciphertext1[i], params);
    for (int i=0; i<16; i++) import_gate_bootstrapping_ciphertext_fromFile(input_data, &ciphertext2[i], params);

    /* Apply the circuit on the 2 cipher texts */ 
    LweSample* result = new_gate_bootstrapping_ciphertext_array(16, params);
    circuit(result, ciphertext1, ciphertext2, bk);

    /* export the result 16 ciphertexts to a file (for the cloud) */
    for (int i=0; i<16; i++) export_gate_bootstrapping_ciphertext_toFile(output_data, &result[i], params);

    /* close open files */
    fclose(cloud_key);
    fclose(input_data);
    fclose(output_data);

    /* clean up all pointers */
    delete_gate_bootstrapping_ciphertext_array(16, result);
    delete_gate_bootstrapping_ciphertext_array(16, ciphertext2);
    delete_gate_bootstrapping_ciphertext_array(16, ciphertext1);
    delete_gate_bootstrapping_cloud_keyset(bk);

    return;
}

