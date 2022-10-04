%% Inputs

name  = 'down_winglet';

S     = 0.575;
xCG   = 0.1;
MTOW  = 10;
nzmax = 2;
V     = 20;

g     = 9.81;
rho   = 1.0686;

%% Criação do .fs

W  = MTOW*g;
q  = 0.5*rho*V^2;
CL = W*nzmax/(q*S);

if exist(strcat(name,'.fs'), 'file') == 2
  delete(strcat(name,'.fs'));
end

run = fopen(strcat(name,'.run'),'W');
fprintf(run,'load %s.avl\n',name);
fprintf(run,'oper\n');
fprintf(run,'c2\n');
fprintf(run,'v %.3f\n',V);
fprintf(run,'m %.3f\n',MTOW);
fprintf(run,'d %.3f\n',rho);
fprintf(run,'g %.3f\n',g);
fprintf(run,'x %.3f\n',xCG);
fprintf(run,'c %.3f\n',CL);
fprintf(run,'\n');
fprintf(run,'d2\n');
fprintf(run,'pm 0\n');
fprintf(run,'x\n');
fprintf(run,'fs\n');
fprintf(run,'%s',name,'.fs');
fprintf(run,'\n\n');
fprintf(run,'quit\n');
fclose(run);

[~,~] = dos(strcat('avl < ', name,'.run'));
delete(strcat(name,'.run'));

%% Leitura do .fs

file = fopen(strcat(name,'.fs'),'r');
for i = 1:7
    fgetl(file);
end
Y = fscanf(file,' %*s %*s %*s %*s %*s %*s %*s %d\n',1);
for i = 1:13
    fgetl(file);
end

% j|Yle|Chord|Area|c_cl|ai|cl_norm|cl|cd|cdv|cm_c/4|cm_LE|C.P.x/c
fs = fscanf(file,' %d %f %f %f %f %f %f %f %f %f %f %f %f\n',[13 Y]);
fclose(file);

%% Cálculo

b  = fs(2,1:Y);
c  = fs(3,1:Y);

cl = fs(8,1:Y);
cm = fs(11,1:Y);

l  = cl.*c*q;
m  = cm.*c*q;

Q = zeros(1,Y);
for i = (Y-1):-1:1
    Q(i) = Q(i+1) + l(i+1)*(b(i+1)-b(i));
end

T = zeros(1,Y);
for i = (Y-1):-1:1
    T(i) = T(i+1) + m(i+1)*(b(i+1)-b(i));
end

M = zeros(1,Y);
for i = 1:Y
    for j = i:(Y-1)
        M(i) = M(i) + l(j)*(b(j+1)-b(j))*(b(j)-b(i));
    end
end

%% Plots

figure(3)

subplot(2,2,1)
plot(b,Q)
grid on
grid minor
xlabel('y [m]')
ylabel('Força cortante [N]')

subplot(2,2,2)
plot(b,M)
grid on
grid minor
xlabel('y [m]')
ylabel('Momento fletor [N.m]')

subplot(2,2,3)
plot(b,T)
grid on
grid minor
xlabel('y [m]')
ylabel('Momento torsor [N.m]')