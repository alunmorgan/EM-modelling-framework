function out = standard_form_text(num)
%Convert a number into a latexstadnard form string.
%
% example: out = standard_form_text(4000)

if isempty(num)
    out = '';
else
    epnt = 0;
    if abs(num) >100
        while abs(num) > 10
            num = num/10;
            epnt = epnt +1;
        end
    elseif abs(num) < 0.01 && abs(num) > 0
        while abs(num) < 1
            num = num * 10;
            epnt = epnt -1;
        end
    else
        out = num2str(num);
        return
    end
    
    num = round(num * 100 ) /100;
    
    out  = strcat(num2str(num),'\times{}10^{',num2str(epnt),'}');
end