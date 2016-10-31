function op = remove_material_counter(input)
% strip out the counter on the materials
input = regexprep(input,'\s*steel(\d+)_\d+\s*',' steel$1' );
input = regexprep(input,'\s*PEC_\d+\s*',' PEC' );
% catch to remove _
op = regexprep(input,'_',' ' );

if iscell(input)
    op = op{1};
    for ua = 2:length(input)
        op  = strcat(op,',',input{ua});
    end %for
end %if