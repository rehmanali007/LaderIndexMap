import csv


def write_data():
    new_file = open("file.csv", "w")
    csv_writer = csv.writer(new_file, delimiter=",")
    csv_writer.writerow(["input_file", "output_file", "code"])
    csv_writer.writerow(["main.tif", "main_13.tif", 13])
    csv_writer.writerow(["bla.tif", "bla_04.tif", 4])


def read_data():
    new_file = open("file.csv", "r")
    new_file_reader = csv.DictReader(new_file)
    for row in new_file_reader:
        print(row["input_file"])


write_data()

read_data()
