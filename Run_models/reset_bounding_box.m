function text_data = reset_bounding_box(text_data)
text_data = cat(1, text_data, '   bbxlow= -1E+30');
text_data = cat(1, text_data, '   bbylow= -1E+30');
text_data = cat(1, text_data, '   bbzlow= -1E+30');
text_data = cat(1, text_data, '   bbxhigh= 1E+30');
text_data = cat(1, text_data, '   bbyhigh= 1E+30');
text_data = cat(1, text_data, '   bbzhigh= 1E+30');
end % function
