function Blend_reports(sets)
%Blends some of the output from the individual thermal analysis reports to
%generate a summary comparison report.
%
%   Args:
%       sets (cell array of strings): If there is a single entry then generate blended results for all parameter sweeps in the set.
%                                     If there are more than one entries then blend the base models
% Example: Blend_reports(sets)
if length(sets) == 1
    single_set = sets{1};
blend_single_base(single_set)   
else
    use_names = 0;
blend_multi_base(sets, use_names) 
end %if