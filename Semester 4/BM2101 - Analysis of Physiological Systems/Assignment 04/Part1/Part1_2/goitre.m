function yp = goitre(t,y);
yp = [-2.52 0 .08;.84 -.01 0;0 .01 -.1]*y + [25 0 0]';
end