function yp = G_I_Diabetic(t,y)
    yp = [-0.8 0.08; -5 -2]*y + [0; 1];
end