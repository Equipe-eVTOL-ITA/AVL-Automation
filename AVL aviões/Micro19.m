% function C = Wavl_aileron(n)
clear all
clc
i=0;
% while i<4
for a=-10:1:20
    i = i+1;

%%um arquivo por angulo de ataque? Estol? Onde o avião é inclinado?

m = int2str(a);
AVL = fopen(strcat(m,'.avl'),'W');
fprintf(AVL,'bmk_19\n');
fprintf(AVL,'0\n'); 
fprintf(AVL,'0 0 0\n'); % fora do efeito solo
% fprintf(AVL,'0 1 0.5\n'); % dentro do efeito solo
fprintf(AVL,'0.625	0.25 2.5\n');   
fprintf(AVL,'0.0632 0 0\n');
fprintf(AVL,'0.01\n');  

%% ======================ASA===============================
fprintf(AVL,'SURFACE\n');
fprintf(AVL,'mainwing\n');
fprintf(AVL,'15 1 40 0\n');
fprintf(AVL,'YDUPLICATE\n');
fprintf(AVL,'0\n');
fprintf(AVL,'ANGLE\n');
fprintf(AVL,'0\n');
fprintf(AVL,'COMPONENT\n');
fprintf(AVL,'1\n');

fprintf(AVL,'SECTION\n');
fprintf(AVL,'0.0000 0.0000 0.0000 0.25 0.0000\n');
fprintf(AVL,'AFILE\n');
fprintf(AVL,'Chesky01.dat\n');
fprintf(AVL,'CLAF\n');
fprintf(AVL,'1.094\n');
fprintf(AVL,'CDCL\n');
fprintf(AVL,'-0.1016 0.119 0.992 0.02 2.12 0.0335\n');

fprintf(AVL,'SECTION\n');
fprintf(AVL,'0 0.74 0 0.25 0\n');
fprintf(AVL,'AFILE\n');
fprintf(AVL,'Chesky01.dat\n');
fprintf(AVL,'CLAF\n');
fprintf(AVL,'1.094\n');
fprintf(AVL,'CDCL\n');
fprintf(AVL,'-0.1016 0.119 0.992 0.02 2.12 0.0335\n');
fprintf(AVL,'CONTROL\n');
fprintf(AVL,'aileron 1 0.75 0 1 0 -1\n');


fprintf(AVL,'SECTION\n');
fprintf(AVL,'0.0 1.25 0 0.25 0\n');
fprintf(AVL,'AFILE\n');
fprintf(AVL,'Chesky01.dat\n');
fprintf(AVL,'CLAF\n');
fprintf(AVL,'1.094\n');
fprintf(AVL,'CDCL\n');
fprintf(AVL,'-0.1016 0.119 0.992 0.02 2.12 0.0335\n');
fprintf(AVL,'CONTROL\n');
fprintf(AVL,'aileron 1 0.75 0 1 0 -1\n');

%% ======================EH===============================
fprintf(AVL,'SURFACE\n');
fprintf(AVL,'HorStabilizer\n');
fprintf(AVL,'5 1 15 0\n');
fprintf(AVL,'YDUPLICATE\n');
fprintf(AVL,'0\n');
fprintf(AVL,'ANGLE\n');
fprintf(AVL,'-2\n');
fprintf(AVL,'TRANSLATE\n');
fprintf(AVL,'0.8 0 0.20\n');
fprintf(AVL,'COMPONENT\n');
fprintf(AVL,'2\n');

fprintf(AVL,'SECTION\n');
fprintf(AVL,'0.0000 0.0000 0.0000 0.15 0.0000\n');
fprintf(AVL,'AFILE\n');
fprintf(AVL,'RG14reversetik.dat\n');
fprintf(AVL,'CLAF\n');
fprintf(AVL,'1.092\n');
fprintf(AVL,'CDCL\n');
fprintf(AVL,'-1.209 0.0232 -0.4769 0.0106 0.8505 0.0375\n');
fprintf(AVL,'CONTROL\n');
fprintf(AVL,'elevator 1 0 0 1 0 1\n');

fprintf(AVL,'SECTION\n');
fprintf(AVL,'0.000000 0.26 0 0.15 0\n');
fprintf(AVL,'AFILE\n');
fprintf(AVL,'RG14reversetik.dat\n');
fprintf(AVL,'CLAF\n');
fprintf(AVL,'1.092\n');
fprintf(AVL,'CDCL\n');
fprintf(AVL,'-1.209 0.0232 -0.4769 0.0106 0.8505 0.0375\n');
fprintf(AVL,'CONTROL\n');
fprintf(AVL,'elevator 1 0 0 1 0 1\n');
%% ======================EV===============================
fprintf(AVL,'SURFACE\n');
fprintf(AVL,'VerStabilizer\n');
fprintf(AVL,'5 1 15 0\n');
fprintf(AVL,'ANGLE\n');
fprintf(AVL,'0\n');
fprintf(AVL,'TRANSLATE\n');
fprintf(AVL,'0.8 0 0.2\n');
fprintf(AVL,'COMPONENT\n');
fprintf(AVL,'2\n');

fprintf(AVL,'SECTION\n');
fprintf(AVL,'0.0000 0.0000 0.0000 0.15 0.0000\n');
fprintf(AVL,'AFILE\n');
fprintf(AVL,'naca0012.dat\n');
fprintf(AVL,'CLAF\n');
fprintf(AVL,'1.092\n');
fprintf(AVL,'CDCL\n');
fprintf(AVL,'-1.1 0.045 0 0.0102 1.1 0.045\n');
fprintf(AVL,'CONTROL\n');
fprintf(AVL,'rudder 1 0 0 0 1 1\n');

fprintf(AVL,'SECTION\n');
fprintf(AVL,'0.000000 0.0 0.22 0.15 0\n');
fprintf(AVL,'AFILE\n');
fprintf(AVL,'naca0012.dat\n');
fprintf(AVL,'CLAF\n');
fprintf(AVL,'1.092\n');
fprintf(AVL,'CDCL\n');
fprintf(AVL,'-1.1 0.045 0 0.0102 1.1 0.045\n');
fprintf(AVL,'CONTROL\n');
fprintf(AVL,'rudder 1 0 0 0 1 1\n');
%% ========================================================
fclose(AVL);


frun = fopen(strcat(m,'.run'),'W');
fprintf(frun,'LOAD %s\n',strcat(m,'.avl'));
% fprintf(frun,'%s\n', 'MASS');
% fprintf(frun,'%s\n','lev.mass');
% fprintf(frun, '%s\n',   'MSET');
% fprintf(frun, '%s\n',   '0');
fprintf(frun, '%s\n',   'OPER');
fprintf(frun, '%s\n',   'C1');


fprintf(frun, '%s\n',   'M');
fprintf(frun, '%s\n',   '9.6');

fprintf(frun, '%s\n',   'D');
fprintf(frun, '%s\n',   '1.1008');

% fprintf(frun, '%s\n',   'X'); % desativar!!!!!!!!!!!!!!
% fprintf(frun, '%s\n',   '0.0632');

fprintf(frun, '%s\n',   'G');
fprintf(frun, '%s\n',   '9.81');

fprintf(frun, '%s\n',   'V');
fprintf(frun, '%s\n',   '12');
% fprintf(frun, '%s\n %f\n',   'V',Velocidade);
fprintf(frun, '\n');
% fprintf(frun, '%s\n',   'B');
% fprintf(frun, '%s\n\n',   '45');
% fprintf(frun, '%s\n',   'd1');
% fprintf(frun, '%s\n %f\n',   'PM',0);
fprintf(frun, '%s\n',   'a');
fprintf(frun, '%s\n %f\n',   'a',a);

fprintf(frun, '%s\n',   'X');
fprintf(frun, '%s\n',   'ST');
fprintf(frun, '%s%s\n', m,'.st');
% fprintf(frun, '%s\n',   'FS');
% fprintf(frun, '%s%s\n', m,'.fs');
% fprintf(frun, '%s\n',   'FN');
% fprintf(frun, '%s%s\n', m,'.fn');
fprintf(frun,'$s\n');
fprintf(frun,'QUIT\n');
fclose(frun);
dos(strcat('avl < ', m,'.run'));

%% Adquisi��o de for�as

read = fopen(strcat(m,'.st'));
aircraft.results.alfa(i)= cell2mat(textscan(read,'Alpha =   %f',1,'headerlines',14));
fclose(read);

read = fopen(strcat(m,'.st'));
aircraft.results.beta(i)= cell2mat(textscan(read,'Beta  =   %f',1,'headerlines',16));
fclose(read);

read = fopen(strcat(m,'.st'));
aircraft.results.CXtot(i)= cell2mat(textscan(read,'CXtot =  %f',1,'headerlines',19));
fclose(read);

read = fopen(strcat(m,'.st'));
aircraft.results.Cltot(i) =cell2mat(textscan(read,'%*s %*s  %*f     Cltot =  %f',1,'headerlines',19));
fclose(read);

read = fopen(strcat(m,'.st'));
aircraft.results.Cltotp(i) =cell2mat(textscan(read,'%*s %*s  %*f %*s %*s %*f     Cl''tot =  %f',1,'headerlines',19));
fclose(read);

read = fopen(strcat(m,'.st'));
aircraft.results.CYtot(i)= cell2mat(textscan(read,'CYtot =  %f',1,'headerlines',20));
fclose(read);

read = fopen(strcat(m,'.st'));
aircraft.results.Cmtot(i) =cell2mat(textscan(read,'%*s %*s  %*f     Cmtot =  %f',1,'headerlines',20));
fclose(read);

read = fopen(strcat(m,'.st'));
aircraft.results.CZtot(i)= cell2mat(textscan(read,'CZtot =  %f',1,'headerlines',21));
fclose(read);

read = fopen(strcat(m,'.st'));
aircraft.results.Cntot(i) =cell2mat(textscan(read,'%*s %*s  %*f     Cntot =  %f',1,'headerlines',21));
fclose(read);

read = fopen(strcat(m,'.st'));
aircraft.results.Cmtotp(i) =cell2mat(textscan(read,'%*s %*s  %*f %*s %*s %*f     Cn''tot =  %f',1,'headerlines',21));
fclose(read);

read = fopen(strcat(m,'.st'));
aircraft.results.CLtot(i)= cell2mat(textscan(read,'CLtot =   %f',1,'headerlines',23));
fclose(read);

read = fopen(strcat(m,'.st'));
aircraft.results.CDtot(i)= cell2mat(textscan(read,'CDtot =   %f',1,'headerlines',24));
fclose(read);

read = fopen(strcat(m,'.st'));
aircraft.results.CDvis(i)= cell2mat(textscan(read,'CDvis =   %f',1,'headerlines',25));
fclose(read);

read = fopen(strcat(m,'.st'));
aircraft.results.CDind(i)= cell2mat(textscan(read,'%*s %*s  %*f     CDind =   %f',1,'headerlines',25));
fclose(read);

read = fopen(strcat(m,'.st'));
aircraft.results.e(i) =cell2mat(textscan(read,'%*s %*s  %*f         e =    %f',1,'headerlines',27));
fclose(read);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

read = fopen(strcat(m,'.st'));
aircraft.results.d_elev(i)= cell2mat(textscan(read,'   elevator        =  %f',1,'headerlines',30));
fclose(read);
% 
read = fopen(strcat(m,'.st'));
aircraft.results.d_ail(i)= cell2mat(textscan(read,'   aileron         =  %f',1,'headerlines',29));
fclose(read);

read = fopen(strcat(m,'.st'));
aircraft.results.d_rud(i)= cell2mat(textscan(read,'   rudder          =  %f',1,'headerlines',31));
fclose(read);
% %% Aquisi��o de derivadas de estabilidade
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
read = fopen(strcat(m,'.st'));
aircraft.results.CLa(i) =cell2mat(textscan(read,'%*s %*s  %*s %*s      CLa =   %f',1,'headerlines',39));
fclose(read);

read = fopen(strcat(m,'.st'));
aircraft.results.CLb(i) =cell2mat(textscan(read,'%*s %*s  %*s %*s %*s %*s %*f    CLb =  %f',1,'headerlines',39));
fclose(read);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
read = fopen(strcat(m,'.st'));
aircraft.results.CYa(i) =cell2mat(textscan(read,'%*s %*s  %*s %*s      CYa =   %f',1,'headerlines',40));
fclose(read);

read = fopen(strcat(m,'.st'));
aircraft.results.CYb(i) =cell2mat(textscan(read,'%*s %*s  %*s %*s %*s %*s %*f    CYb =  %f',1,'headerlines',40));
fclose(read);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
read = fopen(strcat(m,'.st'));
aircraft.results.Cla(i) =cell2mat(textscan(read,'%*s %*s %*s    Cla =   %f',1,'headerlines',41));
fclose(read);

read = fopen(strcat(m,'.st'));
aircraft.results.Clb(i) =cell2mat(textscan(read,'%*s %*s %*s %*s %*s %*f    Clb =  %f',1,'headerlines',41));
fclose(read);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
read = fopen(strcat(m,'.st'));
aircraft.results.Cma(i) =cell2mat(textscan(read,'%*s %*s  %*s %*s      Cma =   %f',1,'headerlines',42));
fclose(read);

read = fopen(strcat(m,'.st'));
aircraft.results.Cmb(i) =cell2mat(textscan(read,'%*s %*s  %*s %*s %*s %*s %*f    Cmb =  %f',1,'headerlines',42));
fclose(read);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
read = fopen(strcat(m,'.st'));
aircraft.results.Cna(i) =cell2mat(textscan(read,'%*s %*s %*s      Cna =   %f',1,'headerlines',43));
fclose(read);

read = fopen(strcat(m,'.st'));
aircraft.results.Cnb(i) =cell2mat(textscan(read,'%*s %*s %*s %*s %*s %*f    Cnb =  %f',1,'headerlines',43));
fclose(read);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
read = fopen(strcat(m,'.st'));
aircraft.results.CLp(i) =cell2mat(textscan(read,'%*s %*s  %*s %*s      CLp =   %f',1,'headerlines',47));
fclose(read);

read = fopen(strcat(m,'.st'));
aircraft.results.CLq(i) =cell2mat(textscan(read,'%*s %*s  %*s %*s %*s %*s %*f    CLq =  %f',1,'headerlines',47));
fclose(read);

read = fopen(strcat(m,'.st'));
aircraft.results.CLr(i) =cell2mat(textscan(read,'%*s %*s %*s %*s %*s %*s %*f %*s %*s %*f   CLr =  %f',1,'headerlines',47));
fclose(read);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
read = fopen(strcat(m,'.st'));
aircraft.results.CYp(i) =cell2mat(textscan(read,'%*s %*s  %*s %*s      CYp =   %f',1,'headerlines',48));
fclose(read);

read = fopen(strcat(m,'.st'));
aircraft.results.CYq(i) =cell2mat(textscan(read,'%*s %*s  %*s %*s %*s %*s %*f    CYq =  %f',1,'headerlines',48));
fclose(read);

read = fopen(strcat(m,'.st'));
aircraft.results.CYr(i) =cell2mat(textscan(read,'%*s %*s %*s %*s %*s %*s %*f %*s %*s %*f   CYr =  %f',1,'headerlines',48));
fclose(read);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
read = fopen(strcat(m,'.st'));
aircraft.results.Clp(i) =cell2mat(textscan(read,'%*s %*s  %*s      Clp =   %f',1,'headerlines',49));
fclose(read);

try
read = fopen(strcat(m,'.st'));
aircraft.results.Clq(i) =cell2mat(textscan(read,'%*s %*s  %*s %*s %*s %*f    Clq =  %f',1,'headerlines',49));
fclose(read);
catch
 read = fopen(strcat(m,'.st'));
aircraft.results.Clq(i) =cell2mat(textscan(read,'%*s %*s  %*s %*s %*s     Clq =  %f',1,'headerlines',49));
fclose(read);   
end

try
read = fopen(strcat(m,'.st'));
aircraft.results.Clr(i) =cell2mat(textscan(read,'%*s %*s %*s %*s %*s %*f %*s %*s %*f   Clr =  %f',1,'headerlines',49));
fclose(read);
catch
read = fopen(strcat(m,'.st'));
aircraft.results.Clr(i) =cell2mat(textscan(read,'%*s %*s %*s %*s %*s %*s %*s %*f   Clr =  %f',1,'headerlines',49));
fclose(read);
end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

read = fopen(strcat(m,'.st'));
aircraft.results.Cmp(i) =cell2mat(textscan(read,'%*s %*s  %*s %*s      Cmp =   %f',1,'headerlines',50));
fclose(read);

read = fopen(strcat(m,'.st'));
aircraft.results.Cmq(i) =cell2mat(textscan(read,'%*s %*s  %*s %*s %*s %*s %*f    Cmq =  %f',1,'headerlines',50));
fclose(read);

try
read = fopen(strcat(m,'.st'));
aircraft.results.Cmr(i) =cell2mat(textscan(read,'%*s %*s %*s %*s %*s %*s %*f %*s %*s %*f   Cmr =  %f',1,'headerlines',50));
fclose(read);
catch
read = fopen(strcat(m,'.st'));
aircraft.results.Cmr(i) =cell2mat(textscan(read,'%*s %*s %*s %*s %*s %*s %*f %*s %*s    Cmr =   %f',1,'headerlines',50));
fclose(read);
end
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
read = fopen(strcat(m,'.st'));
aircraft.results.Cnp(i) =cell2mat(textscan(read,'%*s %*s %*s      Cnp =   %f',1,'headerlines',51));
fclose(read);

read = fopen(strcat(m,'.st'));
aircraft.results.Cnq(i) =cell2mat(textscan(read,'%*s %*s %*s %*s %*s %*f    Cnq =  %f',1,'headerlines',51));
fclose(read);

read = fopen(strcat(m,'.st'));
aircraft.results.Cnr(i) =cell2mat(textscan(read,'%*s %*s %*s %*s %*s %*f %*s %*s %*f   Cnr =  %f',1,'headerlines',51));
fclose(read);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

read = fopen(strcat(m,'.st'));
aircraft.results.Xnp(i) =cell2mat(textscan(read,'%*s %*s  Xnp =   %f',1,'headerlines',65));
fclose(read);


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% read = fopen(strcat(m,'.fs'));
% aircraft.results.strip.Y(i) =(textscan(read,'%*f %f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f','headerlines',20));
% fclose(read);
% 
% read = fopen(strcat(m,'.fs'));
% aircraft.results.strip.cl_local(i) =(textscan(read,'%*f %*f %*f %*f %*f %*f %*f %f %*f %*f %*f %*f %*f %*f','headerlines',20));
% fclose(read);
% fclose('all')
%% Delete de arquivos de leitura 
delete(strcat(m,'.st'));
% delete(strcat(m,'.fn'));
% delete(strcat(m,'.fs'));
delete(strcat(m,'.run'));
delete(strcat(m,'.avl'))
end
