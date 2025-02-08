import mido
import time

# OSC client setup

# Define the MIDI input port (make sure to replace 'Akai LPD8' with your actual device name)
port_name = "LPD8 0"
output_file = "midi_values.txt"

# def list_ports():
#     # Get available MIDI input ports
#     input_ports = mido.get_input_names()
#     print("Available MIDI Input Ports:")
#     for port in input_ports:
#         print(port)

#     # Get available MIDI output ports
#     output_ports = mido.get_output_names()
#     print("\nAvailable MIDI Output Ports:")
#     for port in output_ports:
#         print(port)
        
# list_ports()
# Create a dictionary to store the last known values for each control and note states
control_values = {}
pad_states = {}

# Optionally, initialize the pad states (assuming off)
def initialize_pad_states(pad_numbers):
    for pad in pad_numbers:
        pad_states[pad] = 0  # 0 indicates that the pad is off

with mido.open_input(port_name) as inport:
    
    # Assuming you know the control numbers and pad numbers,
    # you can initialize them here. Example for Akai LPD8:
    control_numbers = list(range(0, 8))  # Assuming 8 knobs
    pad_numbers = list(range(36, 44))  # Pads 36-43 (MIDI note numbers for LPD8)

    # Initialize control values to default (you may change the values as needed)
    for control in control_numbers:
        control_values[control] = 0  # Assuming default value is 0

    # Initialize pad states
    initialize_pad_states(pad_numbers)

    while True:
        for msg in inport.iter_pending():  # Listen for incoming MIDI messages
            if msg.type == "control_change":
                control, value = msg.control, msg.value
                # Update control values
                control_values[control] = value
                
                # Clear previous inputs and write current control values and pad states to the file
                with open(output_file, "w") as f:  # Use "w" to overwrite the file
                    # Write control values
                    for ctrl, val in control_values.items():
                        f.write(f"Control {ctrl}:{val}\n")  # Format as "Control control:value"
                
                    # Write pad states
                    for note, state in pad_states.items():
                        f.write(f"Pad {note}:{state}\n")  # Format as "Pad note:state"

                print(f"Wrote control values and pad states to file: Control {control}:{value}")
                
            elif msg.type == "note_on":
                pad_states[msg.note] = msg.velocity  # Save the velocity as the state for note_on
                print(f"Pad On: {msg.note}, Velocity: {msg.velocity}")
                
                # Clear previous inputs and write current control values and pad states to the file
                with open(output_file, "w") as f:
                    # Write control values
                    for ctrl, val in control_values.items():
                        f.write(f"Control {ctrl}:{val}\n")  # Format as "Control control:value"
                
                    # Write pad states
                    for note, state in pad_states.items():
                        f.write(f"Pad {note}:{state}\n")  # Format as "Pad note:state"

            elif msg.type == "note_off":
                # Update the pad state for note_off
                pad_states[msg.note] = 0  # Use 0 to indicate that the pad is off
                print(f"Pad Off: {msg.note}")
                
                # Clear previous inputs and write current control values and pad states to the file
                with open(output_file, "w") as f:
                    # Write control values
                    for ctrl, val in control_values.items():
                        f.write(f"Control {ctrl}:{val}\n")  # Format as "Control control:value"
                
                    # Write pad states
                    for note, state in pad_states.items():
                        f.write(f"Pad {note}:{state}\n")  # Format as "Pad note:state"

        time.sleep(0.01)  # Add a small delay to avoid high CPU usage
