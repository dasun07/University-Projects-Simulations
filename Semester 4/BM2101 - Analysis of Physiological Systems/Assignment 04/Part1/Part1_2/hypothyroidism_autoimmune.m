function yp = hypothyroidism_autoimmune(t,y);
yp = [-2.52 0 .08;.84 -.004 0;0 .004 -.1]*y + [150 0 0]';
end