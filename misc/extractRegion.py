def extract_region(input_file, output_file, width, height, start_x, start_y, region_width, region_height):
    """
    Extracts a specific region from RGB data in a text file and saves it to a new file.

    Args:
        input_file (str): Path to the input RGB data text file.
        output_file (str): Path to the output RGB data text file.
        width (int): Width of the full image.
        height (int): Height of the full image.
        start_x (int): Starting horizontal position (column).
        start_y (int): Starting vertical position (row).
        region_width (int): Width of the region to extract.
        region_height (int): Height of the region to extract.
    """
    with open(input_file, "r") as infile:
        data = [line.strip() for line in infile]

    # Ensure the region fits within the image dimensions
    if start_x + region_width > width or start_y + region_height > height:
        raise ValueError("The specified region is out of bounds of the image dimensions.")

    # Extract the region
    extracted_data = []
    for row in range(start_y, start_y + region_height):
        for col in range(start_x, start_x + region_width):
            index = row * width + col  # Calculate the index in the flat list
            extracted_data.append(data[index])

    # Write the extracted region to the output file
    with open(output_file, "w") as outfile:
        for pixel in extracted_data:
            outfile.write(pixel + "\n")

    print(f"Region extracted and saved to {output_file}")


# Inputs
input_file = "behemothLogo0.txt"  # Input RGB data file
output_file = "behemothLogo_Region0.txt"  # Output file for the extracted region
image_width = 1920  # Full image width
image_height = 1080  # Full image height

# Region details
start_x = 810  # Starting column
start_y = 356  # Starting row
region_width = 300  # Width of the region
region_height = 370  # Height of the region

# Extract the region
extract_region(input_file, output_file, image_width, image_height, start_x, start_y, region_width, region_height)
