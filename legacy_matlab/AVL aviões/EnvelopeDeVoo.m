clear all

%constantes
rho = 1;
g = 9.81;

%parãmetros do avião
SF = 0.5;   %safety factor
nmaxp = 3;  %fator de carga máximo positivo
nminn = -2;
s = 0.5;
m = 10;

%tração
T0 = 35;
T1 = -0.4084;
T2 = -0.0185;

%parâmetros aerodinâmicos
CLmax = 2;
CLmin = -1.5; %extrair do avl?????
CD = 0.2;

%função sustentação
l = @(v, cl) 0.5 * rho * v.^2 .* s .* cl;
%função fator de carga
n = @(v, cl) l(v, cl)/(m*g);
%acha velocidade p dado fator de carga
vel = @(n, cl) ( n*m*g / (0.5*rho*s*cl) ) ^0.5;

%plotar n com CLmax e CLmin
v1 = [25:-0.1:0];
cls1(1:size(v1,2)) = CLmax;
cls1 = [cls1, zeros(1, size(v1, 2))+CLmin];
v1 = [v1 v1(end:-1:1)];
ns1 = n(v1, cls1);
plot(v1, ns1, 'b--', 'DisplayName', "Fator de carga com CLmax")
hold on

%plota velocidade de cruzeiro e mergulho
Vmax = max(roots([T2 - 0.5*rho*s*CD, T1, T0])); % D = T
Vmergulho = 1.4 * Vmax;
plot([Vmax Vmax], [n(Vmax, CLmax) n(Vmax, CLmin)], 'g--', 'DisplayName', "Velocidade Máxima");
plot([Vmergulho Vmergulho], [n(Vmergulho, CLmax) n(Vmergulho, CLmin)], 'r--', 'DisplayName', "Velocidade de mergulho");

%plota o envelope
%aumenta o n até nmaxp, daí horizontal até Vne (como calcular?)
Vesp = vel(1, CLmax);
Vesn = vel(-1, CLmin);
a2 = Vesp:0.1:Vmergulho;
b2 = Vmergulho:-0.1:Vesn;
v2 = [Vesp a2 b2 Vesn Vesp];
cls2(1:size(a2,2)) = CLmax;
cls2(end+1:end+size(b2,2)) = CLmin;
nlim(1:size(a2,2)) = nmaxp;
nlim(end+1:end+size(b2,2)) = nminn;
ns2 = [0 absMin(n([a2 b2], cls2), nmaxp.*(cls2==CLmax) + nminn.*(cls2==CLmin)) 0 0];
plot(v2, ns2, 'r', 'DisplayName', "Envelope Seguro")

%plota a região de segurança
Vman = vel(nmaxp, CLmax);
v3 = Vman:0.1:1.4*Vmergulho;
cls3(1:size(v3,2)) = CLmax;
cls3 = [cls3, zeros(1, size(v3, 2))+CLmin];
v3 = [v3 v3(end:-1:1)];
ns3 = absMin(n(v3, cls3), (1+SF)*(nmaxp.*(cls3==CLmax) + nminn.*(cls3==CLmin)));
plot(v3, ns3, 'm', 'DisplayName', "Zona perigosa");

hold on
legend
title('Envelope de voo')
xlabel('Velocidade (m/s)')
ylabel('Fator de carga')
grid on


function x = absMin(v1, v2)
    x = (v1.*(abs(v1)<abs(v2)) + v2.*(abs(v2)<=abs(v1)));
end