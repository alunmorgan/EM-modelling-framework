from freecad_elements import make_beampipe, make_racetrack_aperture, make_circular_aperture,\
    make_taper, ModelException, parameter_sweep, base_model
from sys import argv
import os

# baseline model parameters
INPUT_PARAMETERS = {'racetrack_height': 10, 'racetrack_width': 40, 'racetrack_length': 80,
                    'cavity_radius': 20, 'cavity_length': 20, 'taper_length': 30}
MODEL_NAME, OUTPUT_PATH = argv


def racetrack_to_octagonal_cavity_model(input_parameters):
    """Generates the geometry for the elliptical taper in FreeCAD. Also writes out the geometry as STL files 
       and writes a "sidecar" text file containing the input parameters used.

         Args:
            input_parameters (dict): Dictionary of input parameter names and values.
        """
    try:
        wire1, face1 = make_racetrack_aperture(input_parameters['racetrack_height'],
                                               input_parameters['racetrack_width'])
        wire2, face2 = make_circular_aperture(input_parameters['cavity_radius'])
        beampipe1 = make_beampipe(face1, input_parameters['racetrack_length'],
                                  (-input_parameters['racetrack_length'] / 2. -
                                   input_parameters['taper_length'] -
                                   input_parameters['cavity_length'] / 2., 0, 0))
        taper1 = make_taper(wire2, wire1, input_parameters['taper_length'],
                            (-input_parameters['cavity_length'] / 2., 0, 0), (0, 180, 0))
        beampipe2 = make_beampipe(face2, input_parameters['cavity_length'])
        taper2 = make_taper(wire2, wire1, input_parameters['taper_length'],
                            (input_parameters['cavity_length'] / 2., 0, 0))
        beampipe3 = make_beampipe(face1, input_parameters['racetrack_length'],
                                  (input_parameters['racetrack_length'] / 2. +
                                   input_parameters['taper_length'] +
                                   input_parameters['cavity_length'] / 2., 0, 0))
        fin1 = beampipe1.fuse(taper1)
        fin2 = fin1.fuse(beampipe2)
        fin3 = fin2.fuse(taper2)
        fin4 = fin3.fuse(beampipe3)
    except Exception as e:
        raise ModelException(e)
    # An entry in the parts dictionary corresponds to an STL file. This is useful for parts of differing materials.
    parts = {'all': fin4}
    return parts, os.path.splitext(os.path.basename(MODEL_NAME))[0]


base_model(racetrack_to_octagonal_cavity_model, INPUT_PARAMETERS, OUTPUT_PATH, accuracy=10)
parameter_sweep(racetrack_to_octagonal_cavity_model, INPUT_PARAMETERS, OUTPUT_PATH, 'cavity_radius', [5, 10, 15, 25, 30])
parameter_sweep(racetrack_to_octagonal_cavity_model, INPUT_PARAMETERS, OUTPUT_PATH, 'taper_length', [10, 20, 40, 50, 60])
parameter_sweep(racetrack_to_octagonal_cavity_model, INPUT_PARAMETERS, OUTPUT_PATH, 'racetrack_height', [15, 20, 25, 30, 35, 40, 45, 50])
parameter_sweep(racetrack_to_octagonal_cavity_model, INPUT_PARAMETERS, OUTPUT_PATH, 'racetrack_width', [20, 30, 50, 60, 70])
parameter_sweep(racetrack_to_octagonal_cavity_model, INPUT_PARAMETERS, OUTPUT_PATH, 'racetrack_length', [50, 100, 150, 200, 250, 300])
parameter_sweep(racetrack_to_octagonal_cavity_model, INPUT_PARAMETERS, OUTPUT_PATH, 'cavity_length', [10, 30])
