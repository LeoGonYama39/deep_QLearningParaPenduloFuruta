% =========================================================================
% Re-entrenamiento (Fine-Tuning Robusto Sim-to-Real) con GPU Forzada
% =========================================================================
clear; clc;

%% 1. Configuración de Reanudación y Archivos
reanudar_entrenamiento = true; 

carpeta_checkpoints = 'checkpoints_dqn/intento2'; 
archivo_a_reanudar = fullfile(carpeta_checkpoints, 'agente2.mat'); % <-- PON TU ARCHIVO AQUÍ

%% 2. Variables Iniciales del Entorno en el Workspace
modelo = 'PenduloQUBE';
load_system(modelo);

Ts = 0.01;
T_final = 5.0;

% Condiciones iniciales base (se sobreescriben en cada episodio por localResetFcn)
theta0 = 0;
alpha0 = deg2rad(2);
theta_dot0 = 0; 
alpha_dot0 = 0; 

% Especificación de Observaciones (4x1) y Acciones (9 niveles)
num_obs = 4;
obsInfo = rlNumericSpec([num_obs 1], ...
    'LowerLimit', [-deg2rad(90); -deg2rad(15); -inf; -inf], ...
    'UpperLimit', [ deg2rad(90);  deg2rad(15);  inf;  inf]);

niveles_voltaje = [-8, -4, -1.5, -0.3, 0, 0.3, 1.5, 4, 8];
actInfo = rlFiniteSetSpec(niveles_voltaje);

bloque_agente = [modelo '/RL Agent'];
env = rlSimulinkEnv(modelo, bloque_agente, obsInfo, actInfo);
env.ResetFcn = @(in) localResetFcn(in, modelo);

%% 3. Cargar el Agente 2, Forzar GPU y Ajustar Fine-Tuning
if reanudar_entrenamiento
    if ~isfile(archivo_a_reanudar)
        error('No se encontró el archivo: %s', archivo_a_reanudar);
    end
    
    fprintf('--> Cargando Agente desde: %s\n', archivo_a_reanudar);
    datos = load(archivo_a_reanudar);
    
    if isfield(datos, 'agente')
        agente = datos.agente;
    elseif isfield(datos, 'saved_agent')
        agente = datos.saved_agent;
    end

    critic = getCritic(agente);
    critic.UseDevice = 'gpu';
    agente = setCritic(agente, critic);
    
    % Ajustar hiperparámetros para Fine-Tuning bajo perturbaciones fuertes
    agente.UseExplorationPolicy = true; 
    agente.AgentOptions.EpsilonGreedyExploration.Epsilon = 0.08; 
    agente.AgentOptions.EpsilonGreedyExploration.EpsilonMin = 0.01;
    agente.AgentOptions.EpsilonGreedyExploration.EpsilonDecay = 1e-5;

    % Tasa de aprendizaje suave para afinar pesos sin olvido catastrófico
    agente.AgentOptions.CriticOptimizerOptions.LearnRate = 2e-4;
    
    fprintf('--> Dispositivo del Crítico confirmado en: %s\n', upper(critic.UseDevice));
end

%% 4. Opciones de Entrenamiento y Ejecución
max_pasos = floor(T_final / Ts);

trainOpts = rlTrainingOptions( ...
    'MaxEpisodes', 1000, ...
    'MaxStepsPerEpisode', max_pasos, ...
    'ScoreAveragingWindowLength', 20, ...
    'Plots', 'training-progress', ...
    'Verbose', true, ...
    'StopTrainingCriteria', 'AverageReward', ...
    'StopTrainingValue', 485, ...
    'SaveAgentCriteria', 'EpisodeReward', ...
    'SaveAgentValue', 440, ...
    'SaveAgentDirectory', fullfile(carpeta_checkpoints, 'mejores_agentes3'));

fprintf('--> Iniciando Fine-Tuning en GPU...\n');
try
    trainingStats = train(agente, env, trainOpts);
catch ME
    fprintf('\n[!] Entrenamiento interrumpido: %s\n', ME.message);
end

% Guardar siempre el respaldo al terminar o pausar
fecha_str = char(datetime('now', 'Format', 'yyyyMMdd_HHmmss'));
nombre_respaldo = fullfile(carpeta_checkpoints, ['agente_nuevo' fecha_str '.mat']);
save(nombre_respaldo, 'agente');
fprintf('\n--> ¡Agente guardado con éxito en: %s!\n', nombre_respaldo);

% =========================================================================
% Función Local de Reinicio: Ángulos + Velocidades Iniciales Aleatorias
% =========================================================================
function in = localResetFcn(in, modelo)
    % 1. Ángulo inicial del péndulo entre -10° y +10°
    alpha_init = deg2rad((rand() - 0.5) * 20); 
    
    % 2. Ángulo inicial del brazo entre -30° y +30°
    theta_init = deg2rad((rand() - 0.5) * 60);
    
    % 3. Velocidad inicial del péndulo (Simulación inteligente de Swing-Up + Empujones)
    if rand() < 0.5
        % CASO A (50% de episodios): Escenario de "Cachar el Swing-Up"
        % El péndulo entra por un extremo (-10° o +10°) moviéndose HACIA el centro (0°)
        % Velocidad alta: hasta 130°/s (2.26 rad/s) en dirección opuesta al signo de alpha_init
        mag_vel = deg2rad(30 + rand() * 100); % Entre 30°/s y 130°/s
        alpha_dot_init = -sign(alpha_init) * mag_vel;
    else
        % CASO B (50% de episodios): Empujón aleatorio en cualquier dirección
        % Si va hacia afuera, limitamos a ±60°/s para que sea físicamente salvable con 8V
        alpha_dot_init = deg2rad((rand() - 0.5) * 120); % Entre -60°/s y +60°/s
    end
    
    % 4. Velocidad inicial del brazo del motor: ampliada a ±150°/s (±2.6 rad/s)
    theta_dot_init = deg2rad((rand() - 0.5) * 300);
    
    % Enviar variables al Workspace del modelo
    in = setVariable(in, 'alpha0', alpha_init, 'Workspace', modelo);
    in = setVariable(in, 'theta0', theta_init, 'Workspace', modelo);
    in = setVariable(in, 'alpha_dot0', alpha_dot_init, 'Workspace', modelo);
    in = setVariable(in, 'theta_dot0', theta_dot_init, 'Workspace', modelo);
end