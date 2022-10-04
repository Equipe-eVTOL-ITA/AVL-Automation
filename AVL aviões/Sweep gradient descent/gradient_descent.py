import scipy.io, scipy.interpolate, scipy.optimize, numpy
import scipy.stats as stat
mtows_1 = scipy.io.loadmat('MTOWs.mat', appendmat=False)
mtows_1 = mtows_1['alldec']
mtows_2 = scipy.io.loadmat('MTOW_comp')
mtows_2 = mtows_2['mtows']

mtows=numpy.maximum(mtows_1, mtows_2)


def linspace(begin, end, num):
    return [begin + x * (end-begin)/(num-1) for x in range(num)]

cLen = 10
cRange   = linspace(0.2, 0.35, cLen)
bLen = 10
bRange   = linspace(1.6, 2.5, bLen)
VhLen = 2
VhRange  = linspace(0.3, 0.4, VhLen)
VvLen = 4
VvRange  = linspace(0.02, 0.04, VvLen)
ARhLen = 3
ARhRange = linspace(3, 4, ARhLen)
ARvLen = 3
ARvRange = linspace(3, 4, ARhLen)
ltLen = 5
ltRange  = linspace(0.6, 0.9, ltLen)
others = [[0 for _ in range(cLen)] for _ in range(bLen)]
#scipy.io.savemat('MTOWs', {'mtows':mtows})

import matplotlib.pyplot as plt
from mpl_toolkits import mplot3d

def apply_restrictions(Vmax):

    #mtows é um ndarray do numpy com os valores de mtow pra cada combinação de parâmetros
    #a ordem de indexação é c, b, Vh, Vv, ARh, ARv, lt
    

    #para cada combinação de b e c, encontrar o máximo
    maxbc = numpy.zeros([cLen, bLen])

    #others associa caba (b, c) com um conjunto [Vh, Vv, ARh, ARv, lt] que produz o máximo MTOW
    

    #inicializar array pra colocar os máximos
    #e array pra cololocar os outros parâmetros associados

    fx_history=[]
    S_history=[]
    x_history=[]

    for ci, c_params in enumerate(mtows):
        #c_params é o array dos parâmetros pra cada corda
        for bi, b_params in enumerate(c_params):
            #c_params é o resto dos parãmetros depois da corda
            #pegar máximo, outros parâmetros
            maxbc[ci][bi] = numpy.amax(c_params)
            #OTHERS TÁ ERRADO!!!!!!!!!!!!!!!!!
            #era pra ter índices dos parâmetros que dão o máximo
            others[ci][bi] = numpy.unravel_index(numpy.argmax(c_params), c_params.shape)

    maxbc=numpy.array([[numpy.amax(mtows[i, j]) for j in range(len(bRange))] for i in range(len(cRange))])

    #fazer spline c maxbc
    spline = scipy.interpolate.RectBivariateSpline(cRange, bRange, maxbc)

    def fun(x):
        fval=-spline(x[0], x[1])

        if not x.tolist() in x_history:
            x_history.append(x.tolist())

            fx_history.append(fval)

            S_history.append(x[0]*x[1])

        return fval

    jac = lambda x: [-spline(x[0], x[1], dx=1), -spline(x[0], x[1], dy=1)]

    constraints=[{'type':'ineq', 'fun':lambda x: Vmax*0.036-0.15*x[0]**2*x[1], 'jac':lambda x: -0.15*numpy.array([2*x[1]*x[0], x[1]*x[0]**2])}]

    #fazer gradient descent
    optimum = scipy.optimize.minimize(fun, x0=[0.25, 1.7], jac=jac, method='SLSQP', bounds=[(cRange[0], cRange[-1]), (bRange[0], bRange[-1])], constraints=constraints)
    # optimum=scipy.optimize.differential_evolution(fun, bounds=[(cRange[0], cRange[-1]), (bRange[0], bRange[-1])], popsize=20)
    print(optimum)
    [best_c, best_b] = optimum.x
    #interpolar linearmente pra achar outros parâmetros do mínimo
    #spline com os 5 parametros e interpolar e recalcular valor mínimo
    #spline para cada parâmetro
    '''param_splines = []
    for i in range(len(others[0][0])):
        param_splines.append(scipy.interpolate.RectBivariateSpline(cRange, bRange, numpy.array([[other[i] for other in row] for row in others])))

    print(best_c, best_b)
    for spl in param_splines:
        print(spl(best_c, best_b))'''

    x_history=numpy.array(x_history)
    fx_history=numpy.array(fx_history)

    fx_history=fx_history.reshape(numpy.size(fx_history))

    print(x_history, fx_history)

    '''plt.plot(-fx_history)

    plt.grid()
    plt.xlabel('Iteração')
    plt.ylabel('MTOW')

    plt.show()

    cc, bb=numpy.meshgrid(cRange, bRange)

    cp=plt.contourf(cc, bb, maxbc)

    plt.colorbar(cp)

    plt.title('Resultados da varredura')
    plt.xlabel('$c$')
    plt.ylabel('$b$')

    plt.show()'''

    return x_history, fx_history, cRange, bRange, maxbc

xhs=[]
fxhs=[]

Vmaxr=numpy.linspace(0.5, 1.0, 50)

for Vmax in Vmaxr:
    xh, fxh, cRange, bRange, maxbc=apply_restrictions(Vmax)

    xhs.append(xh[-1])
    fxhs.append(fxh[-1])

plt.plot(Vmaxr, -numpy.array(fxhs))

plt.xlabel('Volume máximo (% da caixa)')
plt.ylabel('MTOW ótimo')

plt.grid()

plt.show()

cc, bb=numpy.meshgrid(cRange, bRange)

plt.scatter(cc.reshape(numpy.size(cc))*bb.reshape(numpy.size(bb)), maxbc.reshape(numpy.size(maxbc)))

plt.grid()
plt.ylabel('MTOW')
plt.xlabel('S')

plt.show()

vol = cc.reshape(numpy.size(cc))**2*bb.reshape(numpy.size(bb))*0.15/0.036
plt.scatter(cc.reshape(numpy.size(cc))**2*bb.reshape(numpy.size(bb))*0.15/0.036, maxbc.reshape(numpy.size(maxbc)))

indexes = numpy.where(numpy.logical_and(maxbc.reshape(numpy.size(maxbc))>9.5, vol < 0.44))

print('MTOW é ', maxbc.reshape(numpy.size(maxbc))[indexes])
print('Corda e envergadura são ', cc.reshape(numpy.size(cc))[indexes], ' e ', bb.reshape(numpy.size(bb))[indexes])
unraveled_index = numpy.unravel_index(indexes, (len(others), len(others[0])))
others = numpy.array(others)
other_indexes = others[unraveled_index]
other_indexes = other_indexes[0][0]
print('Outros ', VhRange[other_indexes[1]], VvRange[other_indexes[2]], ARhRange[other_indexes[3]], ARvRange[other_indexes[4]], ltRange[other_indexes[5]], sep=' ')



plt.grid()
plt.ylabel('MTOW')
plt.xlabel('V (%)')

plt.show()
