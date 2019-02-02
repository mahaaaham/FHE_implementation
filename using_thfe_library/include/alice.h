#ifndef ALICE_H
#define ALICE_H

#include <tfhe/tfhe.h>
#include <tfhe/tfhe_io.h>

void generate_keys(FILE* secret_key, FILE* cloud_key);
void encrypt(FILE* secret, int16_t plaintext1, int16_t plaintext2, FILE* encrypted_data);
void decrypt(FILE* secret_key, FILE* encrypted_data, FILE* decrypted_data); 

#endif /* ALICE_H */
