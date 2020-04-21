function [output_matrix, sc]= matrix_reduction(input_data, reduction)

[first_reduction ,sc1] = matrix_reduction_1D(input_data, 1, reduction);
[second_reduction, sc2 ] = matrix_reduction_1D(first_reduction, 2, reduction);
[output_matrix, sc3] = matrix_reduction_1D(second_reduction, 3, reduction);

sc = [sc1, sc2, sc3];