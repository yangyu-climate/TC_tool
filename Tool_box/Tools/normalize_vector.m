function [u,v] = normalize_vector(U,V)

    S = sqrt(U.^2+V.^2);
    u = U./S;
    v = V./S;