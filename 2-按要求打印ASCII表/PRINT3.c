#include <stdio.h>

int main(){
    const int perline = 13;
    const int lines = 2;

    char ch = 'a';
    for(int i = 0;i < lines;i++){
        for(int j = 0;j < perline;j++){
            putchar(ch++);
        }
        putchar('\r');
        putchar('\n');
    }

    return 0;
}