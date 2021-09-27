%% Практическая работа 3 по МеРСИ...
..."Расчет теплового баланса ректификационной колонны"
clear; clc; format; close all;

%% Исходные данные
x = [4.2 8.2 10.3 12.7 15.8 19.4 22.6 23.6 27.1 29.4 30.7 43.3 55 66.8 76.1 93.5];
y = [10.8 22.5 25.7 31 35.6 43.3 56.4 58 63 66 70.8 84.4 92 96.6 98.1 88.7];

t = [112.1 0 107.4 106.1 104.6 101.4 94.3 92.5 90.4 87 86 78.6 70.8 65.6 63.6 60.7];

GF = 11;
xD = 0.92;
xF = 0.52;
xW = 0.12;

M1 = 12*3+6+16;
M2 = 12*2+4+16*2;

Tkp = 235.1;

xFm = M1*xF / (M1*xF + M2* (1-xF));
xWm = M1*xW / (M1*xW + M2* (1-xW));
xDm = M1*xD / (M1*xD + M2* (1-xD));

for i = 1:length(t)-1
    if (xF >= x(i)/100) && (xF < x(i+1)/100)
        yFs = y(i)/100 + (xF-x(i)/100)/(x(i+1)/100-x(i)/100)*(y(i+1)/100-y(i)/100);
        ts = t(i) + (xF-x(i)/100)/(x(i+1)/100-x(i)/100)*(t(i+1)/100-t(i)/100);
        break;
    end
end

%% Температура
for i = 1:length(t)-1
    if (xD >= x(i)/100) && (xD < x(i+1)/100)
        tD = t(i) + (xD-x(i)/100)/(x(i+1)/100-x(i)/100)*(t(i+1)-t(i));
        break;
    end
end

for i = 1:length(t)-1
    if (xF >= x(i)/100) && (xF < x(i+1)/100)
        tF = t(i) + (xF-x(i)/100)/(x(i+1)/100-x(i)/100)*(t(i+1)-t(i));
        break;
    end
end

for i = 1:length(t)-1
    if (xW >= x(i)/100) && (xW < x(i+1)/100)
        tW = t(i) + (xW-x(i)/100)/(x(i+1)/100-x(i)/100)*(t(i+1)-t(i));
        break;
    end
end

%% Теплота испарения
r1 = 72.18* (235.1 - ts)^0.38;
r2 = 333.3 + 0.9657 * ts - 0.004223 * ts^2;

rD = xDm * r1 + (1 - xDm) * r2;

%% Тепловая нагрузка дефлегматора

% Массовые доли
MF = M1*xF + M2*(1-xF);
MW = M1*xW + M2*(1-xW);
MD = M1*xD + M2*(1-xD);

% Решение системы уравнений материального баланса
A = [MD MW; MD*xDm MW*xWm];
B = [GF*MF; GF*MF*xFm];
Gi = linsolve(A,B);
GD = Gi(1);
GW = Gi(2);

% 
GFm = GF*MF;
GDm = GD*MD;
GWm = GW*MW;

% Флегмовое число
Rmin = (xD-yFs)/(yFs-xF);
R = 1.3*Rmin + 0.3;

Qd = GDm * (R+1) * rD;
%% Теплоемкости веществ
c1 = inline('2.11 + 0.0028 * t');
c1D = c1(tD); c1F = c1(tF); c1W = c1(tW);
c2 = inline('1.97 + 0.0036 * t');
c2D = c2(tD); c2F = c2(tF); c2W = c2(tW);

cW = xWm*c1W + (1 - xWm) * c2W;
cD = xDm*c1D + (1 - xDm) * c2D;
cF = xFm*c1F + (1 - xFm) * c2F;

%% Тепловая нагрузка куба
Qk = 0.95 * (Qd + GDm*cD*tD + GWm*cW*tW - GFm*cF*tF);