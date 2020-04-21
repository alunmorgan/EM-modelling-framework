% data = readmatrix('Z:\EM_simulation\EM_modeling_Reports\dii_bpm_bellow_asm_no_buttons\dii_bpm_bellow_asm_no_buttons_Base\wake\fexport_e_000000015');
fileID = fopen('Z:\EM_simulation\EM_modeling_Reports\dii_bpm_bellow_asm_no_buttons\dii_bpm_bellow_asm_no_buttons_Base\wake\fexport_e_000000015');
data = textscan(fileID,'%f %f %f', 'Headerlines', 1176);
fclose(fileID);
tk = 0;
X_field = NaN(size(X_coords,1), size(Y_coords,1), size(Z_coords,1));
Y_field = NaN(size(X_coords,1), size(Y_coords,1), size(Z_coords,1));
Z_field = NaN(size(X_coords,1), size(Y_coords,1), size(Z_coords,1));
for lwd = 1:size(Z_coords,1)
    for lws = 1:size(Y_coords,1)
        for lwh = 1:size(X_coords,1)
            tk = tk + 1;
            X_field(lwh, lws, lwd) = data{1}(tk);
            Y_field(lwh, lws, lwd) = data{2}(tk);
            Z_field(lwh, lws, lwd) = data{3}(tk);
        end %for
    end %for
end %for

M_field = sqrt(X_field .^ 2 + Y_field .^ 2 + Z_field .^ 2);
M_field = M_field(2:end-1, 2:end-1, 2:end-1);%stripping off the boundary zeros.

c = zeros(size(M_field));
for kew = 1:size(M_field)
a = squeeze(M_field(:,:,kew));
d = zeros(size(a));
[br, bc]= find(a==0);%finding the location of the metal.
for nwe = 1:size(a,1)
    for wha = 1:size(a,2)
        if a(nwe, wha) == 0
            continue %in the metal.
        end %if
        inds = br(bc == wha);
        if isempty(inds)
            continue % not inside the structure.
        end %if
        
        if nwe < max(inds) && nwe > min(inds)
            c(nwe, wha, kew) = a(nwe, wha);
            d(nwe, wha) =  a(nwe, wha);
        end %if
    end %for
end %for
clear a
end %for
%
[x_mesh, y_mesh, z_mesh] = meshgrid(X_coords(2:end-1,1), Y_coords(2:end-1,1), Z_coords(2:end-1,1));
M_field_unwrapped = c(:);
x_mesh_unwrapped = x_mesh(:);
y_mesh_unwrapped = y_mesh(:);
z_mesh_unwrapped = z_mesh(:);
data_inds = find(M_field_unwrapped ~= 0);

M_field_unwrapped = M_field_unwrapped(data_inds);
x_mesh_unwrapped = x_mesh_unwrapped(data_inds);
y_mesh_unwrapped = y_mesh_unwrapped(data_inds);
z_mesh_unwrapped = z_mesh_unwrapped(data_inds);

figure(1)
scatter3(x_mesh_unwrapped, y_mesh_unwrapped, z_mesh_unwrapped, 10, ...
    log10(M_field_unwrapped), 'filled',...
    'MarkerFaceAlpha',0.2, 'MarkerEdgeAlpha',0.2 )
