extern int printd(int i);

int main(int a) {
  int i;
  for ( i = 0; i < 1000; i = i+1 ) {
    printd(i);
  }
  return 0;
}
