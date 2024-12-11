function c = FVM(grid,parameters)
%FVM - Basic implementation of the Finite Volume Method on a 2D
% unstructured grid with triangular elements.
%
% Syntax
%   c = FVM(grid,parameters)
%
% Input Arguments
%   grid - 2D FVM grid object. Custom structure (see modGrid.m).
%   parameters - FVM parameters. Custom structure (see run.m).
%
% Output Arguments
%   c - Approximate fine-grid solution determined by the FVM. Matrix. Has
%       format [c^(0),c^(1),c^(2),...,c^(K)], where c^(k) is a vector
%       containing approximate solution values at time step k.

nodes = grid.nodes;
numNodes = size(nodes,1);

f = parameters.f;

T = parameters.T;
K = parameters.K;
tau = T/K;

I = grid.I;

[A,b0] = genAb(grid,parameters);

itMat = I - tau * A;

c = zeros(numNodes,K+1); c(:,1) = f(nodes(:,1),nodes(:,2));

% Time stepping
for k = 1:K

    t = k*tau;

    % Determine RHS from Equation (12).
    [cTmp,bTmp] = setRHS(c(:,k),b0,t,grid,parameters);

    c(:,k+1) = itMat \ (cTmp + tau*bTmp);

end

end