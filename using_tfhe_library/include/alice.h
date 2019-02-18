#ifndef ALICE_H
#define ALICE_H

#include <tfhe/tfhe.h>
#include <tfhe/tfhe_io.h>

/* write the bit by bit encryption of the 2 plaintexts in */
/* DIR_ENCRYPTED_DATA using the secret_key stocked in DIR_SECRET_KEY */
void encrypt(char* dir_secret, int16_t plaintext1, int16_t plaintext2, 
	     char* dir_encrypted_data);

/* write in decimal in DIR_DECRYPTED_DATA the  decryption of the */
/* 16 bit cipher stocker in DIR_ENCRYPTED_DATA using the secret_key */ 
/* stocked in DIR_SECRET_KEY */
void decrypt(char* dir_secret_key, char* dir_encrypted_data, 
	     char* dir_decrypted_data);

/* write the secret_key and cloud_key in the corresponding DIR_FOO files */
void generate_keys(char* dir_secret_key, char* dir_cloud_key);

#endif /* ALICE_H */
