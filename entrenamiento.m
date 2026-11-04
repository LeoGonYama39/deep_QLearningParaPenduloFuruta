% =========================================================================
% Proyecto Final - Control Inteligente (Equipo 4)
% Planta: Quanser QUBE-Servo 3 (Péndulo Invertido Rotatorio)
% Algoritmo: Deep Q-Network (DQN) con GPU y Checkpoints
% =========================================================================
clear; clc; close all;

%% 1. Configuración de Modo de Ejecución (Nuevo vs. Reanudar)
% -------------------------------------------------------------------------
% - Pon reanudar_entrenamiento = false para iniciar desde cero.
% - Pon reanudar_entrenamiento = true para continuar desde un archivo .mat
reanudar_entrenamiento = true; 

% Carpeta donde se guardarán los avances automáticamente
carpeta_checkpoints = 'checkpoints_dqn/intento2';
if ~exist(carpeta_checkpoints, 'dir')
    mkdir(carpeta_checkpoints);
end

% Nombre del archivo a cargar si reanudar_entrenamiento == true
archivo_a_reanudar = fullfile(carpeta_checkpoints, 'Agente_Pausado_20261104_160552.mat');

%% 2. Parámetros del Entorno y Simulink
% -------------------------------------------------------------------------
modelo = 'PenduloQUBE'; % Nombre exacto de tu archivo .slx
load_system(modelo);

Ts = 0.01;              % Período de muestreo: 10 ms (100 Hz)
T_final = 5.0;          % Duración máxima del episodio: 5 s (500 pasos)

% Condiciones iniciales base en el Workspace (requeridas por los integradores)
theta0 = 0;
alpha0 = deg2rad(2);    % Inicia ligeramente inclinado (2 grados)

% 2.1 Espacio de Observaciones: s_k = [theta; alpha; theta_dot; alpha_dot]
num_obs = 4;
obsInfo = rlNumericSpec([num_obs 1], ...
    'LowerLimit', [-deg2rad(90); -deg2rad(15); -inf; -inf], ...
    'UpperLimit', [ deg2rad(90);  deg2rad(15);  inf;  inf]);
obsInfo.Name = 'estados_péndulo';
obsInfo.Description = 'theta, alpha, theta_dot, alpha_dot';

% 2.2 Espacio de Acciones Discreto (Voltaje Vm en Volts)
% Más denso cerca de 0 V para evitar chattering (tirones) cuando ya está en equilibrio
niveles_voltaje = [-8, -4, -1.5, -0.3, 0, 0.3, 1.5, 4, 8];
num_acciones = numel(niveles_voltaje);

actInfo = rlFiniteSetSpec(niveles_voltaje);
actInfo.Name = 'voltaje_motor';

% Creación del entorno vinculando el bloque RL Agent
bloque_agente = [modelo '/RL Agent'];
env = rlSimulinkEnv(modelo, bloque_agente, obsInfo, actInfo);

% Función de reinicio aleatorio al inicio de cada episodio (Algoritmo 1, línea 3)
env.ResetFcn = @(in) localResetFcn(in, modelo);

%% 3. Creación o Recuperación del Agente DQN
% -------------------------------------------------------------------------
if reanudar_entrenamiento
    if isfile(archivo_a_reanudar)
        fprintf('--> Cargando agente previo desde: %s\n', archivo_a_reanudar);
        datos = load(archivo_a_reanudar);
        if isfield(datos, 'saved_agent')
            agente = datos.saved_agent;
        elseif isfield(datos, 'savedAgent')
            agente = datos.savedAgent;
        elseif isfield(datos, 'agente')
            agente = datos.agente;
        else
            error('El archivo .mat no contiene un objeto de agente reconocido.');
        end
        fprintf('--> Agente cargado con éxito. Listo para continuar.\n');
        if isfield(datos, 'eps_final')
            agente.AgentOptions.EpsilonGreedyExploration.Epsilon = datos.eps_final;
            fprintf('--> Epsilon restaurado exactamente en: %.4f\n', datos.eps_final);
        end
    else
        error('No se encontró el archivo %s. Verifica el nombre en la carpeta.', archivo_a_reanudar);
    end
else
    fprintf('--> Creando nueva red neuronal Q(s,a;phi) y agente DQN desde cero...\n');
    
    % Arquitectura de la Red Q (4 entradas -> 128 -> 128 -> 9 salidas Q)
    redQ = [
        featureInputLayer(num_obs, 'Normalization', 'none', 'Name', 'state')
        fullyConnectedLayer(128, 'Name', 'fc1')
        reluLayer('Name', 'relu1')
        fullyConnectedLayer(128, 'Name', 'fc2')
        reluLayer('Name', 'relu2')
        fullyConnectedLayer(num_acciones, 'Name', 'Q_values')
    ];
    
    redQ_dl = dlnetwork(redQ);
    
    % Opciones del optimizador del Crítico (Adam + GPU)
    criticOpts = rlOptimizerOptions( ...
        'LearnRate', 1e-3, ...          % Tasa de aprendizaje (eta)
        'GradientThreshold', 1.0);      % Evita explosión de gradientes
    
    % Función de valor Q vectorial en la GPU
    critic = rlVectorQValueFunction(redQ_dl, obsInfo, actInfo, ...
        'ObservationInputNames', 'state', ...
        'UseDevice', 'gpu');            % <--- ACELERACIÓN POR GPU ACTIVADA
    
    % Hiperparámetros del Agente DQN (Algoritmo 1 del documento)
    agentOpts = rlDQNAgentOptions( ...
        'SampleTime', Ts, ...
        'DiscountFactor', 0.99, ...             % Factor de descuento (gamma)
        'ExperienceBufferLength', 1e5, ...      % Capacidad de memoria D (N)
        'MiniBatchSize', 128, ...               % Tamaño de lote (B)
        'TargetUpdateFrequency', 200, ...       % Período actualización red objetivo (C)
        'TargetSmoothFactor', 1.0, ...          % 1.0 = Copia dura cada C pasos (como en el PDF)
        'UseDoubleDQN', true, ...               % Mejora estabilidad evitando sobreestimar Q
        'CriticOptimizerOptions', criticOpts);
    
    % Programa de exploración Epsilon-Greedy (Algoritmo 1, línea 5 y 12)
    agentOpts.EpsilonGreedyExploration.Epsilon = 1.0;      % Exploración inicial 100%
    agentOpts.EpsilonGreedyExploration.EpsilonMin = 0.02;  % Exploración mínima 2%
    agentOpts.EpsilonGreedyExploration.EpsilonDecay = 1e-4;% Decaimiento por paso
    
    % Instanciar el Agente DQN
    agente = rlDQNAgent(critic, agentOpts);
end

%% 4. Configuración del Entrenamiento y Guardado Automático
% -------------------------------------------------------------------------
max_pasos = floor(T_final / Ts); % 500 pasos por episodio

trainOpts = rlTrainingOptions( ...
    'MaxEpisodes', 1000, ...
    'MaxStepsPerEpisode', max_pasos, ...
    'ScoreAveragingWindowLength', 20, ...
    'Plots', 'training-progress', ...
    'Verbose', true, ...
    'StopTrainingCriteria', 'AverageReward', ...
    'StopTrainingValue', 475, ...
    'SaveAgentCriteria', 'none');

%% 5. Ejecución del Entrenamiento y Respaldo Final
% -------------------------------------------------------------------------
entrenar = true; % Cambia a false cuando solo quieras simular el agente ya entrenado

if entrenar
    fprintf('--> Iniciando entrenamiento en GPU...\n');
    fprintf('    (Si presionas "Stop" en la gráfica, el agente se guardará automáticamente al salir)\n\n');
    
    trainingStats = train(agente, env, trainOpts);
    
    % 1. Calcular el total acumulado de pasos de esta sesión
    pasos_totales_sesion = sum(trainingStats.EpisodeSteps);
    
    % 2. Leer o actualizar el epsilon exacto actual
    eps_actual = agente.AgentOptions.EpsilonGreedyExploration.Epsilon;
    decay_rate = agente.AgentOptions.EpsilonGreedyExploration.EpsilonDecay;
    eps_min    = agente.AgentOptions.EpsilonGreedyExploration.EpsilonMin;
    eps_final  = max(eps_min, eps_actual * ((1 - decay_rate)^pasos_totales_sesion));
    
    % 3. Guardar todo en el .mat
    fecha_str = char(datetime('now', 'Format', 'yyyyMMdd_HHmmss'));
    nombre_respaldo = fullfile(carpeta_checkpoints, ['Agente_Pausado_' fecha_str '.mat']);
    save(nombre_respaldo, 'agente', 'trainingStats', 'eps_final');
    
    fprintf('\n--> Agente guardado en: %s\n', nombre_respaldo);
    fprintf('    Episodios corridos en sesion: %d\n', numel(trainingStats.EpisodeReward));
    fprintf('    Epsilon exacto para reanudar: %.4f\n', eps_final);
end

% =========================================================================
% Función Local: Condiciones Iniciales Aleatorias por Episodio
% =========================================================================
function in = localResetFcn(in, modelo)
    % Algoritmo 1, Línea 3: Inicializar s_0 con condiciones aleatorias
    % Alpha inicial entre -5° y +5° (evita que nazca exactamente en 0° y no aprenda a corregir)
    alpha_init = deg2rad((rand() - 0.5) * 10); 
    
    % Theta inicial entre -15° y +15°
    theta_init = deg2rad((rand() - 0.5) * 30);
    
    in = setVariable(in, 'alpha0', alpha_init, 'Workspace', modelo);
    in = setVariable(in, 'theta0', theta_init, 'Workspace', modelo);
end