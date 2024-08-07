function genMesh(parameters)

fid = fopen('mesh.geo', 'w');

% Automatic - 2
% Delaunay - 5
% Frontal-Delaunay - 6
fprintf(fid,'Mesh.Algorithm = 5;\n');
fprintf(fid,'r = %g;\n',parameters.ref); % Mesh refinement parameter.

lineCount = 1;
N = length(parameters.lines);
for i = 1:N
    line = parameters.lines{i};
    fprintf(fid,'Point(%g) = {%g,%g,0,r};\n',i,line(1,1),line(1,2));
    fprintf(fid,'Point(%g) = {%g,%g,0,r};\n',2*N-i+1,line(2,1),line(2,2));
    fprintf(fid,'Line(%g) = {%g,%g};\n',lineCount,i,2*N-i+1);
    lineCount = lineCount + 1;
end

loopCount = 1;
for i = 1:N-1
    fprintf(fid,'Line(%g) = {%g,%g};\n',lineCount,i,i+1);
    lineCount = lineCount + 1;
    fprintf(fid,'Line(%g) = {%g,%g};\n',lineCount,2*N-i,2*N-i+1);
    fprintf(fid,'Curve Loop(%g) = {%g,%g,%g,-%g};\n',loopCount,N+2*i-1,i+1,N+2*i,i);
    fprintf(fid,'Plane Surface(%g) = {%g};\n',loopCount,loopCount);
    lineCount = lineCount + 1;
    loopCount = loopCount + 1;
end

fprintf(fid,'Surface Loop(1) = {');
for i = 1:loopCount-1
    fprintf(fid,'%g',i);
    if i < loopCount-1
        fprintf(fid,',');
    end
end
fprintf(fid,'};\n');

for i = 1:size(parameters.points,1)
    fprintf(fid,'Point(%g) = {%g,%g,0,r};\n',2*N+i,parameters.points(i,1),parameters.points(i,2));
    fprintf(fid,'Point{%g} In Surface {1};\n',2*N+i);
end

fprintf(fid,'Synchronize;\n');

fprintf(fid,'Mesh 2;\n');

fprintf(fid,'Mesh.PartitionCreateTopology = %g;\n',parameters.domainTopology); % 0 for no partition topology, or 1 to update topology (place partition points and interfaces rather than just groups)
fprintf(fid,'Mesh.PartitionCreateGhostCells = %g;\n',parameters.ghostCells); % 0 for no ghost cells, or 1 for ghost cells
fprintf(fid,'Mesh.PartitionCreatePhysicals = %g;\n',parameters.physicalGroups); % 0 for no handling of physical groups, 1 to group partitions into new physical groups
fprintf(fid,'Mesh.PartitionOldStyleMsh2 = %g;\n',parameters.compatibility); % 0 to remove compatibility for older GMSH versions (MSH2 format), 1 to save mesh in compatibility mode (note: setting 1 will break the grid modification)

fprintf(fid,'Plugin(SimplePartition).NumSlicesX = %g;\n',parameters.numStrips); % Number of partitions, any (reasonable) integer > 1
fprintf(fid,'Plugin(SimplePartition).NumSlicesY = 1;\n');
fprintf(fid,'Plugin(SimplePartition).Run;\n');

fprintf(fid,'Mesh.Format = 50;\n');
fprintf(fid,'Save "mesh.m";\n');

fclose(fid);
system([parameters.gmshPath,'mesh.geo -']); % Run GMSH and create 2D mesh.

end
