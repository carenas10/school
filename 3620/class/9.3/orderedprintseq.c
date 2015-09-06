#include <stdio.h>

int main(int argc, char *argv[]){
  int i, size;
  size = 4;
  for (i = 0; i < size; i++){
    FILE *f = fopen("output.txt","a+");
    fprintf(f,"Record of employee %d\n", i);
    fclose(f);
  }
  return 0;
}

