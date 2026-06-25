function var = dVdPhi(data,dPhi)

SD = length(size(data));

if SD==3
    for k=1:size(data,1)
        D = squeeze(data(k,:,:));
        D = [D(end,:);D;D(1,:)];
        var(k,:,:) = 0.5*(D(3:end,:)-D(1:end-2,:))/dPhi;
    end
elseif SD==2
    D = data;
    D = [D(end,:);D;D(1,:)];
    var = 0.5*(D(3:end,:)-D(1:end-2,:))/dPhi;
else
    D(:,1) = data;
    D = [D(end);D;D(1)];
    var = 0.5*(D(3:end)-D(1:end-2))/dPhi;
end

