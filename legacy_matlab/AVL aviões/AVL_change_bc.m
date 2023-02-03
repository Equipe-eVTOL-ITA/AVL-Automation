function AVL_change_bc(filename, basefile, b, c, Vh, Vv, ARh, ARv, lt, ang)

%% Argumentos:
% filename: arquivo de output
% basefile: arquivo de base
% b, c: corda, env.
% Vh, Vv: volumes de cauda
% ARh, ARv: alongamentos das empenagens
% lt: comprimento da cauda, desde o CA da asa
% ang: angulo entre a cauda e o plano do chao

%% Dimensoes de referencia
Sref=b*c;
cref=c;
bref=b;

% Sref   Cref   Bref
ref=[num2str(Sref), ' ', num2str(cref), ' ', num2str(bref)];

%% Definindo superficies
wingroot=['0.0 0.0 0.0 ', num2str(c), ' 0.0'];
wingtip=['0.0 ', num2str(b/2), ' 0.0 ', num2str(c), ' 0.0'];

% dimensoes das empenagens
Sh=Vh*(Sref*cref)/lt;
ch=sqrt(Sh/ARh);
bh=ch*ARh;

Sv=Vv*(Sref*bref)/lt;
cv=sqrt(Sv/ARv);
bv=cv*ARv;

EHroot=['0.0 0.0 0.0 ', num2str(ch), ' 0.0'];
EHtip=['0.0 ', num2str(bh/2), ' 0.0 ', num2str(ch), ' 0.0'];

EVroot=['0.0 0.0 0.0 ', num2str(cv), ' 0.0'];
EVtip=['0.0 0.0 ', num2str(bv/2), ' ', num2str(cv), ' 0.0'];

%% translates
EH_translate=[num2str(lt+3*c/4-ch/4), ' 0.0 ', num2str(lt*tand(ang))];
EV_translate=[num2str(lt+3*c/4-cv/4), ' 0.0 ', num2str(lt*tand(ang))];

infile=fopen(basefile, 'r');
outfile=fopen(filename, 'w');

while ~feof(infile)
    line=fgets(infile);

    firststr=sscanf(line, '%s');
    
    if strcmp(firststr, '#ref')
        fprintf(outfile, '%s\n', ref);
    else if strcmp(firststr, '#root')
        fprintf(outfile, '%s\n', wingroot);
    else if strcmp(firststr, '#tip')
        fprintf(outfile, '%s\n', wingtip);
    else if strcmp(firststr, '#EHroot')
        fprintf(outfile, '%s\n', EHroot);
    else if strcmp(firststr, '#EHtip')
        fprintf(outfile, '%s\n', EHtip);
    else if strcmp(firststr, '#EVroot')
        fprintf(outfile, '%s\n', EVroot);
    else if strcmp(firststr, '#EVtip')
        fprintf(outfile, '%s\n', EVtip);
    else if strcmp(firststr, '#EHtrans')
        fprintf(outfile, '%s\n', EH_translate);
    else if strcmp(firststr, '#EVtrans')
        fprintf(outfile, '%s\n', EV_translate);
    else
        fprintf(outfile, '%s', line);
    end
    end
    end
    end
    end
    end
    end
    end
    end
end

fclose(infile);
fclose(outfile);
