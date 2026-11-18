% =========================================================================
% Script de Evaluación del Agente Entrenado (Sin exploración al azar)
% =========================================================================
clear; clc; close all;

% 1. Cargar el agente
archivo = 'checkpoints_dqn/intento2/agente3.mat'; 
datos = load(archivo);
if isfield(datos, 'agente')
    agente = datos.agente;
elseif isfield(datos, 'saved_agent')
    agente = datos.saved_agent;
end

% 2. Parámetros del modelo para una prueba de 10 segundos
modelo = 'PenduloQUBE';
load_system(modelo);
Ts = 0.01;
T_final = 10.0;

% -------------------------------------------------------------------------
% Condiciones iniciales (Con el nombre EXACTO que piden los integradores)
% -------------------------------------------------------------------------


    alpha0 = deg2rad((rand() - 0.5) * 20); 
    theta0 = deg2rad((rand() - 0.5) * 60);
    
    % 3. Velocidad inicial del péndulo (Simulación inteligente de Swing-Up + Empujones)
    if rand() < 0.5
        % CASO A (50% de episodios): Escenario de "Cachar el Swing-Up"
        % El péndulo entra por un extremo (-10° o +10°) moviéndose HACIA el centro (0°)
        % Velocidad alta: hasta 130°/s (2.26 rad/s) en dirección opuesta al signo de alpha_init
        mag_vel = deg2rad(30 + rand() * 100); % Entre 30°/s y 130°/s
        alpha_dot0 = -sign(alpha0) * mag_vel;
    else
        % CASO B (50% de episodios): Empujón aleatorio en cualquier dirección
        % Si va hacia afuera, limitamos a ±60°/s para que sea físicamente salvable con 8V
        alpha_dot0 = deg2rad((rand() - 0.5) * 120); % Entre -60°/s y +60°/s
    end
    theta_dot0 = deg2rad((rand() - 0.5) * 300);
    


fprintf('=== Valores iniciales aleatorios ===\n');
fprintf('  alpha0     = %+6.2f deg (%+.4f rad)\n', rad2deg(alpha0), alpha0);
fprintf('  theta0     = %+6.2f deg (%+.4f rad)\n', rad2deg(theta0), theta0);
fprintf('  alpha_dot0 = %+6.2f deg/s (%+.4f rad/s)\n', rad2deg(alpha_dot0), alpha_dot0);
fprintf('  theta_dot0 = %+6.2f deg/s (%+.4f rad/s)\n\n', rad2deg(theta_dot0), theta_dot0);

% 3. Apagar por completo la exploración aleatoria para evaluar
agente.UseExplorationPolicy = false; 

% 4. Correr la simulación en Simulink
fprintf('--> Simulando el sistema con el agente entrenado (0%% azar)...\n');
out = sim(modelo);

% 5. Extraer datos de los bloques To Workspace
t = out.log_estados.Time;
estados = squeeze(out.log_estados.Data); % [theta, alpha, theta_dot, alpha_dot]
if size(estados, 1) == 4 && size(estados, 2) ~= 4
    estados = estados';
end
theta_deg = rad2deg(estados(:, 1));
alpha_deg = rad2deg(estados(:, 2));

t_v = out.log_voltaje.Time;
Vm  = squeeze(out.log_voltaje.Data);

% 6. Graficar resultados (Con alto contraste para Modo Oscuro)
figure('Color', [1 1 1], 'Position', [100, 100, 900, 650]);

ax1 = subplot(3,1,1);
plot(t, alpha_deg, 'b', 'LineWidth', 1.5); hold on;
yline(0, '--k'); yline(15, ':r'); yline(-15, ':r');
ylabel('\alpha (grados)', 'Color', 'k');
title(sprintf('Ángulo del Péndulo (\\alpha) | Inicio: \\alpha_0 = %.1f°, d\\alpha_0 = %.1f°/s', ...
      rad2deg(alpha0), rad2deg(alpha_dot0)), 'Color', 'k', 'FontWeight', 'bold');
set(ax1, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'GridColor', [0.7 0.7 0.7]);
grid on;

ax2 = subplot(3,1,2);
plot(t, theta_deg, 'Color', [0 0.5 0], 'LineWidth', 1.5); hold on;
yline(0, '--k');
ylabel('\theta (grados)', 'Color', 'k');
title(sprintf('Ángulo del Brazo Rotatorio (\\theta) | Inicio: \\theta_0 = %.1f°, d\\theta_0 = %.1f°/s', ...
      rad2deg(theta0), rad2deg(theta_dot0)), 'Color', 'k', 'FontWeight', 'bold');
set(ax2, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'GridColor', [0.7 0.7 0.7]);
grid on;

ax3 = subplot(3,1,3);
stairs(t_v, Vm, 'r', 'LineWidth', 1.2);
ylabel('Voltaje V_m (V)', 'Color', 'k');
xlabel('Tiempo (s)', 'Color', 'k');
title('Acción de Control del Agente DQN', 'Color', 'k', 'FontWeight', 'bold');
ylim([-11 11]);
set(ax3, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'GridColor', [0.7 0.7 0.7]);
grid on;