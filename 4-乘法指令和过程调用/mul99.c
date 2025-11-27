#include <stdio.h>

int main(){
    for(int left = 9;left>0;left--){
        for (int right = 1;right <=left;right++){
            int re = left * right;
            printf("%d * %d = %d   ",left,right,re);
        }
        printf("\n");
    }
    printf("\n");
    return 0;
}
