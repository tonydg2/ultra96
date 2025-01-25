from PIL import Image

def jpg_to_rgb_raw(input_file):
  # Open the JPG image
  image = Image.open(input_file).convert("RGB")

  # get resolution
  width, height = image.size
  print(f"Resolution: {width}x{height}")

# Input JPG file and output raw data file
input_jpg = "behemothLogo0.jpg"  # Replace with your input JPG file

# Convert and save the raw RGB data
jpg_to_rgb_raw(input_jpg)
