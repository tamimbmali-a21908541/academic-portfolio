pkg load signal

nx=0:10;
nh=0:10;

x=zeros(size(nx));
h=zeros(size(nh));

x(nx>=0) = (1/4).^nx(nx>=0);
h(nh>=0) = (1/5).^nh(nh>=0);

subplot(3,1,1)
stem(nx,x,'k','LineWidth',3)
title('x[n]')

subplot(3,1,2)
stem(nh,h,'k','LineWidth',3)
title('h[n]')

y=conv(x,h)

ninicio=nx(1) + nh(1);
nfim=nx(end) + nh(end);
ny=[ninicio:nfim];

subplot(3,1,3)
stem(ny,y,'k','LineWidth',3)
title('y[n]')
title('y[n]')