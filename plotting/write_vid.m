function write_vid(data, output_loc)
try
    v = VideoWriter(output_loc);
    v.FrameRate = 5;
    open(v);
    for kwh = 1:length(data)
        writeVideo(v, data(kwh));
    end %for
    close(v)
catch
    save(output_loc, 'data')
end %try

end %function
