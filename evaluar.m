% =========================================================================
% Script de Evaluación del Agente Entrenado (Sin exploración al azar)
% =========================================================================
clear; clc; close all;

% 1. Cargar el agente
archivo = 'checkpoints_dqn/intento2/Agente_Pausado_20261104_160552.mat'; % <-- AJUSTA EL NOMBRE
datos = load(archivo);
agente = datos.agente;

% 2. Parámetros del modelo para una prueba de 10 segundos
modelo = 'PenduloQUBE';
load_system(modelo);
Ts = 0.01;
T_final = 10.0;

% Condición inicial de prueba exigente: péndulo inclinado a 8 grados y brazo a 15 grados
alpha0 = deg2rad(-5);
theta0 = deg2rad(4);

% 3. Apagar por completo la exploración aleatoria para evaluar
agente.UseExplorationPolicy = false; 

% 4. Correr la simulación en Simulink
fprintf('--> Simulando el sistema con el agente entrenado (0%% azar)...\n');
out = sim(modelo);

% 5. Extraer datos de los bloques To Workspace
t = out.log_estados.Time;
estados = squeeze(out.log_estados.Data); % [theta, alpha, theta_dot, alpha_dot]
% Si las dimensiones vienen transpuestas, asegurar que sean 4 columnas:
if size(estados, 1) == 4 && size(estados, 2) ~= 4
    estados = estados';
end

theta_deg = rad2deg(estados(:, 1));
alpha_deg = rad2deg(estados(:, 2));

t_v = out.log_voltaje.Time;
Vm  = squeeze(out.log_voltaje.Data);

% 6. Graficar resultados (Formato para revisión de desempeño)
figure('Color', 'w', 'Position', [100, 100, 900, 650]);

subplot(3,1,1);
plot(t, alpha_deg, 'b', 'LineWidth', 1.5); hold on;
yline(0, '--k'); yline(15, ':r'); yline(-15, ':r');
ylabel('\alpha (grados)');
title('Ángulo del Péndulo (\alpha) - Referencia: 0°');
grid on;

subplot(3,1,2);
plot(t, theta_deg, 'Color', [0 0.5 0], 'LineWidth', 1.5); hold on;
yline(0, '--k');
ylabel('\theta (grados)');
title('Ángulo del Brazo Rotatorio (\theta) - Referencia: 0°');
grid on;

subplot(3,1,3);
stairs(t_v, Vm, 'r', 'LineWidth', 1.2);
ylabel('Voltaje V_m (V)');
xlabel('Tiempo (s)');
title('Acción de Control del Agente DQN');
ylim([-11 11]);
grid on;