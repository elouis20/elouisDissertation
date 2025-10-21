function hist = histmaker(mu,sigma,n)
    a = makedist('Normal','mu',mu,'sigma',sigma);
    hist = random(a,1,n);
    
end