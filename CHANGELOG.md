# 3.0.0
## Breaking changes
* Exit code is 0 on `--help` or running without parameters. Before it was 1.

# 2.2.1
## Bugfixes
* Fixed message adding a blacklist of '.' when no blacklist is specified

# 2.2.0
## Features
* Added `--summary` argument for printing the whitelist and blacklist summary before the run

# 2.1.0
## Features
* Added coloring of output and consolidated output

# 2.0.0
## Breaking changes
* Changed the way to specify files for scanning (without `--file filename`) to be able to pipe the filenames from `find`

# 1.0.1

## Features
* Cleaned the code and added tests

# 1.0.0
First stable version