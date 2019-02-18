#include <alice.h>
#include <cloud.h>
#include <homomorphic_functions.h>

#include <stdlib.h>


#define DIR_SECRET_KEY "data/secret.key"
#define DIR_CLOUD_KEY "data/cloud.data"
#define DIR_ENCRYPTED_INPUT "data/encrypted_arg.data"
#define DIR_ENCRYPTED_OUTPUT "data/encrypted_result.data"
#define DIR_DECRYPTED_OUTPUT "data/decrypted_output.data"


/* ---- Global variables ---- */
/* 2 functions are disponibles: sum and minimum, 
   see homomorphic_functions.h */
void (*h_function)(LweSample*, const LweSample*, const LweSample*, 
		   const TFheGateBootstrappingCloudKeySet*) = minimum;
/* The 2 arguments that are encrypted and used by h_function */
const int16_t arg1 = 1234;
const int16_t arg2 = 1232;


int 
main()
{
  /* Alice */
  printf("Alice's turn:\n");
  printf("She creates parameters and puts in data/crypted.data the encryption\n"
	 "of the following plaintexts: %d, %d\n", 
	 arg1, arg2);
  generate_keys(DIR_SECRET_KEY, DIR_CLOUD_KEY);
  encrypt(DIR_SECRET_KEY, arg1, arg2, DIR_ENCRYPTED_INPUT);

  /* Cloud */
  printf("\nCloud's turn:\n");
  printf("It applies homomorphically a function on the 2 ciphers.\n");
  apply_h_function(DIR_CLOUD_KEY, DIR_ENCRYPTED_INPUT, DIR_ENCRYPTED_OUTPUT, 
		   h_function);

  /* Alice */
  printf("\nAlice's turn:\n");
  printf("She decrypts the result of the operation and writes it \nin %s.\n",
	 DIR_DECRYPTED_OUTPUT);
  decrypt(DIR_SECRET_KEY, DIR_ENCRYPTED_OUTPUT, DIR_DECRYPTED_OUTPUT); 

  /* We print the content of the file that contains the decrypted result */
  printf("\nThe result is: ");
  FILE* result = fopen(DIR_DECRYPTED_OUTPUT, "rt");
  char temp_char;
  while((temp_char = fgetc(result)) != EOF)
    {
      printf("%c", temp_char);
    }
  fclose(result);

  return EXIT_SUCCESS;
}
