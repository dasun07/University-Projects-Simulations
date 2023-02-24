function yp = riggs_insufficient(t,y);
yp = [-2.52 0 .08;.84 -.01 0;0 .01 -.1]*y + [15 0 0]';
end