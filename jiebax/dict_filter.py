


import sys

class DictFilter():

    def __init__(self, dict_filepath, new_dict_filepath=None):

        pass


def filter_dict(dict_filepath, new_dict_filepath=None, min_freq=10):

    new_lines = []

    with open(dict_filepath, "r") as F:
        for line in F:
            line = line.strip()
            if line:
                line_data = line.split(" ")
                if len(line_data) > 1 and int(line_data[1]) >= min_freq:
                    new_lines.append(line)

    if new_dict_filepath is None:
        return new_lines
    else:
        with open(new_dict_filepath, "w") as F:
            F.write("\n".join(new_lines))


def _filter_default_dict():
    filter_dict("./jieba.dict.default.txt", "./jieba.dict.better.txt", min_freq=10)



if __name__ == '__main__':
    _filter_default_dict()
    





