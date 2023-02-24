%This MATLAB script solves the differential equation,
%involved in question 01, PART 03

syms g(t)

Dg = diff(g,t);

ode = diff(g,t,2) == -2.8*diff(g,t) -2.6*g + 0.8;
cond1 = g(0) ==  0;
cond2 = Dg(0) == 1;
conds = [cond1 cond2];
gSol(t) = dsolve(ode, conds);
gSol = simplify(gSol)

%%
% Finding i(t)
simplify(-0.2*diff(gSol,t) -0.4*gSol + 0.2)
