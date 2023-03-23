function write_vid(data, output_loc)
% Writes video from input frames file.

v = VideoWriter(output_loc);
v.FrameRate = 5;
open(v);
for kwh = 1:length(data)
    writeVideo(v, data(kwh));
end %for
close(v)
