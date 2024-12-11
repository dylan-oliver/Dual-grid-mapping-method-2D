function plotCoarse(sol,rad,tol)
N = size(sol,1);
x = reshape(sol(:,1),1,N); X = zeros(0,1);
y = reshape(sol(:,2),1,N); Y = zeros(0,1);
c = reshape(sol(:,3),1,N); C = zeros(0,1);

circles = zeros(0,2);

for i = 1:N
    check = sqrt((circles(:,1) - x(i)).^2 + (circles(:,2) - y(i)).^2);
    if any(check <= tol*rad)
        continue
    else
        circles(end+1,:) = [x(i),y(i)];
        X(end+1) = x(i); Y(end+1) = y(i); C(end+1) = c(i);
    end
end

scatter(X,Y,30,C,'filled')
end
