function ov = insert_geometry_pics(pic_loc)
% find the images showing the model geometry and the port locations. Write
% latex code to display them.
%
% example: ov = insert_geometry_pics('pp_link')

% Start to generate a list of file names and captions
names = {'Full_model.eps',};
caps = {'Full model'};
ang = {'90'};
clip = {'true'};
trim = {', trim= 20mm 15mm 37mm 4mm'};
spacing = {'-25'};

% Find all the epsfiles in the target folder.
[image_names ,~] = dir_list_gen(pic_loc,'eps',1);

% Find the user defined model views.
user_plots_inds = find_position_in_cell_lst(strfind(image_names, 'user_plot'));
user_plots = image_names(user_plots_inds);

% Find the port loctation graphs.
port_loc_inds = find_position_in_cell_lst(strfind(image_names, 'port_locations_'));
port_loc = image_names(port_loc_inds);

if ~isempty(user_plots)
    names = cat(2,names,user_plots');
    for nsk = 1:length(user_plots)
        [tok] = regexp(user_plots{nsk},'user_plot(x|y|z)_(.*)\.eps','tokens');
        tok = tok{1};
        tok{2} = regexprep(tok{2}, 'm', '-');
        caps = cat(2,caps, ['cut in the ',tok{1},' plane, at a location of ',tok{2}]);
        ang = cat(2,ang,'90');
        clip = cat(2,clip,'true');
        trim = cat(2,trim,', trim= 20mm 15mm 37mm 4mm');
        spacing = cat(2,spacing, '-25');
    end
end

if ~isempty(port_loc)
    names = cat(2,names,port_loc');
    for nsk = 1:length(port_loc)
        [tok] = regexp(port_loc{nsk},'port_locations_(x|y|z).eps','tokens');
        caps = cat(2,caps, ['Locations of ports on the ',tok{1}{1},' boundary']);
        ang = cat(2,ang,'0');
        clip = cat(2,clip,'false');
       trim = cat(2,trim,' ');
       spacing = cat(2,spacing, '0');
    end
end
ov = {' '};
for hw = 1:length(names)
    if exist([pic_loc,names{hw}],'file')
        ov = cat(1,ov,'\begin{figure}[hbt]');
        ov = cat(1,ov,'\begin{center}');
        ov = cat(1,ov,['\includegraphics [angle=',ang{hw},', origin=c, scale=0.5, clip=',clip{hw},trim{hw},']{',names{hw},'}']);
        ov = cat(1,ov,['\vspace{',spacing{hw},'mm}']);
        ov = cat(1,ov,['\caption{', caps{hw},'}']);
        ov = cat(1,ov,'\end{center}');
        ov = cat(1,ov,'\end{figure}');
    end
end
