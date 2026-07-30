pkg load signal
a=[1 -5 4];
b=[1 -2];
n=[0:10];
x=[(1/2).^n];
z=filtic(b,a,[1]);
[y,zf]=filter(b,a,x,z);
stem(n,y)
