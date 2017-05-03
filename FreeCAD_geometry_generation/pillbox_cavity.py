from freecad_elements import make_beampipe, make_circular_aperture, ModelException, parameter_sweep
from sys import argv
import os

# baseline model parameters
INPUT_PARAMETERS = {'cavity_radius': 20, 'cavity_length': 20, 'pipe_radius': 10, 'pipe_length': 80}
MODEL_NAME, OUTPUT_PATH = argv


def pillbox_cavity_model(input_parameters):
    """ Generates the geometry for the pillbox cavity in FreeCAD. Also writes out the geometry as STL files 
       and writes a "sidecar" text file containing the input parameters used.

         Args:
            input_parameters (dict): Dictionary of input parameter names and values.
        """

    try:
        wire1, face1 = make_circular_aperture(input_parameters['pipe_radius'])
        wire2, face2 = make_circular_aperture(input_parameters['cavity_radius'])
        beampipe1 = make_beampipe(face1, input_parameters['pipe_length'],
                                  (-input_parameters['pipe_length'] / 2. - input_parameters['cavity_length'] / 2., 0, 0)
                                  )
        beampipe3 = make_beampipe(face1, input_parameters['pipe_length'],
                                  (input_parameters['pipe_length'] / 2. + input_parameters['cavity_length'] / 2., 0, 0)
                                  )
        beampipe2 = make_beampipe(face2, input_parameters['cavity_length'])
        fin1 = beampipe1.fuse(beampipe2)
        fin2 = fin1.fuse(beampipe3)
    except Exception as e:
        raise ModelException(e)
    # An entry in the parts dictionary corresponds to an STL file. This is useful for parts of differing materials.
    parts = {'all': fin2}
    return parts, os.path.splitext(os.path.basename(MODEL_NAME))[0]


parameter_sweep(pillbox_cavity_model, INPUT_PARAMETERS, OUTPUT_PATH, 'cavity_radius', 10, 50, 10)
parameter_sweep(pillbox_cavity_model, INPUT_PARAMETERS, OUTPUT_PATH, 'pipe_radius', 5, 25, 5)
parameter_sweep(pillbox_cavity_model, INPUT_PARAMETERS, OUTPUT_PATH, 'cavity_length', 10, 50, 10)
parameter_sweep(pillbox_cavity_model, INPUT_PARAMETERS, OUTPUT_PATH, 'cavity_radius', 10, 50, 10)
parameter_sweep(pillbox_cavity_model, INPUT_PARAMETERS, OUTPUT_PATH, 'pipe_length', 40, 110, 20)
