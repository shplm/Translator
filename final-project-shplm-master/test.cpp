#include <stdio.h>
#include <iostream>

using namespace std;

extern "C"{
	float foo();
}

int main(int argc, char const *argv[]) {
  float x = foo();
  printf("return from foo: %f\n",x);
  return 0;
}
