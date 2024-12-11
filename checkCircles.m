function check = checkCircles(circles,radii,x,y)
%CHECKCIRCLES - Determines if an input point is inside any circular region,
% from a set of similar regions.
%
% Syntax
%   check = CHECKCIRCLES(circles,radii,x,y)
%
% Input Arguments
%   circles - A list of (x,y) coordinates of circular region centroids.
%   Matrix. Format is circles = [(x centroid coord.),(y centroid coord.)],
%   with size (no. of circles)x2.
%   radii - A list of radii corresponding (row-wise) to the circles
%   contained in 'circles'. Vector; length is (no. of circles)x1.
%
% Output Arguments
%   check - Indicator for material type. Logical. True is material type 2,
%           false is material type 1.

check = sqrt((circles(:,1) - x).^2 + (circles(:,2) - y).^2);
check = check <= radii;
check = any(check);
end