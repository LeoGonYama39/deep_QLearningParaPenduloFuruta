function verificar_controlador()
% Pruebas en MATLAB sin QUARC y sin hardware. Requiere pesos ya exportados.
assert(isfile('DQN_pesos.mat'),'Ejecute primero exportar_dqn_quarc.');
clear dqn_policy dqn_qube_rt
for k=1:120
    [u,~,st,tick]=dqn_qube_rt(0,0,false,false);
    assert(u==0 && st==0 && ~tick);
end
% No importar si el DQN decide Vm=0 en el origen: se verifica el tick.
ticks=zeros(1,31);
for k=1:31
    [u,~,st,tick]=dqn_qube_rt(0,0,true,false);
    assert(st==2 && isfinite(u) && abs(u)<=8);
    ticks(k)=tick;
end
assert(isequal(find(ticks),[1 11 21 31]), 'Cadencia incorrecta del DQN.');
[u,~,st]=dqn_qube_rt(0,16*pi/180,true,false);
assert(u==0 && st==3,'No se detuvo al caer.');
for k=1:120
    [u,~,st]=dqn_qube_rt(0,0,true,false);
    assert(u==0 && st==3,'Reenganche automatico despues del disparo.');
end
for k=1:120, dqn_qube_rt(0,0,false,false); end
[~,~,st]=dqn_qube_rt(0,0,true,false); assert(st==2);
[u,~,st]=dqn_qube_rt(0,0,true,true); assert(u==0 && st==3);
clear dqn_qube_rt
[u,~,st]=dqn_qube_rt(0,0,true,false);
assert(u==0 && st~=2,'Arranque automatico con armar=1.');
clear dqn_qube_rt
for k=1:120, dqn_qube_rt(0,0,false,false); end
[~,~,st]=dqn_qube_rt(0,0,true,false); assert(st==2);
[u,~,st]=dqn_qube_rt(NaN,0,true,false); assert(u==0 && st==3);
clear dqn_qube_rt
fprintf('Pruebas MATLAB aprobadas: cadencia, desarmado, caida, enclavamiento, fallo y NaN.\n');
fprintf('Esto no verifica tiempos de QUARC, encoders ni estabilidad de la planta.\n');
end
