function replica = replicate_structure(reference_structure, replica)
% Creates an empty structure complete with sub structures
% Useful for creating output for null data cases.

substructure = fieldnames(reference_structure);
for hs = 1:length(substructure)
    if iscell(reference_structure.(substructure{hs}))
        replica.(substructure{hs}) = cell(size(reference_structure.(substructure{hs}),1),...
            size(reference_structure.(substructure{hs}),2));
    elseif ischar(reference_structure.(substructure{hs}))
        replica.(substructure{hs}) = '';
    elseif isstruct(reference_structure.(substructure{hs}))
        replica.(substructure{hs}) = struct();
        replica.(substructure{hs}) = replicate_structure(reference_structure.(substructure{hs}), replica.(substructure{hs})); 
    else
        replica.(substructure{hs}) = [];
    end
end %for
