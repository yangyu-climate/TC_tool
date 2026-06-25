function var = DvDz_value(v,z)

for i = 1:size(z,2)
    for j = 1:size(z,3)
        Z          = squeeze(z(:,i,j));
        V          = squeeze(v(:,i,j));
        var(:,i,j) = gradient(V)./gradient(Z);
    end
end


