#include <alice.h>

#include <stdio.h>


void
generate_keys(char* dir_secret_key, char* dir_cloud_key) 
{
    FILE* secret_key = fopen(dir_secret_key, "wb");
    FILE* cloud_key = fopen(dir_cloud_key, "wb");

    /* generate a keyset */
    const int minimum_lambda = 110;
    TFheGateBootstrappingParameterSet* params = new_default_gate_bootstrapping_parameters(minimum_lambda);

    /* generate a random key */
    uint32_t seed[] = { 314, 1592, 657 };
    tfhe_random_generator_setSeed(seed,3);
    TFheGateBootstrappingSecretKeySet* key = new_random_gate_bootstrapping_secret_keyset(params);

    /* export the secret key to file for later use */
    export_tfheGateBootstrappingSecretKeySet_toFile(secret_key, key);

    /* export the cloud key to a file (for the cloud) */
    export_tfheGateBootstrappingCloudKeySet_toFile(cloud_key, &key->cloud);

    /* close all files */
    fclose(secret_key);
    fclose(cloud_key);
   
    /* clean up all pointers */
    delete_gate_bootstrapping_parameters(params);

    return;
}


void 
encrypt(char* dir_secret_key, int16_t plaintext1, int16_t plaintext2, char* dir_encrypted_data) 
{
    FILE* secret_key = fopen(dir_secret_key, "rb");
    FILE* encrypted_data = fopen(dir_encrypted_data, "wb");

    /* recuperation of the key in data/secret.key */
    TFheGateBootstrappingSecretKeySet* key = new_tfheGateBootstrappingSecretKeySet_fromFile(secret_key);

    /* if necessary, the params are inside the key */
    const TFheGateBootstrappingParameterSet* params = key->params;


    /* generate encrypt the 16 bits of plaintext1 */
    LweSample* ciphertext1 = new_gate_bootstrapping_ciphertext_array(16, params);
    for (int i=0; i<16; i++) {
        bootsSymEncrypt(&ciphertext1[i], (plaintext1>>i)&1, key);
    }

    /* generate encrypt the 16 bits of plainetxt2 */
    LweSample* ciphertext2 = new_gate_bootstrapping_ciphertext_array(16, params);
    for (int i=0; i<16; i++) {
        bootsSymEncrypt(&ciphertext2[i], (plaintext2>>i)&1, key);
    }

    /* export the 2x16 ciphertexts to a file (for the cloud) */
    for (int i=0; i<16; i++) 
        export_gate_bootstrapping_ciphertext_toFile(encrypted_data, 
						    &ciphertext1[i], params);
    for (int i=0; i<16; i++) 
        export_gate_bootstrapping_ciphertext_toFile(encrypted_data, 
						    &ciphertext2[i], params);

    /* close open files */
    fclose(encrypted_data);
    fclose(secret_key);

    /* clean up all pointers */
    delete_gate_bootstrapping_secret_keyset(key);
    delete_gate_bootstrapping_ciphertext_array(16, ciphertext2);
    delete_gate_bootstrapping_ciphertext_array(16, ciphertext1);
    return;
}


void
decrypt(char* dir_secret_key, char* dir_encrypted_data, char* dir_decrypted_data) 
{
    FILE* secret_key = fopen(dir_secret_key, "rb");
    FILE* encrypted_data = fopen(dir_encrypted_data, "rb");
    FILE* decrypted_data = fopen(dir_decrypted_data, "wb");

    /* reads the cloud key from file */
    TFheGateBootstrappingSecretKeySet* key = new_tfheGateBootstrappingSecretKeySet_fromFile(secret_key);
 
    /* if necessary, the params are inside the key */
    const TFheGateBootstrappingParameterSet* params = key->params;

    /* read the 16 ciphertexts */
    LweSample* to_decrypt = new_gate_bootstrapping_ciphertext_array(16, params);

    /* import the 32 ciphertexts from the answer file */
    for (int i=0; i<16; i++) 
        import_gate_bootstrapping_ciphertext_fromFile(encrypted_data, 
						      &to_decrypt[i], params);

    /* decrypt and rebuild the 16-bit plaintext answer */
    int16_t int_decrypted = 0;
    for (int i=0; i<16; i++) {
        int ai = bootsSymDecrypt(&to_decrypt[i], key);
        int_decrypted |= (ai<<i);
    }

    /* print the decryption on decrypted_data */
    fprintf(decrypted_data, "%d\n", int_decrypted);

    fclose(encrypted_data);
    fclose(decrypted_data);
    fclose(secret_key);

    /* clean up all pointers */
    delete_gate_bootstrapping_ciphertext_array(16, to_decrypt);
    delete_gate_bootstrapping_secret_keyset(key);

    return;
}
