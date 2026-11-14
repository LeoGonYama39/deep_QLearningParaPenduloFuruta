function informe = exportar_dqn_quarc(archivo, nombreVariable, estadosExtra)
% EXPORTAR_DQN_QUARC Exporta y verifica el DQN en el MATLAB anfitrion.
% No entrena, no compila QUARC y no mueve hardware.
% Uso: exportar_dqn_quarc('MiAgente.mat','agente')
% Opcional: estadosExtra 4xN de observaciones registradas.
% Ejecutar con Current Folder = carpeta de este paquete.
if nargin < 2, nombreVariable = ''; end
if nargin < 3, estadosExtra = zeros(4,0); end
assert(isfile(archivo), 'No existe el archivo de agente.');
assert(size(estadosExtra,1)==4 && all(isfinite(estadosExtra(:))), ...
    'estadosExtra debe ser 4xN finito.');
D = load(archivo);
if isempty(nombreVariable)
    nombres = fieldnames(D); candidatos = {};
    for k = 1:numel(nombres)
        if isa(D.(nombres{k}),'rl.agent.rlDQNAgent')
            candidatos{end+1} = nombres{k}; %#ok<AGROW>
        end
    end
    assert(numel(candidatos)==1, ...
        'Indique el nombre de la variable del agente como segundo argumento.');
    nombreVariable = candidatos{1};
end
assert(isfield(D,nombreVariable), 'Variable del agente no encontrada.');
agente = D.(nombreVariable);
assert(isa(agente,'rl.agent.rlDQNAgent'), 'Se requiere un rlDQNAgent.');
agente.UseExplorationPolicy = false;
assert(abs(agente.AgentOptions.SampleTime-0.01)<1e-12, ...
    'Este paquete espera un agente entrenado con Ts=0.01.');
oi = getObservationInfo(agente);
assert(numel(oi)==1 && isequal(oi.Dimension,[4 1]), 'Observacion esperada: 4x1.');
ai = getActionInfo(agente);
assert(numel(ai)==1, 'Se espera un canal de accion.');
A = ai.Elements;
if iscell(A)
    assert(all(cellfun(@(x) isnumeric(x) && isscalar(x),A)), ...
        'Las acciones deben ser voltajes escalares.');
    A = cellfun(@double,A);
end
A = double(A(:));
assert(isequal(A,[-8;-4;-1.5;-0.3;0;0.3;1.5;4;8]), ...
    'Conjunto/orden de acciones diferente al declarado. No se reordena.');
% La verificacion se hace en CPU aunque el entrenamiento haya usado GPU.
% No se cambia ningun peso ni se guarda sobre el checkpoint original.
critic = getCritic(agente);
critic.UseDevice = 'cpu';
agente = setCritic(agente,critic);
net = getModel(critic);
assert(isa(net,'dlnetwork'), 'Se esperaba dlnetwork.');
if isprop(critic,'Normalization')
    assert(all(strcmp(string(critic.Normalization),'none')), ...
        'El critico contiene normalizacion adicional; no exportar asi.');
end
L = net.Layers;
tipos = {'nnet.cnn.layer.FeatureInputLayer', ...
    'nnet.cnn.layer.FullyConnectedLayer','nnet.cnn.layer.ReLULayer', ...
    'nnet.cnn.layer.FullyConnectedLayer','nnet.cnn.layer.ReLULayer', ...
    'nnet.cnn.layer.FullyConnectedLayer'};
assert(numel(L)==6, 'Red no compatible: deben ser seis capas.');
for k=1:6
    assert(isa(L(k),tipos{k}), 'Secuencia de capas no compatible.');
end
assert(strcmp(string(L(1).Normalization),'none'), ...
    'Se esperaba featureInputLayer con Normalization=none.');
assert(L(1).InputSize==4, 'La entrada debe tener cuatro estados.');
assert(L(2).OutputSize==128 && L(4).OutputSize==128 && L(6).OutputSize==9, ...
    'Arquitectura esperada: 4-128-128-9.');
C = net.Connections;
assert(height(C)==5, 'La red debe ser una cadena simple.');
for k=1:5
    assert(any(strcmp(string(C.Source),L(k).Name) & ...
        strcmp(string(C.Destination),L(k+1).Name)), ...
        'Conexiones no compatibles con una cadena FC-ReLU.');
end
W1 = parametro(net,L(2).Name,'Weights');
b1 = parametro(net,L(2).Name,'Bias');
W2 = parametro(net,L(4).Name,'Weights');
b2 = parametro(net,L(4).Name,'Bias');
W3 = parametro(net,L(6).Name,'Weights');
b3 = parametro(net,L(6).Name,'Bias');
assert(isequal(size(W1),[128 4]) && isequal(size(b1),[128 1]));
assert(isequal(size(W2),[128 128]) && isequal(size(b2),[128 1]));
assert(isequal(size(W3),[9 128]) && isequal(size(b3),[9 1]));

% Verificacion ANTES de escribir pesos: red online vs algebra en double.
% El margen entre las dos mejores Q distingue errores de casi empates.
rngPrev = rng; restaurar = onCleanup(@() rng(rngPrev)); %#ok<NASGU>
rng(114,'twister');
S = [zeros(4,1), diag([pi/12,pi/36,0.5,0.5]), ...
    -diag([pi/12,pi/36,0.5,0.5]), ...
    [pi/2;pi/12;5;5].*(2*rand(4,256)-1), double(estadosExtra)];
errorMax = 0; cambios = 0; casiEmpates = 0;
for k=1:size(S,2)
    s = S(:,k);
    q = W3*max(W2*max(W1*s+b1,0)+b2,0)+b3;
    ref = numericCPU(getValue(critic,{s})); ref = ref(:);
    assert(numel(ref)==9 && all(isfinite(ref)), 'Q de referencia invalida.');
    err = max(abs(q-ref));
    tol = 2e-5*max(1,max(abs(ref)));
    assert(err<=tol, 'La exportacion NO coincide con getValue; no desplegar.');
    errorMax = max(errorMax,err);
    [~,im] = max(q); [~,ir] = max(ref);
    orden = sort(ref,'descend'); casi = orden(1)-orden(2)<=2*tol;
    casiEmpates = casiEmpates + casi;
    ar = getAction(agente,{s});
    if iscell(ar), ar=ar{1}; end
    ar = numericCPU(ar);
    if im~=ir || A(im)~=ar
        cambios = cambios + 1;
        assert(casi, 'La accion difiere sin casi empate. No desplegar.');
    end
end
informe = struct('archivoOrigen',char(archivo),'variable',char(nombreVariable), ...
    'estadosVerificados',size(S,2),'errorQMaximo',errorMax, ...
    'casiEmpates',casiEmpates,'cambiosAccion',cambios, ...
    'fecha',char(datetime('now')),'versionMATLAB',version, ...
    'TsAgente',0.01,'TsBase',0.001);
% Este MAT contiene exclusivamente siete arreglos double, sin objetos.
save('DQN_pesos.mat','W1','b1','W2','b2','W3','b3','A','-v7');
save('DQN_verificacion.mat','informe','S','-v7');
clear dqn_policy dqn_qube_rt
fprintf('Exportacion numerica verificada: %d estados, max |dQ|=%g.\n', ...
    informe.estadosVerificados,errorMax);
if cambios>0
    warning('%d acciones distintas en casi empates. Revisar antes de probar hardware.',cambios);
end
fprintf('Pesos: %s\n',fullfile(pwd,'DQN_pesos.mat'));
disp(informe);
end

function x = parametro(net,capa,nombre)
T = net.Learnables;
i = strcmp(string(T.Layer),capa) & strcmp(string(T.Parameter),nombre);
assert(nnz(i)==1, 'Parametro no encontrado de forma unica.');
x = numericCPU(T.Value{find(i,1)});
assert(isreal(x) && all(isfinite(x(:))), 'Parametro no finito o complejo.');
end

function x = numericCPU(x)
if isa(x,'dlarray'), x=extractdata(x); end
if isa(x,'gpuArray'), x=gather(x); end
x=double(x);
end
