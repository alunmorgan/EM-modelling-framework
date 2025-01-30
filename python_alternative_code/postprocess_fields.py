import concurrent.futures
import re
import numpy as np
import os
import scipy.io as sio
from tqdm import tqdm

def process_snapshot_fields(fileset, fileset_name, out_path):
    number_of_parallel_files = 6
    futures = []
    with concurrent.futures.ThreadPoolExecutor() as executor:
        for wne in range(0, len(fileset), number_of_parallel_files):
            for wns in range(number_of_parallel_files):
                if wne + wns >= len(fileset):
                    continue
                futures.append(executor.submit(read_single_fexport_file, fileset[wne + wns]))
            for future in concurrent.futures.as_completed(futures):
                construct_snapshot_file(future.result(), fileset_name, out_path)
                update_waitbar(len(futures), len(fileset))

def read_single_fexport_file(file):
    with open(file, 'r') as f:
        return f.readlines()

def construct_snapshot_file(test_input, fileset_name, out_path):
    def find_boundary(test_input, key):
        temp_boundary = next(line for line in test_input if key in line)
        return int(re.search(r'\s*([0-9]+)\s*:', temp_boundary).group(1))

    n_coords_x = find_boundary(test_input, 'ix2') - find_boundary(test_input, 'ix1') + 1
    n_coords_y = find_boundary(test_input, 'iy2') - find_boundary(test_input, 'iy1') + 1
    n_coords_z = find_boundary(test_input, 'iz2') - find_boundary(test_input, 'iz1') + 1

    def extract_coordinates(test_input, key, n_coords):
        start_ind = next(i for i, line in enumerate(test_input) if key in line)
        return np.array([float(re.search(r'\s*([0-9-+eE.]+)\s+', test_input[start_ind + i]).group(1)) for i in range(n_coords)])

    data_coord_x = extract_coordinates(test_input, 'X-Coordinates(ix1:ix2):', n_coords_x)
    data_coord_y = extract_coordinates(test_input, 'Y-Coordinates(iy1:iy2):', n_coords_y)
    data_coord_z = extract_coordinates(test_input, 'Z-Coordinates(iz1:iz2):', n_coords_z)

    data = {'coord_x': data_coord_x, 'coord_y': data_coord_y, 'coord_z': data_coord_z}

    Fx = np.full((n_coords_x, n_coords_y, n_coords_z), np.nan)
    Fy = np.full((n_coords_x, n_coords_y, n_coords_z), np.nan)
    Fz = np.full((n_coords_x, n_coords_y, n_coords_z), np.nan)

    if not test_input:
        return

    timestamp_temp = next(line for line in test_input if 'subtitle:' in line)
    time_temp = re.search(r'(E|H)_[0-9]+,\st=\s*([0-9\.eE-+]+)', timestamp_temp)
    timestamp = float(time_temp.group(2))
    field_type = time_temp.group(1)
    data['timestamp'] = timestamp

    data_start_ind = next(i for i, line in enumerate(test_input) if 'END DO' in line) + 2
    test_input = test_input[data_start_ind:]

    temp_slices = [test_input[i * n_coords_x * n_coords_y:(i + 1) * n_coords_x * n_coords_y] for i in range(n_coords_z)]

    for jwad, temp_slice in enumerate(temp_slices):
        for hfgs in range(n_coords_y):
            x_start_index = hfgs * n_coords_x
            x_end_index = (hfgs + 1) * n_coords_x
            temp_slice2 = temp_slice[x_start_index:x_end_index]
            for hsk, line in enumerate(temp_slice2):
                temp_data_reg = re.search(r'\s*([0-9-+eE.]+)\s+([0-9-+eE.]+)\s+([0-9-+eE.]+)', line)
                Fx[hsk, hfgs, jwad] = float(temp_data_reg.group(1))
                Fy[hsk, hfgs, jwad] = float(temp_data_reg.group(2))
                Fz[hsk, hfgs, jwad] = float(temp_data_reg.group(3))

    timestamp_label = str(timestamp).replace('.', 'p')
    sio.savemat(os.path.join(out_path, f'field_data_snapshots_Fx{field_type}{fileset_name}{timestamp_label}.mat'), {'Fx': Fx, 'data': data})
    sio.savemat(os.path.join(out_path, f'field_data_snapshots_Fy{field_type}{fileset_name}{timestamp_label}.mat'), {'Fy': Fy, 'data': data})
    sio.savemat(os.path.join(out_path, f'field_data_snapshots_Fz{field_type}{fileset_name}{timestamp_label}.mat'), {'Fz': Fz, 'data': data})

def update_waitbar(current, total):
    progress = current / total
    tqdm.write(f'Progress: {progress:.2%}')

# Example usage:
# process_snapshot_fields(['file1.txt', 'file2.txt'], 'fileset_name', 'output_path')
