function plot_wall_losses(wall_loss_data)
%Plots the wall loss data
% Args:
%        wall_loss_data (struct): structured data on the polygons where losses
%                                 occour.

figure
colormap(jet)
patches = fieldnames(wall_loss_data);
 losses = NaN(length(patches), 1);
for hgs = 1:length(patches)
    losses(hgs) = wall_loss_data.(patches{hgs}).('loss');
end %for
maxloss = max(losses);
for hds = 1:length(patches)
patch(wall_loss_data.(patches{hds}).('points').x, ...
      wall_loss_data.(patches{hds}).('points').y, ...
      wall_loss_data.(patches{hds}).('points').z,...
      wall_loss_data.(patches{hds}).('loss') ./ maxloss)
end %for
