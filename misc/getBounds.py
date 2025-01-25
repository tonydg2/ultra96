def find_logo_boundaries(txt_file, width, height, black_value="0x010101"):
    # Read the RGB data from the text file
    with open(txt_file, "r") as f:
        data = [line.strip() for line in f]

    # Initialize boundaries
    min_row, max_row = height, 0
    min_col, max_col = width, 0

    # Iterate through each pixel
    for row in range(height):
        for col in range(width):
            # Calculate the linear index in the flat list
            index = row * width + col
            if data[index] != black_value:  # Check if the pixel is non-black
                # Update boundaries
                min_row = min(min_row, row)
                max_row = max(max_row, row)
                min_col = min(min_col, col)
                max_col = max(max_col, col)

    # Check if boundaries were updated
    if min_row > max_row or min_col > max_col:
        print("Logo not found.")
        return None

    # Return the logo boundaries
    return (min_row, max_row, min_col, max_col)


# Input details
txt_file = "behemothLogo0.txt"  # The text file with RGB data
width = 1920  # Width of the image
height = 1080  # Height of the image

# Call the function to find logo boundaries
boundaries = find_logo_boundaries(txt_file, width, height)

# Print the results
if boundaries:
    min_row, max_row, min_col, max_col = boundaries
    print(f"Logo is located at:")
    print(f"Vertical range (rows): {min_row} to {max_row}")
    print(f"Horizontal range (columns): {min_col} to {max_col}")
