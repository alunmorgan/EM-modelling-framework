function [output, reduction]= matrix_reduction_1D(input, dim, reduction)

if rem(size(input,dim), reduction) ~= 0 
    disp('The value of the reduction requested is not a factor of the size of the matrix provided')
    while rem(size(input,dim), reduction) ~= 0 && reduction ~= 0
        reduction = reduction - 1;
    end %while
    disp(['Using ', num2str(reduction), ' for reduction value.'])
    
end %if

for hse = size(input, dim) / reduction:-1:1
    requested_range_upper = hse * reduction;
    requested_range_lower = (hse - 1) * reduction +1;
    if dim == 1
        output(hse, :, :) = mean(input(requested_range_lower : requested_range_upper,:,:), dim);
    elseif dim == 2
        output(:, hse, :) = mean(input(:, requested_range_lower : requested_range_upper,:), dim);
    elseif dim == 3
        output(:, :, hse) = mean(input(:, :, requested_range_lower : requested_range_upper), dim);
    end %if
end %for

