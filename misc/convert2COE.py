def format_rgb_data(input_file, output_file):
    """
    Processes an RGB data file to remove "0x" from each value, adds a comma after each value,
    and formats it with a proper header and footer for memory initialization.

    Args:
        input_file (str): Path to the input file.
        output_file (str): Path to the output file.
    """
    with open(input_file, "r") as infile:
        # Read all lines, stripping whitespace and "0x" from each value
        data = [line.strip()[2:] for line in infile if line.strip()]

    # Open the output file for writing
    with open(output_file, "w") as outfile:
        # Write the header
        outfile.write("memory_initialization_radix=16;\n")
        outfile.write("memory_initialization_vector=")

        # Write the processed data
        for i, value in enumerate(data):
            if i < len(data) - 1:
                outfile.write(f"{value},\n")
            else:
                outfile.write(f"{value};\n")  # Last value gets a semicolon

    print(f"Formatted RGB data written to {output_file}")


# Input and output file paths
input_file = "behemothLogo_Region0.txt"  # Input file from the previous script
output_file = "behemothLogo_Region0.coe"  # Output file for formatted data

# Format the RGB data
format_rgb_data(input_file, output_file)
