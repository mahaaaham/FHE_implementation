#include <example_communication.h>
#include <alice.h>
#include <cloud.h>
#include <homomorphic_functions.h>

#include <stdlib.h>

#define DIR_SECRET_KEY "../data/secret.key"
#define DIR_CLOUD_KEY "../data/cloud.data"
#define DIR_ENCRYPTED_INPUT "../data/encrypted_arg.data"
#define DIR_ENCRYPTED_OUTPUT "../data/encrypted_result.data"
#define DIR_DECRYPTED_OUTPUT "../data/decrypted_output.data"

int 
main()
{
    /* Alice encrypt the arguments in DIR_ENCRYPTED_INPUT */
    FILE *secret_key = NULL;  
    FILE *cloud_key = NULL; 
    FILE *encrypted_input = NULL; 
    FILE *encrypted_output = NULL;
    FILE *decrypted_output = NULL;


     secret_key = fopen(DIR_SECRET_KEY, "wb");
     cloud_key = fopen(DIR_CLOUD_KEY, "wb");
     encrypted_input = fopen(DIR_CLOUD_KEY, "wb");

    int16_t plaintext1 = 1;
    int16_t plaintext2 = 100;

    generate_keys(secret_key, cloud_key);
    encrypt(secret_key, plaintext1, plaintext2, encrypted_input);

    fclose(secret_key);
    fclose(cloud_key);
    fclose(encrypted_input);

    /* The cloud takes the encrypted arguments, apply a circuit  */
    /* and write the encrypted result in DIR_ENCRYPTED_OUTPUT */

    encrypted_input = fopen(DIR_ENCRYPTED_INPUT, "rb");
    cloud_key = fopen(DIR_CLOUD_KEY, "rb");

    apply_h_function(cloud_key, encrypted_input, encrypted_output, minimum);

    fclose(cloud_key);
    fclose(encrypted_input);


    /* Alice takes the encrypted_output, decrypts it en write the result in */ 
    /* decrypted_output */

    encrypted_output = fopen(DIR_ENCRYPTED_OUTPUT, "rb");
    decrypted_output = fopen(DIR_DECRYPTED_OUTPUT, "wb");

    decrypt(secret_key, encrypted_output, decrypted_output); 

    fclose(encrypted_output);
    fclose(decrypted_output);

    return EXIT_SUCCESS;
}
