# Lexical-analyzer

This project consists of a lexical analyzer designed to highlight the syntax of Python code, providing a visual environment that facilitates intuitive error detection. The main features and architecture of the project are described below.

## General Description

The lexical analyzer is responsible for identifying and highlighting the different elements of Python syntax, such as keywords, operators, literals, comments, and other language components. This allows users to clearly visualize the structure of the code and detect errors quickly.

## Technologies Used

**Core language:** Racket  
Racket is the programming language used to implement both the lexical analyzer engine and the graphical interface. The choice of Racket allows efficient text manipulation and facilitates the construction of a flexible graphical interface.

## Graphical Interface

The program's graphical interface is designed and rendered using Racket. Through this interface, users can upload Python code files for analysis. Once the file is loaded, the syntax is highlighted, and if errors are detected, they are displayed in a special section located at the bottom of the interface.

![Screenshot 1](https://github.com/Roodrrigoo/Lexical-analyzer/blob/main/imgs/resaltador%20captura1.png?raw=true)

## Key Features

### Syntax Coloring
The program identifies the different components of the Python syntax and colors them according to the rules of the language, making it easier to read and debug the code. Each type of element (keywords, variables, literals, etc.) has a distinctive color to visually differentiate them.

![Screenshot 2](https://github.com/Roodrrigoo/Lexical-analyzer/blob/main/imgs/resaltador%20captura2.png?raw=true)

### Lexical Error Detection
In the interface, a section dedicated to highlighting lexical errors found during the analysis is displayed. When the program detects an error in the code, it is pointed out precisely, indicating the line and type of error, helping the user correct it quickly.

### Python File Analysis
The program allows the user to load files written in Python (.py) for analysis. Once the file is loaded, the parser proceeds to check the syntax of the code and colors it in real time.

### Web Interface
To make the use of the parser more accessible, a graphical interface has been integrated that can be used from a web browser. This allows the program to be run remotely, through a web page created and managed by the program itself in Racket. The user can upload Python files through the web, viewing both the colored code and the detected errors directly in their browser.

![Screenshot 3](https://github.com/Roodrrigoo/Lexical-analyzer/blob/main/imgs/resaltador%20captura3.png?raw=true)

## How Does It Work?

1. **File Upload:** The user can upload a Python file through the graphical or web interface.
2. **Lexical Analysis:** The program scans the code, identifies keywords, operators, and other components of Python syntax, applying the appropriate coloring.
3. **Error Display:** If a lexical error is detected in the file, it is displayed at the bottom of the interface, specifying the exact location of the error and a brief description.
4. **Web Display:** The user also has the option to run the program from a web browser, providing a convenient alternative to use the lexical analyzer from any device.

## Project Objective

The goal of this project is to create a tool that allows Python programmers and students to improve their workflow by offering them a visual way to analyze and correct their code efficiently. By highlighting syntax and clearly displaying lexical errors, it aims to reduce debugging time and increase code comprehension.
