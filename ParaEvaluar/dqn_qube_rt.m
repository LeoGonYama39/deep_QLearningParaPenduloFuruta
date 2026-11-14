function [Vm, s, estado, nuevaAccion] = dqn_qube_rt(theta, alpha, armar, falloHW)
%#codegen
% INVOCAR EXACTAMENTE UNA VEZ CADA 0.001 s.
% theta: radianes continuos del brazo respecto al centro (NO modulo 2*pi).
% alpha: radianes respecto a la vertical superior, intervalo [-pi,pi].
% armar/falloHW: escalares boolean. Vm: voltaje solicitado al driver.
% estado uint8: 0 desarmado, 1 esperando, 2 controlando, 3 disparo enclavado.
% La politica se calcula cada diez ticks; proteccion/filtro en cada tick.
persistent inicializado posPrev velPrev contador uHold ejecutando disparado ...
    vioDesarmado armarPrev muestras
if isempty(inicializado)
    inicializado=false; posPrev=zeros(2,1); velPrev=zeros(2,1);
    contador=uint8(0); uHold=0.0; ejecutando=false; disparado=false;
    vioDesarmado=false; armarPrev=false; muestras=uint16(0);
end
Vm=0.0; s=zeros(4,1); estado=uint8(0); nuevaAccion=false;
pos=[theta;alpha];
if ~all(isfinite(pos))
    inicializado=false; muestras=uint16(0);
    ejecutando=false; uHold=0.0; contador=uint8(0);
    if armar, disparado=true; end
    if ~armar, disparado=false; vioDesarmado=true; end
    armarPrev=armar;
    estado=uint8(3); return;
end
if ~inicializado
    posPrev=pos; velPrev=zeros(2,1); inicializado=true;
end
% Tustin de s/(0.005s+1) con Tb=0.001:
% v[k]=(9/11)*v[k-1]+(2000/11)*(p[k]-p[k-1]).
delta=pos-posPrev;
% Evita un salto falso de 2*pi al cruzar el corte del pendulo.
delta(2)=atan2(sin(delta(2)),cos(delta(2)));
vel=(9.0/11.0)*velPrev+(2000.0/11.0)*delta;
posPrev=pos; velPrev=vel;
if muestras<uint16(100), muestras=muestras+uint16(1); end
s=[theta;alpha;vel(1);vel(2)];
if ~armar
    ejecutando=false; disparado=false; uHold=0.0; contador=uint8(0);
    vioDesarmado=true; armarPrev=false;
    return;
end
flanco=~armarPrev; armarPrev=true;
if falloHW || ~all(isfinite(s))
    disparado=true;
end
if disparado
    ejecutando=false; uHold=0.0; estado=uint8(3); return;
end
if ~ejecutando
    estado=uint8(1);
    if ~vioDesarmado || ~flanco, return; end
    % Ventana inicial conservadora; ajustarla solo tras validar en simulacion.
    listo=muestras>=uint16(100) && abs(alpha)<=5*pi/180 && ...
        abs(theta)<=15*pi/180 && abs(vel(1))<=1 && abs(vel(2))<=1;
    if ~listo
        disparado=true; estado=uint8(3); return;
    end
    ejecutando=true; contador=uint8(0);
end
% Salida cero inmediata y sin reenganche automatico al volver a la ventana.
if abs(alpha)>=15*pi/180 || abs(theta)>=90*pi/180
    disparado=true; ejecutando=false; uHold=0.0; estado=uint8(3); return;
end
if contador==uint8(0)
    [u,~,~,valido]=dqn_policy(s);
    if ~valido
        disparado=true; ejecutando=false; uHold=0.0; estado=uint8(3); return;
    end
    uHold=u; nuevaAccion=true;
end
contador=contador+uint8(1);
if contador>=uint8(10), contador=uint8(0); end
% Se conserva el conjunto aprendido. No se escala ni recorta a otro rango.
Vm=max(-8.0,min(8.0,uHold));
estado=uint8(2);
end
