function [out, out_string]  = convert_secs_to_hms(data)
% converts a length of time in seconds into days hours minutes and seconds
% elapsed.
% out is the numeric values.
% out_string is the string representation.
% data is the number of seconds.
%
% Example: [out, out_string]  = convert_secs_to_hms(data)

days = floor(data/(24*3600));
left_over = rem(data,(24*3600));
hours = floor(left_over/3600);
left_over = rem(left_over,(3600));
mins = floor(left_over/60);
secs = rem(left_over,(60));

out = [days, hours, mins, secs];
if out(1) == 1
            dys = ' day, ';
        else
            dys = ' days, ';
 end
if out(2) == 1
            hrs = ' hour, ';
        else
            hrs = ' hours, ';
 end
if out(3) == 1
            mns = ' min, ';
        else
            mns = ' mins, ';
end
 
if out(4) == 1
            scs = ' sec, ';
        else
            scs = ' secs, ';
 end

if isempty(out) == 0
    if out(1) ~= 0
       
        out_string = [num2str(out(1)), dys ,num2str(out(2)), hrs, num2str(out(3)), mns ,num2str(round(out(4))), scs, ];
    else
        if out(2) ~= 0
            out_string = [num2str(out(2)), hrs ,num2str(out(3)), mns ,num2str(round(out(4))), scs, ];
        else
            if out(3) ~= 0
                out_string = [num2str(out(3)), mns ,num2str(round(out(4))), scs, ];
            else
                out_string = [num2str(round(out(4))), scs, ];
            end
        end
    end
end