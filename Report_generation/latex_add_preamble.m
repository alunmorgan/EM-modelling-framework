function ov = latex_add_preamble(report_input)
% This sets up the inital latex environment and the inital front page
% for a sharepoint style report.
%
% ov is latex code which can be concatinated with model specific output.
% report_input is a structure containing the required stup parameters.
%
% Example: ov = latex_add_preamble(report_input)

if isfield(report_input, 'report_name')
    name = report_input.report_name;
else
    name = report_input.model_name;
end

if ~isempty(strfind(name, '-'))
    sub_ind = strfind(name, '-');
    sub_title = name(sub_ind +1:end);
    name = name(1:sub_ind -1);
end

dte =datestr(datenum(report_input.date, 'dd/mm/yyyy'),'dd mmmm yyyy');
ov{1} = '\documentclass[a4paper]{report}';
ov = cat(1,ov,'\setlength{\textwidth}{500pt}');
ov = cat(1,ov,'\setlength{\oddsidemargin}{5pt}');
ov = cat(1,ov,'\setlength{\topmargin}{0pt}');
ov = cat(1,ov,'\setlength{\voffset}{-50pt}');
ov = cat(1,ov,'\setlength{\textheight}{720pt}');
ov = cat(1,ov,'\usepackage{graphicx}');
ov = cat(1,ov,'\usepackage{color}');
ov = cat(1,ov,'\usepackage[encoding, filenameencoding=utf8]{grffile}');
ov = cat(1,ov,'\usepackage{hyperref}');
ov = cat(1,ov,'\hypersetup{colorlinks=true, linkcolor=blue}');
ov = cat(1,ov,'\usepackage{fancyhdr}');
ov = cat(1,ov,'\usepackage{multirow}');
% Next bit is for enabling rotated headings in the tables. Source was here.
% http://tex.stackexchange.com/questions/32683/rotated-column-titles-in-tabular
ov = cat(1,ov,'\usepackage{array}');
ov = cat(1,ov,'\newcolumntype{R}[2]{%');
ov = cat(1,ov,'    >{\adjustbox{angle=#1,lap=\width-(#2)}\bgroup}%');
ov = cat(1,ov,'    l%');
ov = cat(1,ov,'    <{\egroup}%');
ov = cat(1,ov,'}');
ov = cat(1,ov,'\newcommand*\rot{\multicolumn{1}{R{45}{1em}}}');
%%%%%%%%%%%%
ov = cat(1,ov,'\pagestyle{fancy}');
ov = cat(1,ov,'\lhead{Results for ',regexprep(regexprep(regexprep(name,'\','\\SJEDtextbackslash '),'_','\\_'),'SJED',''),'}');
ov = cat(1,ov,'\chead{}');
ov = cat(1,ov,'\rhead{\thepage}');
ov = cat(1,ov,'\lfoot{}');
ov = cat(1,ov,'\cfoot{}');
ov = cat(1,ov,'\rfoot{',dte,'}');
ov = cat(1,ov,'\begin{document}');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ov = cat(1,ov,'\title{');
ov = cat(1,ov,'\begin{tabular}{|p{4.5cm}|m{5cm}|c|}');
ov = cat(1,ov,'\hline');
ov = cat(1,ov,'\multirow{2}{*}{\textbf{TDI-DIA}} & ');
ov = cat(1,ov,['\multirow{2}{*}{\includegraphics[scale=0.8]{',report_input.graphic,'}} & \multirow{2}{*}{\small{Doc No: ',report_input.doc_num,'}} \\']);
ov = cat(1,ov,'&& \\');
ov = cat(1,ov,'\hline');
ov = cat(1,ov,'\end{tabular} \\');
ov = cat(1,ov, '\vspace{1cm}');
% put the title of the report here
% Format the title

% model_name = regexprep(model_name, '_', ' ');
ov = cat(1,ov,'\centering');

ov = cat(1,ov,['\textbf{',name,'}\\']);
if exist('sub_title','var')
    ov = cat(1,ov,'\centering');
    ov = cat(1,ov,['(',sub_title,' )\\']);
end
ov = cat(1,ov,'\vspace{0.5cm}');
ov = cat(1,ov,'\begin{tabular}{r@{\hspace{0.25cm}=\hspace{0.25cm}}l}');
ov = cat(1,ov,'\centering');
if isfield(report_input, 'param_names_common')
    for esk = 1:length(report_input.param_names_common)
        val_tmp = report_input.param_vals_common{esk};
        if ~ischar(val_tmp)
            val_tmp = num2str(val_tmp);
        end
        % strip out the counter on the materials
        val_tmp = regexprep(val_tmp,'\s*steel(\d+)_\d+\s*',' steel$1' );
        val_tmp = regexprep(val_tmp,'\s*PEC_\d+\s*',' PEC' );
        % catch to remove _
        val_tmp = regexprep(val_tmp,'_',' ' );
        ov = cat(1,ov,['\emph{',regexprep(report_input.param_names_common{esk},'_',' '),'} & ',val_tmp,'\\']);
    end
    if length(report_input.param_names_varying) == 1
        ov = cat(1,ov,['\emph{',regexprep(report_input.param_names_varying{1},'_',' '),'} & Swept\\']);
        ov = cat(1,ov,'\end{tabular} \\');
        if isfield(report_input,'swept_vals')
            ov = cat(1,ov,'\vspace{0.5cm}');
            list_of_sweep = report_input.swept_vals{1};
            for hs = 2:length(report_input.swept_vals)
                list_of_sweep = [list_of_sweep,', ',report_input.swept_vals{hs}];
            end
            ov = cat(1,ov,['Sweep: \emph{', list_of_sweep,'}']);
        end
    else
        ov = cat(1,ov,'\end{tabular} \\');
        ov = cat(1,ov,'\begin{tabular}{r@{\hspace{0.25cm}=\hspace{0.25cm}}l}');
        for esk = 1:length(report_input.param_names_varying)
            val_tmp = report_input.param_vals_varying(:,esk);
            for pa = 1:length(val_tmp)
                if ~ischar(val_tmp{pa})
                    val_tmp{pa} = num2str(val_tmp{pa});
                end
            end
            % strip out the counter on the materials
            val_tmp = regexprep(val_tmp,'\s*steel(\d+)_\d+\s*',' steel$1' );
            val_tmp = regexprep(val_tmp,'\s*PEC_\d+\s*',' PEC' );
            % catch to remove _
            val_tmp = regexprep(val_tmp,'_',' ' );
            op = val_tmp{1};
            for ua = 2:length(val_tmp)
                op  = strcat(op,',',val_tmp{ua});
            end
            ov = cat(1,ov,['\emph{',regexprep(report_input.param_names_varying{esk},'_',' '),'} & ',op,'\\']);
        end
        ov = cat(1,ov,'\end{tabular} \\');
    end
else
    for esk = 1:length(report_input.param_list)
          val_tmp = report_input.param_vals{esk};
                if ~ischar(val_tmp)
                    val_tmp = num2str(val_tmp);
                end
            % strip out the counter on the materials
            val_tmp = regexprep(val_tmp,'\s*steel(\d+)_\d+\s*',' steel$1' );
            val_tmp = regexprep(val_tmp,'\s*PEC_\d+\s*',' PEC' );
            % catch to remove _
            val_tmp = regexprep(val_tmp,'_',' ' );
        ov = cat(1,ov,['\emph{',regexprep(report_input.param_list{esk},'_',' '),'} & ',val_tmp,'\\']);
    end
    ov = cat(1,ov,'\end{tabular} \\');
end

ov = cat(1,ov,'}');
% Put the authors here
ov = cat(1,ov,['\author{',report_input.author,'}']);
ov = cat(1,ov,['\date{', dte,'}']);
ov = cat(1,ov,'\maketitle');
ov = cat(1,ov,'\tableofcontents');
