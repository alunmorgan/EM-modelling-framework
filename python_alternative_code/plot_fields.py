import numpy as np
import os
import scipy.io as sio
import matplotlib.pyplot as plt
from tqdm import tqdm

def make_field_images(data, metadata, timestamps, max_field_component, output_location, name_of_model, ROI):
    field_components = ['Fx', 'Fy', 'Fz']
    field_images = [None] * 3

    slice_dir = 'z'  # Assuming 'z' as default, adjust as needed
    if slice_dir == 'z':
        xaxis, yaxis = np.meshgrid(metadata['coord_x'], metadata['coord_y'])
        xlab = 'Horizontal (mm)'
        ylab = 'Vertical (mm)'
    elif slice_dir == 'x':
        xaxis, yaxis = np.meshgrid(metadata['coord_y'], metadata['coord_z'])
        xlab = 'Vertical (mm)'
        ylab = 'Beam direction (mm)'
    elif slice_dir == 'y':
        xaxis, yaxis = np.meshgrid(metadata['coord_x'], metadata['coord_z'])
        xlab = 'Horizontal (mm)'
        ylab = 'Beam direction (mm)'

    geometry_slice = geometry_from_slice_data(data['Fx'], data['Fy'], data['Fz'])
    if not np.isnan(ROI):
        xax = xaxis[0, :]
        yax = yaxis[:, 0]
        if slice_dir == 'z':
            x_ind1 = np.where(np.abs(xax) < ROI)[0][0]
            x_ind2 = np.where(np.abs(xax) < ROI)[0][-1]
            y_ind1 = np.where(np.abs(yax) < ROI)[0][0]
            y_ind2 = np.where(np.abs(yax) < ROI)[0][-1]
        elif slice_dir == 'y':
            x_ind1 = np.where(np.abs(xax) < ROI)[0][0]
            x_ind2 = np.where(np.abs(xax) < ROI)[0][-1]
            y_ind1 = 0
            y_ind2 = len(yax) - 1
        elif slice_dir == 'x':
            x_ind1 = np.where(np.abs(xax) < ROI)[0][0]
            x_ind2 = np.where(np.abs(xax) < ROI)[0][-1]
            y_ind1 = 0
            y_ind2 = len(yax) - 1

        xaxis_trim = xaxis[y_ind1:y_ind2+1, x_ind1:x_ind2+1]
        yaxis_trim = yaxis[y_ind1:y_ind2+1, x_ind1:x_ind2+1]
        ROI_tag = f'_ROI{round(ROI*1000*10)/10}mm'.replace('.', 'p')
        geometry_slice_trim = geometry_slice[x_ind1:x_ind2+1, y_ind1:y_ind2+1]
        dirfields_trim = {field: data[field][x_ind1:x_ind2+1, y_ind1:y_ind2+1, :] for field in field_components}
    else:
        xaxis_trim = xaxis
        yaxis_trim = yaxis
        geometry_slice_trim = geometry_slice
        ROI_tag = ''
        dirfields_trim = {field: data[field] for field in field_components}

    out_name = f"{name_of_model}_{field_components[0]}-field_{slice_dir}_slice_direction{ROI_tag}_fieldFrames.mat"
    if not os.path.isfile(os.path.join(output_location, out_name)):
        fig, ax = plt.subplots(figsize=(15, 6))
        for oas, field_name in enumerate(field_components):
            dirfields_trim_temp = dirfields_trim[field_name]
            graph_lims = [np.nanmin(dirfields_trim_temp), np.nanmax(dirfields_trim_temp)]
            timescale = timestamps
            Frames = []
            for ifen in tqdm(range(dirfields_trim_temp.shape[2]), desc=f"Processing {field_name}"):
                slice_data = np.squeeze(dirfields_trim_temp[:, :, ifen])
                actual_time = round(timescale[ifen] * 1E9 * 100) / 100
                slice_data[geometry_slice_trim == 0] = np.nan
                plot_z_slice_fields(ax, xaxis_trim, yaxis_trim, slice_data, slice_dir, field_name, actual_time, graph_lims)
                fig.canvas.draw()
                frame = np.frombuffer(fig.canvas.tostring_rgb(), dtype='uint8').reshape(fig.canvas.get_width_height()[::-1] + (3,))
                Frames.append(frame)
                ax.clear()
            field_images[oas] = {'frames': Frames, 'field_component': field_name, 'slice_dir': slice_dir}
        plt.close(fig)
        sio.savemat(os.path.join(output_location, out_name), {'field_images': field_images})
        return field_images

def plot_z_slice_fields(ax, xaxis, yaxis, slice_data, slice_dir, field_name, actual_time, graph_lims):
    c = ax.pcolormesh(xaxis, yaxis, slice_data, shading='auto', vmin=graph_lims[0], vmax=graph_lims[1])
    ax.set_title(f"{field_name} at {actual_time} ns")
    ax.set_xlabel('Horizontal (mm)')
    ax.set_ylabel('Vertical (mm)')
    plt.colorbar(c, ax=ax)

# Example usage:
# field_images = make_field_images(data, metadata, timestamps, max_field_component, output_location, name_of_model, ROI)

import numpy as np
import matplotlib.pyplot as plt

def plot_field_slices(fig_handle, data_Fx, data_Fy, data_Fz, metadata, timestamp, field_type, slice_dir, field_levels, geometry_slice):
    data = {'Fx': data_Fx, 'Fy': data_Fy, 'Fz': data_Fz}
    field_components = ['Fx', 'Fy', 'Fz']
    time_val = round(timestamp * 1E9 * 100) / 100
    main_title_string = f"{field_type}-field slice direction: {slice_dir} at {time_val}ns"
    
    fig_handle.clf()
    fig_handle.suptitle(main_title_string, fontsize=14, fontweight='bold')

    temp_accum = np.full((data_Fx.shape[0], data_Fx.shape[1], len(field_components)), np.nan)

    if slice_dir == 'z':
        xaxis, yaxis = np.meshgrid(metadata['coord_x'], metadata['coord_y'])
        xlab = 'Horizontal (mm)'
        ylab = 'Vertical (mm)'
    elif slice_dir == 'x':
        xaxis, yaxis = np.meshgrid(metadata['coord_y'], metadata['coord_z'])
        xlab = 'Vertical (mm)'
        ylab = 'Beam direction (mm)'
    elif slice_dir == 'y':
        xaxis, yaxis = np.meshgrid(metadata['coord_x'], metadata['coord_z'])
        xlab = 'Horizontal (mm)'
        ylab = 'Beam direction (mm)'

    for igr, field_name in enumerate(field_components):
        slice_data = data[field_name]
        slice_data[geometry_slice == 0] = np.nan
        temp_accum[:, :, igr] = slice_data

        ax = fig_handle.add_subplot(1, len(field_components) + 1, igr + 1)
        if field_levels is None:
            contour = ax.contourf(xaxis * 1e3, yaxis * 1e3, slice_data.T, cmap='jet')
        else:
            slice_data[0, 0] = min(field_levels)
            slice_data[-1, -1] = max(field_levels)
            contour = ax.contourf(xaxis * 1e3, yaxis * 1e3, slice_data.T, levels=field_levels, cmap='jet')
        
        ax.set_xlabel(xlab)
        ax.set_ylabel(ylab)
        ax.set_title(field_name)
        ax.axis('equal')
        fig_handle.colorbar(contour, ax=ax)

    temp_accum = np.sqrt(np.sum(temp_accum ** 2, axis=2))

    ax = fig_handle.add_subplot(1, len(field_components) + 1, len(field_components) + 1)
    if field_levels is None:
        contour = ax.contourf(xaxis * 1e3, yaxis * 1e3, temp_accum.T, cmap='jet')
    else:
        temp_accum[0, 0] = max(field_levels)
        contour = ax.contourf(xaxis * 1e3, yaxis * 1e3, temp_accum.T, levels=field_levels, cmap='jet')
    
    ax.set_title('Field magnitude')
    ax.axis('equal')
    fig_handle.colorbar(contour, ax=ax)

    plt.draw()

# Example usage:
# fig_handle = plt.figure()
# plot_field_slices(fig_handle, data_Fx, data_Fy, data_Fz, metadata, timestamp, field_type, slice_dir, field_levels, geometry_slice)

import numpy as np
import os
import matplotlib.pyplot as plt

def plot_field_views_selected_timeslice(data, field_type, slice_dir, output_location, name_of_model, selected_time, ROI):
    field_components = ['Fx', 'Fy', 'Fz']
    selected_timeslice = np.argmax(data['timestamp'] > selected_time * 1E-9)
    
    if data['timestamp'][selected_timeslice] <= selected_time * 1E-9:
        print('\nSelected time is not in dataset')
        return
    
    actual_time = round(data['timestamp'][selected_timeslice] * 1E9 * 100) / 100
    geometry_slice = geometry_from_slice_data(data['Fx'], data['Fy'], data['Fz'])
    xaxis, yaxis = np.meshgrid(data['coord_1'], data['coord_2'])
    xax = xaxis[0, :]
    yax = yaxis[:, 0]
    
    if slice_dir == 'z':
        x_ind1 = np.where(np.abs(xax) < ROI)[0][0]
        x_ind2 = np.where(np.abs(xax) < ROI)[0][-1]
        y_ind1 = np.where(np.abs(yax) < ROI)[0][0]
        y_ind2 = np.where(np.abs(yax) < ROI)[0][-1]
    elif slice_dir == 'y':
        x_ind1 = np.where(np.abs(xax) < ROI)[0][0]
        x_ind2 = np.where(np.abs(xax) < ROI)[0][-1]
        y_ind1 = 0
        y_ind2 = len(yax) - 1
    elif slice_dir == 'x':
        x_ind1 = np.where(np.abs(xax) < ROI)[0][0]
        x_ind2 = np.where(np.abs(xax) < ROI)[0][-1]
        y_ind1 = 0
        y_ind2 = len(yax) - 1

    xaxis_trim = xaxis[y_ind1:y_ind2+1, x_ind1:x_ind2+1]
    yaxis_trim = yaxis[y_ind1:y_ind2+1, x_ind1:x_ind2+1]
    
    fig, ax = plt.subplots(figsize=(15, 6))
    
    for field_name in field_components:
        output_name = f"{name_of_model}_{field_type}-field_through_centre_{slice_dir}_slice_direction_{field_name}_at_slice_{selected_timeslice}"
        if not os.path.isfile(os.path.join(output_location, f"{output_name}.png")):
            dirfields = data[field_name]
            dirfields_trim = dirfields[x_ind1:x_ind2+1, y_ind1:y_ind2+1, :]
            geometry_slice_trim = geometry_slice[x_ind1:x_ind2+1, y_ind1:y_ind2+1]
            slice_data = np.squeeze(dirfields_trim[:, :, selected_timeslice])
            slice_data[geometry_slice_trim == 0] = np.nan
            
            plot_z_slice_fields(ax, xaxis_trim, yaxis_trim, slice_data, slice_dir, field_name, field_type, actual_time)
            plt.savefig(os.path.join(output_location, f"{output_name}.png"))
            ax.clear()
            plt.pause(0.05)  # this innocent line prevents the Python hang
            print('.')
    
    plt.close(fig)

def plot_z_slice_fields(ax, xaxis, yaxis, slice_data, slice_dir, field_name, field_type, actual_time):
    c = ax.pcolormesh(xaxis, yaxis, slice_data, shading='auto', cmap='jet')
    ax.set_title(f"{field_name} at {actual_time} ns")
    ax.set_xlabel('Horizontal (mm)')
    ax.set_ylabel('Vertical (mm)')
    plt.colorbar(c, ax=ax)

# Example usage:
# plot_field_views_selected_timeslice(data, field_type, slice_dir, output_location, name_of_model, selected_time, ROI)
