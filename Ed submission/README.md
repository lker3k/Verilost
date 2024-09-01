# File Navigation

Individual modules are within the Modules folder, they can be run with the module_script.sh file, eg the rng module can be tested with rng_script.sh

To simulate the integrated modules, use the integration_script.sh in the Integration folder.

The Final folder does not contain test benches, it is the code that was running on hardware. This is because some changes we made after and was only run on hardware, without going back and testbenching

# Testbenches for Verilog Modules

This README provides an overview of multiple Verilog testbenches used to simulate and verify the functionality of various digital modules. Each testbench is designed to validate a specific module under different scenarios to ensure correct behavior and performance.

## Overview

The following testbenches are included in this suite:

1. **`bit_counter_tb`**: Tests the functionality of the `bit_counter` module.
2. **`debounce_tb`**: Verifies the debounce logic for a noisy button input.
3. **`display_tb`**: Simulates a module that drives a 7-segment display.
4. **`rng_tb`**: Tests a random number generator (RNG) module.
5. **`seven_seg_tb`**: Tests the functionality of a 7-segment display decoder.
6. **`timer_tb`**: Verifies a digital timer module's behavior.

Each testbench generates a set of input signals, applies them to the corresponding Device Under Test (DUT), and observes the output to ensure that the module under test operates as expected.

## Files

- **`bit_counter_tb.v`**: Testbench for the `bit_counter` module.
- **`debounce_tb.v`**: Testbench for the debounce module.
- **`display_tb.v`**: Testbench for the display driving module.
- **`rng_tb.v`**: Testbench for the random number generator module.
- **`seven_seg_tb.v`**: Testbench for the 7-segment display decoder module.
- **`timer_tb.v`**: Testbench for the timer module.
- **`waveform.vcd`**: Output waveform file generated during simulation for all testbenches.

## Common Testbench Structure

Each testbench follows a similar structure:

1. **Define Testbench Variables and Clock**: Registers and wires are declared to represent inputs and outputs for the DUT. Clock signals are generated if needed.

2. **DUT Instantiation**: The DUT is instantiated and connected to the testbench signals.

3. **Clock Generation**: For modules requiring a clock signal, a clock is generated using an infinite loop (`forever` statement).

4. **Initial Block for Input Stimuli**:
   - Input signals are initialized and modified over time using delay operators (`#`).
   - Random input stimuli are generated using `$urandom()` for more extensive testing scenarios.
   - The outputs are logged using `$display` to observe the DUT's behavior.

5. **Waveform Dumping**:
   - `$dumpfile` and `$dumpvars` commands are used to generate a waveform file (`waveform.vcd`) that can be analyzed using a waveform viewer.

6. **Simulation Termination**:
   - `$finish` is used to end the simulation after all tests have been executed.

## How to Run the Testbenches

To run any of the testbenches, you will need a Verilog simulation tool such as ModelSim, Icarus Verilog, or Vivado. Follow these steps to simulate any of the modules:

1. Open your terminal or command line interface.
2. Navigate to the directory containing the testbench file (e.g., `bit_counter_tb.v`).
3. Compile the testbench with your Verilog simulator. For example, using Icarus Verilog:

   ```bash
   iverilog -o bit_counter_tb.vvp bit_counter_tb.v


