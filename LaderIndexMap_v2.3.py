import os
import csv
import argparse

parser = argparse.ArgumentParser(description="")

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
parser.add_argument("-output", help="Output file.", action="store", dest="output")
parser.add_argument("-code", type=int, help="The code.", action="store", dest="code")


def process_lader_index_map(input_file, output_file, code):
    calc = f'"{code}*(A>0)"'
    os.system(
        f"gdal_calc.py -A gdal_calc.py --NoDataValue=0 --outfile=F_temp.tif -A {input_file} --calc={calc}"
    )

    os.system(
        "gdalwarp -tr 300 300 -dstnodata 0 -te -13887126.77 2814162.483 -7430226.771 6360162.483 -t_srs EPSG:3857 -overwrite -r bilinear F_temp.tif  G_temp.tif"
    )

    os.system("rm F_temp.tif")

    os.system(
        'saga_cmd grid_tools "Reclassify Grid Values" -INPUT=G_temp.tif -RESULT=H_temp.sdat -RETAB=matrix.txt -METHOD=0 -OLD=0.0 -NEW=0.0 -SOPERATOR=0 -MIN=0.0 -MAX=1.0 -RNEW=2.0 -ROPERATOR=0 -RETAB -OTHEROPT=false -OTHERS=0.0'
    )

    # The command below probably needs testing manually... -TOPERATOR=0 probably.
    os.system(
        'saga_cmd io_gdal "Export GeoTIFF" -GRIDS=H_temp.sdat -TOPERATOR=0 -NODATAOPT=true -FILE=J_Temp.tif'
    )

    os.system("rm H_temp.* G_temp.tif")

    os.system(
        f"gdal_translate -tr 300 300 -a_nodata 0 -co  COMPRESS=LZW -co JPEG_QUALITY=80 J_Temp.tif {output_file}"
    )

    os.system("rm J_Temp.tif")


def main():
    args = parser.parse_args()
    if args.pull_from_file:
        if args.pull_from_file.lower() == "true":
            if not args.input_file:
                parser.error("Input file is required when pull_from_file is true.")
            if not os.path.exists(args.input_file):
                parser.error("Input does not exists!")
            csv_file = open(args.input_file, "r")
            csv_file_reader = csv.DictReader(csv_file)
            for row in csv_file_reader:
                print(
                    f"input_file = {row['input_file']}\n output_file = {row['output_file']}\ncode = {row['code']}"
                )
                # process_lader_index_map(
                #     row["input_file"], row["output_file"], row["code"]
                # )
            print(f"Processed all the entries in {args.input_file}")
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
