function configurar_prueba_quarc(modelo)
% Configura solo solver/tarea. No cambia driver, target ni conexiones.
% No compila ni inicia hardware. Guardar como una copia antes de usar.
load_system(modelo);
target=get_param(modelo,'SystemTargetFile');
assert(contains(lower(target),'quarc'), ...
    'Parta del template QUARC funcional: target actual %s.',target);
set_param(modelo,'SolverType','Fixed-step', ...
    'Solver','FixedStepDiscrete','FixedStep','0.001', ...
    'EnableMultiTasking','off');
fprintf('Solver discreto, paso 1 ms, una tarea. Target conservado: %s\n',target);
fprintf(['Falta verificar que QAL/HIL, MATLAB Function y todas las senales\n' ...
    'dinamicas compilen a 0.001 s. No dejar filtros ni bloques continuos.\n']);
end
