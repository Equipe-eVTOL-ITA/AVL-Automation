%inputs
force = [3 3 3 3 2 1 0];
pos = [0 1 2 3 4 5 6];
E = 1;
rho = 1;
r1 = 1;
r2 = 2;

%other parameters
moment = force.*pos;
L = max(pos);
m = 4*pi^2*(r2^2-r1^2)*L*rho;
I = (1/12)*m*(3*(r2^2+r1^2)+L^2); 

%polynomial approximation 
p = polyfit(pos, moment, 3);

%integration and substitution (EIv'' = M)
syms x
p_sym = poly2sym(p,x);
p_deflex = int(int(p_sym,x),x);
x_lin = linspace(0,L,1000);
deflex = double(subs(p_deflex,x,x_lin))/(E*I);

%outputs

%polynomial approximation comparison
figure(1)
hold on
plot(pos,moment)
plot(x_lin,polyval(p,x_lin))

%deflexion
figure(2)
hold on
plot(x_lin,deflex)

%maximum deflexion
fprintf("Max deflexion: %f\n", max(deflex));

