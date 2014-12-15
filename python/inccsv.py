import os

class IncrementalCSV:
    def __init__(self, filename):
        if os.path.exists(filename):
            raise ValueError(filename + " already exists")
        self.filename = filename
        self.row_empty = True

    def add_value(self, value):
        with open(self.filename, "a") as fp:
            if self.row_empty:
                fp.write(str(value))
                self.row_empty = False
            else:
                fp.write(',' + str(value))

    def end_row(self):
        with open(self.filename, "a") as fp:
            fp.write("\n")
        self.row_empty = True

class IncrementalByLine:
    def __init__(self, filename):
        if os.path.exists(filename):
            raise ValueError(filename + " already exists")
        self.filename = filename

    def add_line(self, line):
        with open(self.filename, "a") as fp:
            fp.write(line)
            fp.write("\n")
