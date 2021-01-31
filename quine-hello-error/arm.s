@import std;int main(){auto s="@import std;int main(){auto s=%c%s%1$c;printf(s,34,s,R%1$c(%3$s)%1$c,10);}%4$c";printf(s,34,s,R"(
.macro instruction x;.print "Hello, World!";.endm@)",10);}
t.:1: error: parser: instruction expected
