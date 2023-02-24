function yp = G_I_Impulse(t,y)
    yp = [-0.8 0.2; -5 -2]*y + [0; 1-sign(t)];
end