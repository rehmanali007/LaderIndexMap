import os
import csv
import logging
import argparse


logging.basicConfig(
    format="[%(levelname) 5s/%(asctime)s] %(name)s: %(message)s", level=logging.INFO, filename='./lader.log'
)

parser = argparse.ArgumentParser(description="LaderIndexMap Process")

parser.add_argument(
    "-pull_from_file",
    help="True/False : Wheather to use csv file or not.",
    action="store",
    dest="pull_from_file",
)
parser.add_argument(
    "-input_file", help="Input file in csv format.", action="store", dest="input_file"
)
parser.add_argument("-input", help="Input file", action="store", dest="input")
parser.add_argument("-output", help="Output file.",
                    action="store", dest="output")
parser.add_argument("-code", type=int, help="The code.",
                    action="store", dest="code")
parser.add_argument(
    "-logging", type=bool, help="Enable Logging.", action="store", dest="log"
)


def process_lader_index_map(input_file, output_file, code):
    calc = f'"{code}*(A>0)"'

    cmd = f"gdal_calc.py gdal_calc.py -A gdal_calc.py --NoDataValue=-99999 --outfile=F_temp.tif -A {input_file} --calc={calc}"
    logging.info(f"Running: {cmd}")
    os.system(cmd)

    cmd = "gdalwarp -tr 300 300 -dstnodata 0 -te -10757853.456188 4920683.977243 -10034349.767885 5388556.189920 -t_srs EPSG:3857 -overwrite -r bilinear F_temp.tif G_temp.tif"
    logging.info(f"Running: {cmd}")
    os.system(cmd)

    if not os.path.exists("F_temp.tif"):
        logging.info(f"F_temp.tif does not exist!")
    # os.system("rm F_temp.tif")

    cmd = 'saga_cmd grid_tools "Reclassify Grid Values" -INPUT=G_temp.tif -RESULT=H_temp.sdat -RETAB=matrix.txt -METHOD=0 -OLD=0.0 -NEW=0.0 -SOPERATOR=0 -MIN=0.0 -MAX=1.0 -RNEW=2.0 -ROPERATOR=0 -RETAB -OTHEROPT=0.0 -OTHERS=0.0'
    logging.info(f"Running: {cmd}")
    os.system(cmd)

    # The command below probably needs testing manually... -TOPERATOR=0 probably.

    cmd = 'saga_cmd io_gdal "Export GeoTIFF" -GRIDS=H_temp.sdat -FORMAT=1 -FILE=J_Temp.tif -TYPE=5 -NODATA'
    logging.info(f"Running: {cmd}")
    os.system(cmd)

    if not os.path.exists("G_temp.tif"):
        logging.info(" G_temp.tif does not exist!")
    if not os.path.exists("H_temp.sdat"):
        logging.info("H_temp.sdat does not exist@")

    cmd = 'rm H_temp.* G_temp.tif'
    logging.info(f"Running: {cmd}")
    # os.system(cmd)

    if not os.path.exists("output_file"):
        logging.info(f"{output_file} file does not exist!")

    cmd = f'gdal_translate -tr 300 300 -a_nodata -99999 -co COMPRESS=LZW -co JPEG_QUALITY=90 J_Temp.tif {output_file}'
    logging.info(f"Running: {cmd}")
    os.system(cmd)

    if not os.path.exists("J_Temp.tif"):
        logging.info(f"J_Temp.tif file does not exist!")
    cmd = "rm J_Temp.tif"
    # os.system(cmd)


def main():
    args = parser.parse_args()
    if not args.log:
        print("Logging is Disabled!")
        logging.disable(logging.CRITICAL)
    if args.pull_from_file:
        if args.pull_from_file.lower() == "true":
            if not args.input_file:
                parser.error(
                    "Input file is required when pull_from_file is true.")
            if not os.path.exists(args.input_file):
                parser.error("Input does not exists!")
            csv_file = open(args.input_file, "r")
            csv_file_reader = csv.DictReader(csv_file)
            for row in csv_file_reader:
                print(
                    input_file=f"{row['input_file']}\n output_file = {row['output_file']}\ncode = {row['code']}"
                )
                process_lader_index_map(
                    row["input_file"], row["output_file"], row["code"]
                )
            logging.info(f"Processed all the entries in {args.input_file}")
    else:
        if not args.input:
            parser.error("Provide an input file using -input arg ...")
        if not args.output:
            parser.error("Provide an output file using -output arg ...")
        if not args.code:
            parser.error("Provide a code -code arg ...")
        process_lader_index_map(args.input, args.output, args.code)
        print(f"Processed file {args.input} ...")


if __name__ == "__main__":
    main()
