from PIL import Image

def jpg_to_rgb_raw(input_file, output_file):
  # Open the JPG image
  image = Image.open(input_file).convert("RGB")

  # get resolution
  width, height = image.size
  print(f"Resolution: {width}x{height}")

  # Get the RGB data as a flat list of tuples (R, G, B)
  rgb_data = list(image.getdata())

  # Open the output file for writing
  with open(output_file, "w") as f:
      for r, g, b in rgb_data:
          # Format as 24-bit Blue, Red, Green in hex (e.g., 0x00FF00)
          hex_value = f"0x{b:02X}{r:02X}{g:02X}"
          f.write(hex_value + "\n")

  print(f"Raw RGB data written to {output_file}")

# Input JPG file and output raw data file
input_jpg = "behemothLogo0.jpg"  # Replace with your input JPG file
output_raw = "behemothLogo0.txt"  # Replace with your desired output file

# Convert and save the raw RGB data
jpg_to_rgb_raw(input_jpg, output_raw)
