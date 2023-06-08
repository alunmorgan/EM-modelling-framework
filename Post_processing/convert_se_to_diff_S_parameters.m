function mixed_mode_s_parameters = convert_se_to_diff_S_parameters(single_mode_s_parameters)
%Converts single ended S-parameter data into Mixed mode data
% Assumes P1 and P2 are linked
% Assumes P3 and P4 are linked
%
%   P1 ------ P2
%   P3 ------ P4
% becomes
%   M1 ------ M2
%
% Example: 

% Differential-Differential
% A differential signal enters the differential pair and a differential signal comes out
SDD11 = 0.5 * (S11 - S13 - S31 + S33);
SDD12 = 0.5 * (S12 - S14 - S32 + S34);
SDD21 = 0.5 * (S21 - S23 - S41 + S43);
SDD22 = 0.5 * (S22 - S24 - S42 + S44);

% Differential-Common
% A differential signal enters the differential pair and a common signal comes out
SDC11 = 0.5 * (S11 - S13 + S31 - S33);
SDC12 = 0.5 * (S12 - S14 + S32 - S34);
SDC21 = 0.5 * (S21 - S23 + S41 - S43);
SDC22 = 0.5 * (S22 - S24 + S42 - S44);

% Common-Differential
% A common signal enters the differential pair and a differential signal comes out
SCD11 = 0.5 * (S11 + S13 - S31 - S33);
SCD12 = 0.5 * (S12 + S14 - S32 - S34);
SCD21 = 0.5 * (S21 + S23 - S41 - S43);
SCD22 = 0.5 * (S22 + S24 - S42 - S44);

% Common-Common
% A common signal enters the differential pair and a common signal comes out
SCC11 = 0.5 * (S11 + S13 + S31 + S33);
SCC12 = 0.5 * (S12 + S14 + S32 + S34);
SCC21 = 0.5 * (S21 + S23 + S41 + S43);
SCC22 = 0.5 * (S22 + S24 + S42 + S44);
end

