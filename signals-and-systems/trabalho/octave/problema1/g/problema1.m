pkg load signal
a = [1 -1/5];
b = [1];
n = [0:10];
x = [(1/4).^n];
z = filtic(b,a,[1]);
[y,zf] = filter(b,a,x,z);
stem(n,y);

