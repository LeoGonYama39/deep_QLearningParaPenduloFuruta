function [Vm, Q, indice, valido] = dqn_policy(s)
%#codegen
% Inferencia pura. Entrada double 4x1, Q double 9x1.
% DQN_pesos.mat se incorpora AL COMPILAR, no se carga en el QUBE.
% Reexportar pesos exige limpiar funciones y recompilar el modelo.
persistent P
if isempty(P)
    P = coder.load('DQN_pesos.mat','W1','b1','W2','b2','W3','b3','A');
end
Vm=0.0; Q=zeros(9,1); indice=uint8(0); valido=false;
if ~all(isfinite(s)), return; end
h1 = max(P.W1*s+P.b1,0.0);
h2 = max(P.W2*h1+P.b2,0.0);
Q = P.W3*h2+P.b3;
if ~all(isfinite(Q)), return; end
[~,i] = max(Q); % Primer maximo: desempate determinista.
indice = uint8(i);
Vm = P.A(i);
valido = true;
end
