# Project Title

Bulk translate text segements stored in tabular format.

## Description

Simple tool with interactive file/directory picker that translates text segments stored in tabular format -- csv --outputing a clean dataframe with full-text english translation. Uses the polyglotr package to detect and translate languages, and checks for language label (in properly formatted input data) before calling the translate function.

## Getting Started

### Dependencies

* OS independent (i.e., works on both Mac & Windows computers)
* Requires installation of R programming language

### Installing

* Download zip file from this link: https://github.com/KamaanRichards/bulk-text-translator/archive/refs/heads/main.zip --> Extract All
* I recommend creating "input" and "output" folders in the main folder (where you see the main.R file) to help manage your translation work

### Executing program

* Double-click the main.R file (if necessary, choose R Front End to run it)
* Select the csv file you want to import using the filepicker popup
* Select the folder where you want to save the translated output data in the directory picker popup

## Help

The tool currently only supports import from csv files, with standard input column names. Will add support for xlsx files/tables, and enable interactive column selection in later release

## Authors

* Kamaan Richards  

## Version History

* 0.1
    * Initial Release

## License

* TK

## Acknowledgments

* TK
