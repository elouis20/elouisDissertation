function v = vTEfn(P,L,E,b,h,nu,x)
    I = (1/12)*(b)*(h^3);
    A = b*h;
    kappa = (10*(1 + nu))/(12 + 11*nu);
    G = E/(2*(1 + nu));
    v = -((P*(L - x))/(kappa*A*G) - (P/(6*E*I))*(-(x^3) + 3*(L^2)*x - 2*(L^3)));
end