function hetMesh2(parameters)
%HETMESH Creates a set of rectangles corresponding to
% individual pixels in a random heterogeneous domain.
%
% HETMESH(parameters) Decomposes a domain into rectangles
% that correspond to homogeneous 'pixels'. Given the properties of a random
% heterogeneous domain, length Lx and height Ly, a set of nodes is placed
% so that each node corresponds to the corner of a pixel on the domain.
% Rectangles are then created so that each individual pixel is contained in
% a corresponding rectangle, resulting in each rectangle containing only a
% homogeneous part of the overall domain. Material properties are assigned
% according to the pixels in an image of a corresponding domain (the bottom
% left rectangle is assigned the material of the bottom left pixel, for
% example).
xL = parameters.xL;
yH = parameters.yH;
ref = parameters.ref; % Mesh refinement parameter. Smaller = finer grid.
numStrips = parameters.numStrips;

load('Data/hetDomain.mat','circles','radii');

N = size(circles,1);

fid = fopen('mesh.geo','w');

fprintf(fid,'SetFactory("OpenCASCADE");\n');

% Mesh creation algorithm:
% Automatic - 2
% Delaunay - 5
% Frontal-Delaunay - 6
fprintf(fid,'Mesh.Algorithm = 5;\n');

fprintf(fid,'ref = %g;\n',ref);

fprintf(fid,'Point(1) = {0,0,0,1.0};\n');
fprintf(fid,'Point(2) = {%g,0,0,1.0};\n',xL);
fprintf(fid,'Point(3) = {%g,%g,0,1.0};\n',xL,yH);
fprintf(fid,'Point(4) = {0,%g,0,1.0};\n',yH);

fprintf(fid,'Line(1) = {1,2};\n');
fprintf(fid,'Line(2) = {2,3};\n');
fprintf(fid,'Line(3) = {3,4};\n');
fprintf(fid,'Line(4) = {4,1};\n');

fprintf(fid,'Line Loop(1) = {1,2,3,4};\n');

fprintf(fid,'Plane Surface(1) = {1};\n');

for i = 1:N
    fprintf(fid,'Circle(%g) = {%g,%g,0,%g,0,2*Pi};\n',i+4,circles(i,1),circles(i,2),radii(i));
    fprintf(fid,'Curve Loop(%g) = {%g};\n',i+1,i+4);
    fprintf(fid,'Plane Surface(%g) = {%g};\n',i+1,i+1);
end

for i = 1:N
    if i == 1
        sID = 1;
    else
        sID = N + 2;
    end
    fprintf(fid,'BooleanFragments{Surface{%g}; Delete;}{Surface{%g};}\n',sID,i+1);
end

fprintf(fid,'Mesh.MeshSizeMax = ref;\n');

fprintf(fid,'Mesh 2;\n');

%if parameters.part
fprintf(fid,'Mesh.PartitionCreateTopology = %g;\n',1); % 0 for no partition topology, or 1 to update topology (place partition points and interfaces rather than just groups)
fprintf(fid,'Mesh.PartitionCreateGhostCells = %g;\n',0); % 0 for no ghost cells, or 1 for ghost cells
fprintf(fid,'Mesh.PartitionCreatePhysicals = %g;\n',1); % 0 for no handling of physical groups, 1 to group partitions into new physical groups
fprintf(fid,'Mesh.PartitionOldStyleMsh2 = %g;\n',0); % 0 to remove compatibility for older GMSH versions (MSH2 format), 1 to save mesh in compatibility mode (note: setting 1 will break the grid modification)
fprintf(fid,'Mesh.PartitionSplitMeshFiles = %g;\n',0); % 0 to save as a single mesh, 1 to save a mesh for each individual partition

fprintf(fid,'PartitionMesh %g;\n',numStrips); % Number of partitions, any (reasonable) integer > 1
% else
% fprintf(fid,'Physical Point(1) = {%g};\n',N+5);
% fprintf(fid,'Physical Point(2) = {%g};\n',N+6);
% fprintf(fid,'Physical Point(3) = {%g};\n',N+7);
% fprintf(fid,'Physical Point(4) = {%g};\n',N+8);
% 
% fprintf(fid,'Physical Line(1) = {%g};\n',N+5);
% fprintf(fid,'Physical Line(2) = {%g};\n',N+6);
% fprintf(fid,'Physical Line(3) = {%g};\n',N+7);
% fprintf(fid,'Physical Line(4) = {%g};\n',N+8);
% 
% for i = 1:N+1
%     fprintf(fid,'Physical Surface(%g) = {%g};\n',i,i+1);
% end
% end

fprintf(fid,'Mesh.Format = 50;\n');
fprintf(fid,'Save "mesh.m";\n');

fclose(fid);
system([parameters.gmshPath,'mesh.geo -']);
end
