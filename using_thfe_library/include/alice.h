#ifndef ALICE_H
#define ALICE_H

#include <tfhe/tfhe.h>
#include <tfhe/tfhe_io.h>

void generate_keys(char* dir_secret_key, char* dir_cloud_key);
void encrypt(char* dir_secret, int16_t plaintext1, int16_t plaintext2, char* dir_encrypted_data);
void decrypt(char* dir_secret_key, char* dir_encrypted_data, char* dir_decrypted_data); 

#endif /* ALICE_H */
