# DQN del QUBE-Servo 3: exportacion numerica para QUARC

Preparado para el proyecto Control Inteligente de Rodrigo Cruz Bartolo.
No se ha ejecutado MATLAB ni QUARC en este entorno. Ya se recibieron el agente
entrenado y pruebaReal.slx; se inspecciono la estructura del SLX, su hardware y
la conversion de encoders. La reconstruccion del objeto agente y las pruebas
numericas deben ejecutarse en su MATLAB antes de usar hardware.
No contiene pesos inventados y no inicia entrenamiento ni hardware.

## 1. Decision de implementacion

En el equipo anfitrion se abre el agente, se obtiene el critico ONLINE con
`getCritic` y la red con `getModel`, y se extraen sus pesos aprendidos.
En el modelo que compila QUARC solo se usa algebra numerica de dimensiones
fijas: tres productos matriciales, dos ReLU y un maximo.

```matlab
h1 = max(W1*s+b1,0);
h2 = max(W2*h1+b2,0);
Q  = W3*h2+b3;
[~,i] = max(Q);
Vm = A(i);
```

No se exporta la red objetivo, el optimizador, el replay buffer, el objeto
agente ni su logica de entrenamiento. El maximo es sobre los nueve valores Q,
y su indice selecciona el voltaje en el ORDEN ORIGINAL de `ActionInfo`.
Los valores Q no son voltajes. No aplicar softmax, normalizacion de estados,
epsilon-greedy ni un factor de ganancia al voltaje exportado.

`coder.load` incorpora las matrices al generar codigo. El ejecutable no abre
el archivo de agente en tiempo real. Para cambiar los pesos hay que exportar,
limpiar las funciones persistentes y recompilar, incluso en Monitor & Tune.

Existe tambien una ruta oficial con `generatePolicyBlock`/bloque Policy,
disponible desde R2022b. El error del bloque RL Agent no significa que ninguna
politica RL pueda desplegarse. Para esta red tan simple se propone algebra
explicita para reducir dependencias de version y del backend de redes.

## 2. Archivos

| Archivo | Uso |
|---|---|
| exportar_dqn_quarc.m | Se ejecuta en MATLAB; extrae pesos y compara Q/acciones |
| dqn_policy.m | Funcion numerica compilable de la politica |
| dqn_qube_rt.m | Filtros, cadencia de politica y supervisor discreto |
| bloque_MATLAB_Function.txt | Codigo corto para pegar dentro de Simulink |
| configurar_prueba_quarc.m | Configura solver sin cambiar el target QUARC |
| verificar_controlador.m | Pruebas del supervisor en MATLAB sin hardware |

## 3. Exportar, sin entrenar

Descomprimir en una carpeta y seleccionarla como Current Folder en MATLAB.
No ejecutar entrenamiento.m para preparar hardware: el archivo recibido tiene
`entrenar=true`, y empezaria otra sesion de entrenamiento.

```matlab
% Cambiar la ruta y, si corresponde, el nombre de la variable guardada.
informe = exportar_dqn_quarc('C:\ruta\Agente_Pausado_XXXX.mat','agente');
verificar_controlador
```

Tambien puede omitirse el segundo argumento si el MAT contiene exactamente
un rlDQNAgent. El exportador no cambia el MAT original.

El exportador se detiene si encuentra otra arquitectura, normalizacion,
otro orden de acciones, dimensiones incorrectas o diferencias relevantes con
la politica original. Prueba 265 estados, mas los estados extra opcionales.
Compara algebra double con `getValue` del critico y la accion de `getAction`
sin exploracion. La tolerancia Q escala con su magnitud; pequenas diferencias
son esperables al pasar de calculo single/GPU a double/CPU. Una diferencia de
accion cerca de un empate se informa y debe revisarse antes del experimento.
El desempate numerico exportado elige el primer maximo.

Para ampliar la comprobacion con observaciones realmente registradas:

```matlab
% estadosRegistrados debe tener orden [theta;alpha;theta_dot;alpha_dot], 4xN.
informe = exportar_dqn_quarc('C:\ruta\agente.mat','agente',estadosRegistrados);
```

Se generan `DQN_pesos.mat` (solo matrices double) y `DQN_verificacion.mat`
(informe y estados de comprobacion). El archivo original con el agente puede
quedarse fuera del path del modelo de despliegue.

Si se dispone de MATLAB Coder, es posible hacer adicionalmente una compilacion
aislada sin QUARC, despues de exportar:

```matlab
cfg = coder.config('lib');
cfg.TargetLang = 'C';
codegen('-config',cfg,'dqn_qube_rt','-args',{0,0,false,false},'-report');
```

Esto es opcional y no sustituye la compilacion del modelo con el target QUARC.
La via Simulink usa los productos/licencias que requiera su instalacion QUARC.

## 4. Un solo reloj de Simulink, dos cadencias internas

Se propone una tarea discreta con paso de 1 ms, si el template QAL/QUARC y el
equipo del laboratorio admiten esa frecuencia sin overruns. Es necesario
comprobar el tiempo real de ejecucion, especialmente en los ticks con DQN.

| Parte | Ejecucion |
|---|---|
| QAL/HIL lectura y escritura | Cada 0.001 s |
| MATLAB Function completo | Cada 0.001 s |
| Estimacion de velocidades y supervisor | Cada 0.001 s |
| Tres capas densas del DQN | Cada 10 llamadas: 0.01 s |
| Voltaje entre decisiones | Se mantiene; el supervisor puede llevarlo a cero |

Todo el grafo dinamico tiene tasa compilada de 0.001 s. El contador interno
no crea un puerto Simulink de 0.01 s ni otra tarea, de modo que este diseno
evita la transicion de tasas del RL Agent. `nuevaAccion` marca los ticks con
inferencia para comprobar la cadencia en un Scope.

No agregar Rate Transition para ocultar senales continuas: primero quitar
todos los bloques continuos del diagrama fisico. Las constantes pueden
compilar con tiempo infinito y los bloques algebraicos heredar la tasa.
Si el template obliga a otra tasa o varias tareas, este paquete debe adaptarse;
no cambiar solo el paso del solver dejando las constantes internas de 1 ms.

Para un verdadero diseno multitasa con politica en otro subsistema de 10 ms,
serian necesarias transiciones deterministas en sus fronteras y validar la
latencia introducida. Esa no es la estructura utilizada aqui.

## 5. Por que no derivar a 10 ms sin revisar

Para el filtro entrenado `s/(tau*s+1)`, Tustin da:

```text
v[k] = ((2*tau-Tb)/(2*tau+Tb))*v[k-1]
     + (2/(2*tau+Tb))*(p[k]-p[k-1])
```

Con tau=0.005 y Tb=0.001 resulta:

```matlab
v = (9/11)*vPrev + (2000/11)*(pos-posPrev);
```

Como bloques Discrete Transfer Fcn equivalentes a 1 ms: numerador
`[2000/11 -2000/11]`, denominador `[1 -9/11]`.
El paquete implementa la recurrencia dentro del MATLAB Function.

Si se discretiza por Tustin a Tb=0.01, el coeficiente de memoria queda en
cero y resulta `v[k]=100*(p[k]-p[k-1])`: desaparece el suavizado recursivo.
No es equivalente a su filtro continuo observado a 100 Hz. A 1 ms se conserva
mejor su comportamiento, pero sigue siendo una aproximacion por validar.

La inicializacion usa la primera posicion medida y velocidad cero, evitando
el pico causado por inicializar el filtro en cero con una posicion no nula.
Se filtra tambien mientras esta desarmado. Se exige al menos 100 ms de
muestras validas antes de armar; esto no significa que el brazo y el pendulo
hayan permanecido inmoviles durante todo ese intervalo.

## 6. Conexion en una COPIA del modelo real

1. Partir del template QAL/QUARC que ya lee el QUBE. Conservar hardware,
   comunicacion, timebase e inicializacion del dispositivo. Guardar una copia.
   PenduloQUBE.slx recibido es un modelo de simulacion, con target grt.tlc;
   no contiene el bloque QAL fisico que aparece en sus capturas.
2. En esa copia quitar RL Agent, filtros Transfer Fcn continuos, el hold de
   10 ms y la logica de recompensa conectada al controlador. La planta fisica
   ya proporciona la dinamica: no colocar el modelo dinamico simulado en serie.
   La recompensa puede calcularse fuera de linea con los logs del experimento.
3. Agregar un MATLAB Function con el contenido de bloque_MATLAB_Function.txt.
   Conectar theta/alpha CALIBRADOS desde Counts to Angles. Deben ser escalares
   double. El Mux previo al agente se sustituye por estas dos entradas;
   el vector de cuatro observaciones se forma dentro de la funcion.
4. Conectar armar desde un Constant boolean con valor inicial false y tasa
   0.001, conmutado deliberadamente mediante un Dashboard Switch/parametro
   ajustable en External Mode. Verificar que ese parametro sea ajustable en
   su configuracion. No usar un Step que arme automaticamente.
5. Conectar falloHW boolean desde StallDetected y otros fallos que exponga
   el template, combinados con OR. El paquete no sustituye las protecciones
   internas del equipo ni resetea automaticamente el amplificador.
6. Conectar Vm a motorCmd del QAL. Registrar tambien s, estado y nuevaAccion.
   Una saturacion externa redundante a [-8,8] es posible, pero no reducir el
   rango ni escalar las acciones sin volver a validar la politica modificada.
7. Ejecutar `configurar_prueba_quarc('pruebaReal')` con el nombre de la copia.
   El script solo cambia el solver; no inicia hardware ni ajusta el QAL.
   En la mascara QAL/HIL fijar tambien el periodo de lectura/escritura a
   0.001 o verificar que herede ese paso. No crear un segundo timebase HIL.
8. Actualizar el diagrama y visualizar las tasas de muestreo. El controlador
   y los puertos dinamicos del QAL deben verse a 0.001 s. Resolver cualquier
   bloque continuo o tasa residual antes de Monitor & Tune. No silenciar el
   diagnostico de integridad de datos.

Para el paso de 1 ms usar una variable propia, por ejemplo `Tb=0.001`, en los
campos del hardware. El agente mantiene su cadencia de 0.01 s. Evitar reutilizar
indiscriminadamente `Ts` entre el modelo de entrenamiento y el de hardware.

No hace falta reward/isDone para la inferencia; su funcion en hardware la
cubre el supervisor. Al quitarlos desaparece tambien su lazo algebraico y
el Unit Delay de Vm deja de ser necesario para el controlador desplegado.

## 7. Calibracion antes de habilitar salida

Con armar=false y motor a cero, comprobar:

- theta=0 cuando el brazo esta en su centro fisico de operacion.
- alpha=0 en vertical SUPERIOR. Colgando debe estar cerca de +pi o -pi.
- Los signos positivos de ambos angulos coinciden con el modelo de
  entrenamiento, y las velocidades tienen esos mismos signos.
- La conversion usa cuentas por revolucion efectivas y no confunde pulsos
  con conteo en cuadratura. Reutilizar y comprobar el template instalado.
- theta conserva desplazamiento acumulado, sin modulo 2*pi que ocultaria
  una vuelta y el limite de brazo. Solo alpha se lleva a [-pi,pi].

Si el template pone cero del pendulo colgando, la correccion general es
`alpha = atan2(sin(alphaMedido-alphaVertical),cos(alphaMedido-alphaVertical))`,
donde alphaVertical se determina experimentalmente. No suponerlo por la foto.
El signo de Vm debe coincidir tambien con el usado al entrenar. Un signo
incorrecto no se corrige cambiando arbitrariamente la ganancia del DQN.

No cambiar de entrada a los tacometros del QUBE: estan disponibles pero
constituyen otro estimador respecto al utilizado para entrenar. La comparacion
con ellos puede ayudar a validar velocidades y escalas antes de sustituirlo.
Revisar las opciones de compensacion de zona muerta del driver; el hardware
puede aplicar compensaciones adicionales al comando solicitado. Esto es
especialmente relevante con acciones pequenas de 0.3 V.

## 8. Funcionamiento del supervisor

| estado | Significado | Vm |
|---|---|---|
| 0 | Desarmado | 0 |
| 1 | Esperando una secuencia valida de armado | 0 |
| 2 | Controlando | Accion DQN mantenida 10 ms |
| 3 | Disparo enclavado o muestra invalida | 0 |

Para armar debe haberse observado armar=false desde el arranque, y luego un
flanco false->true. En ese flanco exige al menos 100 muestras validas,
|alpha|<=5 grados, |theta|<=15 grados y ambas velocidades <=1 rad/s.
Es una ventana inicial conservadora elegida para este paquete, no un
resultado del entrenamiento. Si no se cumple, volver a false y repetir
cuando las condiciones sean validas. El supervisor no hace swing-up.

Durante control, |alpha|>=15 grados, |theta|>=90 grados, fallo de hardware,
entrada no finita o Q no finita fuerzan cero y enclavan la salida. Aunque
el pendulo vuelva a la vertical, no reengancha hasta desarmar y volver a armar.
Una muestra invalida se informa como estado=3 tambien estando desarmado.

Enviar cero no frena mecanicamente ni garantiza detener el movimiento por
inercia. El limite de software y el Switch tampoco cubren por si solos una
tarea bloqueada. En la configuracion HIL de su template comprobar salida
inicial/final del motor a cero y el apagado del amplificador. El driver del
QUBE-Servo 3 admite watchdog y valores de salida al vencer; habilitarlo por
el mecanismo documentado del template, sin crear otra instancia de la placa.
No usar exclusivamente Stop Simulation suponiendo que la ultima escritura
de cero ocurrira antes de terminar la tarea.

## 9. Orden de validacion

1. Aprobar exportar_dqn_quarc y verificar_controlador en MATLAB.
2. En una copia de la simulacion no lineal, reemplazar RL Agent por la
   inferencia exportada y el NUEVO estimador. La planta continua conserva
   un solver apropiado en esa prueba de simulacion; no convertir integradores
   del modelo fisico simulado a FixedStepDiscrete. Muestrear sus posiciones
   a 1 ms para el controlador y mantener el voltaje entre decisiones.
   Comparar con el agente original usando las mismas condiciones iniciales.
   Para armar automaticamente SOLO en esta simulacion, esperar a observar
   false y luego producir un flanco controlado; no reutilizarlo en hardware.
3. Incluir condiciones perturbadas, cuantizacion y retardo plausibles. Si
   el estimador nuevo cambia demasiado la respuesta, corregir/validar el
   preprocesamiento o reentrenar antes de atribuirlo al hardware.
4. Compilar el modelo real y ejecutar Monitor & Tune con armar=false.
   Comprobar lectura de angulos/velocidades y salida cero al disparar/desarmar.
5. Verificar que no haya overruns a 1 ms y que nuevaAccion tenga pulsos
   separados 10 ms durante control. Si no soporta 1 ms, detenerse y adaptar
   Tb, filtro y divisor de cadencia de forma coherente; no cambiar un solo campo.
6. Iniciar la prueba de balance desde cerca de la vertical superior, en el
   procedimiento de laboratorio autorizado, con posibilidad de detener salida.
   Mantener registro de theta, alpha, velocidades, comando, estado y tiempos.

La politica original se entreno para balance en una region local. Colgar el
pendulo y pulsar Monitor & Tune no es una prueba de balance ni de swing-up.
Resolver la compilacion elimina los errores de software identificados;
la estabilidad real exige validar signos, escalas, temporizacion y modelo.

## 10. Lo revisado y lo pendiente

Revisado directamente en los adjuntos:

- entrenamiento.m declara 4-128-128-9, ReLU y sin normalizacion de entrada.
- Acciones [-8,-4,-1.5,-0.3,0,0.3,1.5,4,8] y agente de 10 ms.
- PenduloQUBE.slx tiene filtros continuos [1 0]/[0.005 1], ode4 a 1 ms,
  una tarea y target grt.tlc; contiene planta no lineal simulada.
- Recompensa y limites corresponden al contexto proporcionado.
- El PDF pide comparacion con control de referencia, robustez +/-2%,
  resultados reales/simulados y documentacion de estimacion de velocidades.

Actualizacion tras recibir los archivos fisicos y las versiones:

- MATLAB R2025b Update 2 y QUARC 2025 SP1 (25.1.5062): la combinacion de
  versiones MATLAB/QUARC esta admitida por las notas oficiales de Quanser.
- pruebaReal.slx usa quarc_win64.tlc, ode4, paso 0.002 y una tarea. Se propone
  cambiarlo a FixedStepDiscrete, 0.001 y conservar el target.
- Counts to Angles tiene theta=-2*pi/(512*4)*cuentasBrazo y
  alpha=mod(2*pi/(512*4)*cuentasPendulo,2*pi)-pi.
- HIL Initialize pone las cuentas de ambos encoders en cero al arrancar.
  Con esta conversion hay que arrancar con el brazo centrado y el pendulo
  COLGANDO. Luego se levanta sin reiniciar para medir alpha cercano a cero.
- HIL Read Timebase usa el periodo fundamental del modelo; no necesita un
  campo propio de Sample time. HIL Write tiene sample_time=-1 y puede fijarse
  explicitamente a 0.001 en la copia.
- Analog output inicial/final es cero y digital output final es cero.
  Hay valores de watchdog configurados pero no aparece un bloque HIL Watchdog;
  esos valores por si solos no activan el watchdog.
- La exportacion comprueba la politica en CPU aunque el entrenamiento
  indicara UseDevice=gpu. No hace falta entrenar otra vez.

No comprobado: reconstruccion MATLAB del objeto guardado, pesos y acciones
del agente, entrenamiento de 1000 episodios, desempeno anunciado, compilacion
C, ejecucion QUARC, sentidos fisicos del motor/encoders ni estabilidad real.
No es necesario reenviar los archivos ya recibidos.

## Documentacion primaria consultada

- [MathWorks: getModel](https://www.mathworks.com/help/reinforcement-learning/ref/rl.function.rlcontinuousdeterministicactor.getmodel.html)
- [MathWorks: coder.load](https://www.mathworks.com/help/coder/ref/coder.load.html)
- [MathWorks: despliegue de politicas](https://www.mathworks.com/help/reinforcement-learning/ug/generate-code-from-trained-policies.html)
- [MathWorks: bloque Policy](https://www.mathworks.com/help/reinforcement-learning/ref/policy.html)
- [MathWorks: conversion continua/discreta y Tustin](https://www.mathworks.com/help/control/ug/continuous-discrete-conversion-methods.html)
- [Quanser: QUBE-Servo 3, canales, watchdog y compensaciones](https://docs.quanser.com/quarc/documentation/qube_servo3_usb.html)
- [Quanser: HIL Read Timebase](https://docs.quanser.com/quarc/documentation/hil_read_timebase_block.html)
