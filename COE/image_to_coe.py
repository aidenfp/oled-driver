import sys
from PIL import Image

coe_hdr = '''memory_initialization_radix=2;
memory_initialization_vector=
'''

def format_bin(x):
    raw = bin(x)[2:]
    return "0"*(8 - len(raw)) + raw


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: {0} <image to convert>".format(sys.argv[0]))
    else:
        fname = sys.argv[1]
        name = fname.split("/")[-1].split(".")[0]
        img = Image.open(fname)
        cimg = img.convert("P")
        
        raw_palette = cimg.getpalette()
        palette = []
        for i in range(0, len(raw_palette), 3):
            palette.append(tuple(raw_palette[i:i+3]))

        with open(f"{name}_cm_r.coe", "w") as f:
            f.write(coe_hdr)
            for i in range(256):
                f.write(format_bin(palette[i][0]) + ",\n")
        
        with open(f"{name}_cm_g.coe", "w") as f:
            f.write(coe_hdr)
            for i in range(256):
                f.write(format_bin(palette[i][1]) + ",\n")
        
        with open(f"{name}_cm_b.coe", "w") as f:
            f.write(coe_hdr)
            for i in range(256):
                f.write(format_bin(palette[i][2]) + ",\n")
        
        (w, h) = cimg.size
        with open(f"{name}_im.coe", "w") as f:
            f.write(coe_hdr)
            for y in range(h):
                for x in range(w):
                    f.write(format_bin(cimg.getpixel((x, y))) + ",\n")
                    
