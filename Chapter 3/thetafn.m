function theta = thetafn(P,L,E,b,h,x)
    I = (1/12)*b*(h^3);
    theta = (P/(2*E*I))*(L^2 - x^2);
end