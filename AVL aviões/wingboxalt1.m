%% INPUTS

De = 50e-3;
Di = 48e-3;



Q = 104.3; % Força cortante
M = 47.68; % Momento fletor
T = -18.45; % Momento torsor 

%% MATERIAL DATA


% Carb 2D
Carb2D.E1    = 5.79e10;
Carb2D.E2    = 5.79e10;
Carb2D.G     = 2.71e9;
Carb2D.nu    = 0.04;
Carb2D.Xt    = 7.18e8;
Carb2D.Xc    = 4.19e8;
Carb2D.Yt    = 7.18e8;
Carb2D.Yc    = 4.19e8;
Carb2D.S     = 1.4e8;
Carb2D.rho   = 1781;
Carb2D.thk   = 4e-4;

%% I

Ixx = pi*(De^4 - Di^4)/64;

%% NORMAL STRESS

E = Carb2D.E1;

sigma = 0.5*M*De/Ixx;
epsilon = sigma/E;


%% SHEAR FLOW

% Shear flow due to twist
AA = (pi/8)*(De^2 - Di^2); 
t = (De - Di)/2;  % espessura tubo
qt = T/(2*AA);   % fluxo cisalhamento

% Shear flow due to normal force
q_hor = @(d) Q*(De^3 - Di^3)/(12*Ixx);
q_ver = @(d) Q*(De^3 - Di^3)/(12*Ixx);

step_hor = De/40;
step_ver = De/40;
for j = 41:-1:1
    sx = (j-1)*step_hor;
    sy = (j-1)*step_ver;
    qu(j) = q_hor(sx) + qt; %Shear flow in the upper skin
    ql(j) = q_hor(sx) - qt; %Shear flow in the lower skin
    qf(j) = q_ver(sy) + qt; %Shear flow in the front spar
    qr(j) = q_ver(sy) - qt; %Shear flow in the rear spar
end

%% SHEAR STRESS

tau_u = max(abs(qu))/t;
tau_l = max(abs(ql))/t;
tau_f = max(abs(qf))/t;
tau_r = max(abs(qr))/t;

%% FAILURE

tsai_hill = @(s11,s22,tau12,X,Y,S) (s11/X).^2 + (s22/Y).^2 - (s11/X).*(s22/Y) + (tau12/S).^2;
von_mises = @(s11,tau12) sqrt((s11.^2 + 6*tau12.^2)/2);

% Upper skin
FI_u = tsai_hill(-sigma,0,tau_u,Carb2D.Xc,Carb2D.Yt,Carb2D.S);
FS_u = 1./sqrt(FI_u);
MS_u = FS_u-1;

% Lower skin
FI_l = tsai_hill(sigma,0,tau_l,Carb2D.Xt,Carb2D.Yt,Carb2D.S);
FS_l = 1./sqrt(FI_l);
MS_l = FS_l-1;

% Frontal spar
VM_f = von_mises(sigma,tau_f);
FS_f = Carb2D.Xt./VM_f;
MS_f = FS_f-1;

% Rear spar
VM_r = von_mises(sigma,tau_r);
FS_r = Carb2D.Xt./VM_r;
MS_r = FS_r-1;

% Roving - compression
FI_c = tsai_hill(-sigma,0,0,Carb2D.Xc,Carb2D.Yt,Carb2D.S);
FS_c = 1./sqrt(FI_c);
MS_c = FS_c-1;

% Roving - tension
FI_t = tsai_hill(sigma,0,0,Carb2D.Xt,Carb2D.Yc,Carb2D.S);
FS_t = 1./sqrt(FI_t);
MS_t = FS_t-1;

%% RESULTS

fprintf('                sigma               tau           MS\n')
fprintf(' Carbon u      %+.2e           %+.2e      %.2f%%\n',-sigma,-tau_u,100*MS_u)
fprintf(' Carbon l      %+.2e           %+.2e      %.2f%%\n',sigma,tau_l,100*MS_l)
fprintf(' Carbon r      %+.2e           %+.2e      %.2f%%\n',sigma,tau_r,100*MS_r)
fprintf(' Carbon f      %+.2e           %+.2e      %.2f%%\n',sigma,-tau_f,100*MS_f)
%fprintf(' Carbon u     %+.2e           %+.2e      %.2f%%\n',-sigma,0,100*min(MS_c))
%fprintf(' Carbon l     %+.2e           %+.2e      %.2f%%\n',sigma,0,100*min(MS_t))
