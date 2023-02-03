%varredura de monoplano usando o AVL_change_bc e o AVL_runner
%o .avl base deve conter os comentários (como especificado no AVL_change_bc
%e AFILE e CDCL vazios como no AVL_runner
clear
plane = 'base_monoplane';

sMax = 0.55;

cLen = 10;
cRange   = linspace(0.2, 0.35, cLen);
bLen = 10;
bRange   = linspace(1.6, 2.5, bLen);
VhLen = 2;
VhRange  = linspace(0.3, 0.4, VhLen);
VvLen = 4;
VvRange  = linspace(0.02, 0.04, VvLen);
ARhLen = 3;
ARhRange = linspace(3, 4, ARhLen);
ARvLen = 3;
ARvRange = linspace(3, 4, ARhLen);
ltLen = 5;
ltRange  = linspace(0.6, 0.9, ltLen);

%só é necessário inclinar se no ãngulo de estol ele bater no chão
angLen = 1;
angRange = linspace(0, 0, angLen);

sz = size(ndgrid(cRange, bRange, VhRange, VvRange, ARhRange, ARvRange, ltRange, angRange));
dec = Inf(sz);
mtows = ones(sz)*NaN;

if exist('MTOWs.mat')==2
    load MTOWs.mat
else
    save MTOWs.mat mtows
end

nairc=0
for ic = 1:cLen
    c = cRange(ic);
    for ib = 1:bLen
        b = bRange(ib);
        for iVh = 1:VhLen
            Vh = VhRange(iVh);
            for iVv = 1:VvLen
                Vv = VvRange(iVv);
                for iARh = 1:ARhLen
                    ARh = ARhRange(iARh);
                    for iARv = 1:ARvLen
                        ARv = ARvRange(iARv);
                        for ilt = 1:ltLen
                            lt = ltRange(ilt);
                            for iang = 1:angLen
                                if b*c <= sMax
                                    mtows(ic, ib, iVh, iVv, iARh, iARv, ilt, iang)=0.0;
                                    nairc=nairc+1
                                    continue
                                end
                                if ~isnan(mtows(ic, ib, iVh, iVv, iARh, iARv, ilt, iang))
                                    nairc=nairc+1
                                    continue
                                end
                                ang = angRange(iang);
                                %montar o .avl, rodar o AVL_runner e o AVL_dec
                                AVL_change_bc([plane '1.avl'], [plane '.avl'], b, c, Vh, Vv, ARh, ARv, lt, ang)
                                AVL_runner([plane '1'], 6, 1);
                                [xdec, mtow] = AVL_dec(b*c, 1);
                                mtow=mtow
                                xdec=xdec
                                nairc=nairc+1
                                nperc=nairc/36000
                                dec(ic, ib, iVh, iVv, iARh, iARv, ilt, iang)=xdec;
                                mtows(ic, ib, iVh, iVv, iARh, iARv, ilt, iang)=mtow;
                                
                                save MTOWs.mat mtows
                                
                                delete([plane '1 (opcao-aerofolio.mat).avl'])
                                delete([plane '1.avl'])
                                fclose('all')
                            end
                        end
                    end
                end
            end
        end
    end
end

save SweepResult.mat dec
save MTOWs.mat mtows

[m, index] = min(dec, [], 'all', 'linear');
[jc, jb, jVh, jVv, jARh, jARv, jlt, jang] = ind2sub(size(dec), index);
disp('O melhor avião do mundo tem:')
disp(['Corda' cRange(jc)])
disp(['Envergadura' bRange(jb)])
disp(['Volume de cauda horizontal' VhRange(jVh)]);
disp(['Volume de cauda vertical' VvRange(jVv)]);
disp(['Alongamento do est. horizontal' ARhRange(jARh)]);
disp(['Alongamento do est. vertical' ARvRange(jARv)]);
disp(['Comprimento da cauda' ltRange(jlt)]);
disp(['E ângulo da cauda' angRange(jang)]);
disp(['E decola em ' m]);