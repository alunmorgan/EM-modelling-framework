function  f = sort_summary_dates(dte)
% reformats the date string recovered from the summary graph.
[f,~,~] =regexp(dte,'\s*(\d{1,2}\s+day[s]?)\s*,\s*(\d{1,2}\s+hour[s]?)\s*,\s*(\d{1,2}\s+min[s]?)\s*,\s*(\d{1,2}\s+sec[s]?)\s*,\s*','Tokens');
if isempty(f)
    [f,~,~] =regexp(dte,'\s*(\d{1,2}\s+hour[s]?)\s*,\s*(\d{1,2}\s+min[s]?)\s*,\s*(\d{1,2}\s+sec[s]?)\s*,\s*','Tokens');
    if isempty(f)
        [f,~,~] =regexp(dte,'\s*(\d{1,2}\s+min[s]?)\s*,\s*(\d{1,2}\s+sec[s]?)\s*,\s*','Tokens');
        if isempty(f)
            [f,~,~] =regexp(dte,'\s*(\d{1,2}\s+sec[s]?)\s*,\s*','Tokens');
        end
    end
end
f = f{1};
if length(f) == 3
    f = cat(2,' ',f);
elseif length(f) == 2
    f = cat(2,' ',' ',f);
elseif length(f) == 1
    f = cat(2,' ',' ',' ',f);
end
