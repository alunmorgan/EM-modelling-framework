function ov = generate_latex_for_eigenmode_analysis(eigenmode_data)
% Generates latex code based on the wake simulation results.
% Wraps latex code around the pre generated Eigenmode results.
%
% ov is the output latex code.
%
% Example: ov = generate_latex_for_eigenmode_analysis(eigenmode_data)
ov = cell(1,1);
ov = cat(1,ov,'\chapter{Eigenmode results}');
ov = cat(1,ov,generate_eigenmode_table(eigenmode_data));
% ov = cat(1,ov,generate_eigenmode_q_table(eigenmode_data));
ov = cat(1,ov,generate_eigenmode_rq_table(eigenmode_data));

ov = cat(1,ov,'\clearpage');