import sys

from version import VERSION

VERSION_FILE = "version.py"
# Valid increments and increment position after `current_version.split(".")`
VALID_INCREMENTS = {
    "major": 0,
    "minor": 1,
    "patch": 2,
}


def main():
    # the value will be a string, so if it begins with feature or bugfix,
    # it will be converted to the corresponding increment
    # if it starts with major, it will be converted to the major increment
    argument = sys.argv[1].lower()
    if argument.startswith("minor"):
        increment = "minor"
    elif argument.startswith("major"):
        increment = "major"
    else:
        increment = "patch"

    print("version" ,VERSION)
    # Split version and increment
    split_version = VERSION.split(".")
    print("split_version",split_version)
    increment_index = VALID_INCREMENTS[increment]
    print("increment_index" ,increment_index)
    split_version[increment_index] = str(int(split_version[increment_index]) + 1)
    print("split_version_index",str(int(split_version[increment_index])))
    print("split-version" ,split_version[increment_index])

    # Reset lower tier versions
    if increment == "major":
        split_version[1] = "0"
        split_version[2] = "0"
    elif increment == "minor":
        split_version[2] = "0"

    # Write new version
    new_version = ".".join(split_version)
    with open(VERSION_FILE, "w") as f:
        f.write(f'VERSION = "{new_version}"\n')


if __name__ == "__main__":
    main()
