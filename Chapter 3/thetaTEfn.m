function theta = thetaTEfn(P,L,E,b,h,nu,x)
    I = (1/12)*(b)*(h^3);
    A = b*h;
    kappa = (10*(1 + nu))/(12 + 11*nu);
    G = E/(2*(1 + nu));
    theta = -(-P/(kappa*A*G) - P/(2*E*I)*((L^2) - (x^2)));
    
end