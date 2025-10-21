function v = vfn(P,L,E,b,h,x)
    I = (1/12)*b*(h^3);
    v = (P/(6*E*I))*(-(x^3) + 3*(L^2)*x - 2*(L^3));
end