#include<stdio.h>

int main() {
    int n,sum=0;

    printf("Input (1-100): ");
    scanf("%d", &n); 

    for(int i=1; i<=n; i++) 
        sum += i;
    
    printf("Output: %d\n", sum);
    return 0;

}