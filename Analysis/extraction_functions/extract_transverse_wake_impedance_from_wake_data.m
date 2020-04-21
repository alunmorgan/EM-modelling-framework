function [wi_quad_x, wi_quad_y, wi_dipole_x, wi_dipole_y] = extract_transverse_wake_impedance_from_wake_data(pp_data, wake_data, processing_type)
% wake data (structure): contains all the data from the wake postprocessing
%
%
% Example: [wi_quad_x, wi_quad_y, wi_dipole_x, wi_dipole_y] = extract_transverse_wake_impedance_from_wake_data(wake_data)

if nargin == 2
    processing_type = 'Matlab';
end %if

if strcmp(processing_type, 'GdfidL')
    wi_quad_x.scale = pp_data.Wake_impedance_trans_quad_X(:,1)*1E-9;
    wi_quad_x.data = pp_data.Wake_impedance_trans_quad_X(:,2);
    
    wi_quad_y.scale = pp_data.Wake_impedance_trans_quad_Y(:,1)*1E-9;
    wi_quad_y.data = pp_data.Wake_impedance_trans_quad_Y(:,2);
    
    wi_dipole_x.scale = pp_data.Wake_impedance_trans_dipole_X(:,1)*1E-9;
    wi_dipole_x.data = pp_data.Wake_impedance_trans_dipole_X(:,2);
    
    wi_dipole_y.scale = pp_data.Wake_impedance_trans_dipole_Y(:,1)*1E-9;
    wi_dipole_y.data = pp_data.Wake_impedance_trans_dipole_Y(:,2);
elseif strcmp(processing_type, 'Matlab')
    wi_quad_x.scale = wake_data.frequency_domain_data.f_raw*1E-9;
    wi_quad_x.data = wake_data.frequency_domain_data.Wake_Impedance_trans_quad_X;
    
    wi_quad_y.scale = wake_data.frequency_domain_data.f_raw*1E-9;
    wi_quad_y.data = wake_data.frequency_domain_data.Wake_Impedance_trans_quad_Y;
    
    wi_dipole_x.scale = wake_data.frequency_domain_data.f_raw*1E-9;
    wi_dipole_x.data = wake_data.frequency_domain_data.Wake_Impedance_trans_dipole_X;
    
    wi_dipole_y.scale = wake_data.frequency_domain_data.f_raw*1E-9;
    wi_dipole_y.data = wake_data.frequency_domain_data.Wake_Impedance_trans_dipole_Y;
end %for
