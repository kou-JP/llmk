![llmk: The Light LaTeX Make](./llmk-logo.png)

[![CI](https://github.com/wtsnjp/llmk/actions/workflows/ci.yml/badge.svg)](https://github.com/wtsnjp/llmk/actions/workflows/ci.yml)
[![CTAN](https://img.shields.io/ctan/v/light-latex-make?color=FC02FF&label=CTAN)](https://www.ctan.org/pkg/light-latex-make)

This is yet another build tool for LaTeX documents. The features of **llmk** are:

* it works solely with texlua,
* using TOML to declare the settings,
* no complicated nesting of configuration, and
* modern default settings (make LuaTeX de facto standard!)

See the bundled reference manual ([llmk.pdf](http://mirrors.ctan.org/support/light-latex-make/llmk.pdf)) for the full specification of the program. The following sections are for a quick guidance.

## Installation

This software is included in [TeX Live](https://www.tug.org/texlive/) and [MiKTeX](https://miktex.org/) as Package `light-latex-make`. If you are using one of the latest distributions, you normally don't need to install it by yourself (for TeX Live, please use the `tlmgr` command to install it, if the package is missing).

In case the package is not installed in your TeX system or you want to use the latest (development) version of the program, you have to install it manually. You can acquire any material related to this software from [our GitHub repository](https://github.com/wtsnjp/llmk). The installation procedure is very simple anyway because the `llmk.lua` is the standalone executable. Running `texlua <path>/llmk.lua` should work in any case. In UNIX-like systems, the easiest way to install the program is copy or symlink the file `llmk.lua` as `llmk` in any place in the `PATH`.

## Basic Usage

The most simple way to use **llmk** is to write the build settings into the LaTeX document itself. The settings can be written as [TOML](https://toml.io) format in comments of a source file, and those have to be placed between the comment lines only with the consecutive `+` characters (at least three).

Here's a very simple example:

```latex
% hello.tex

% +++
% latex = "xelatex"
% +++

\documentclass{article}
\begin{document}

Hello \textsf{llmk}!

\end{document}
```

Suppose we save this file as `hello.tex`, then run

```shell
llmk hello.tex
```

will produce a PDF document (`hello.pdf`) with XeLaTeX, since it is specified in the TOML line of the source.

You can find other example LaTeX document files in the [examples](https://github.com/wtsnjp/llmk/tree/master/examples) directory.

### Using llmk.toml

Alternatively, you can write your build settings in an independent file named `llmk.toml` (this file name is fixed).

```toml
# llmk.toml

latex = "lualatex"
source = "hello.tex"
```

If you run llmk without any argument, llmk will load `llmk.toml` in the working directory, and compile files specified by the `source` key with the settings written in the file.

```shell
llmk
```

### Supports for other magic comment formats

A few other magic comment formats that are supported by existing tools are also supported by llmk.

The directives supported by [TeXShop](https://pages.uoregon.edu/koch/texshop/) and friends, which typically start with `% !TEX`, can be used instead of `latex` and `bibtex` keys. E.g.,

```latex
%! TEX TS-program = xelatex
%! BIB TS-program = biber
\documentclass{article}
```

is equivalent to:

```latex
% +++
% latex = "xelatex"
% bibtex = "biber"
% +++
\documentclass{article}
```

Another supported format is shebang-like directive that is supported by [YaTeX mode for Emacs](https://www.yatex.org/). E.g.,

```latex
%#!pdflatex
\documentclass{article}
```

is equivalent to:

```latex
% +++
% latex = "pdflatex"
% +++
\documentclass{article}
```

Note that this magic comment is effective **only on the first line** of a LaTeX source file. Note also that if a TOML field exist in the file, the TOML field has higher priority and all the other magic comments will be ignored.

### Action Clean/Clobber

Similar to [latexmk](http://personal.psu.edu/jcc8/software/latexmk/), Actions `--clean` (`-c`) and `--clobber` (`-C`) are available.

* The `--clean` action removes temporary files such as `*.aux` and `*.log`.
* The `--clobber` action removes all generated files including final PDFs.

Specifically,

```shell
llmk --clean FILE...
```

removes files generated by the specified `FILE`s. In case you omit the argument `FILE`, files generated by the `source` files are removed. In both cases, the files to remove by these actions can be customized (see the reference manual for the details).

## Advanced Usage

### Custom compile sequence

You can setup custom sequence for processing LaTeX documents; use `sequence` key to specify the order of programs to process the documents and specify the detailed settings for each program in the `programs` table.

For the simple use, you can specify the command name in the top-level just like `latex = "lualatex"`, which is already shown in the former examples.

However, it is impossible to specify more detailed settings (e.g., command-line options) with this simple manner. If you want to change those settings as well, you have to use tables of TOML; write `[programs.<name>]` and then write the each setting following to that:

```toml
# custom sequence
sequence = ["latex", "bibtex", "latex", "dvipdf"]

# quick settings
dvipdf = "dvipdfmx"

# detailed settings for each program
[programs.latex]
command = "uplatex"
opts = ["-halt-on-error"]
args = ["%T"]

[programs.bibtex]
command = "biber"
args = ["%B"]
```

In the `args` keys in each program, some format specifiers are available. Those specifiers will be replaced to appropriate strings before executing the programs:

* `%S`: the file name given to llmk as an argument (source)
* `%T`: the target for each program
* `%o`: the output directory, or `.` if none was specified
* `%b`: the base name of `%S`
* `%B`: the output directory concatenated with the base name of `%S`

This way is a bit complicated but strong enough allowing you to use any kind of outer programs.

### Available TOML keys

The following is the list of available TOML keys in llmk. See the reference manual for the details.

* `bibtex` (type: *string*, default: `"bibtex"`)
* `clean_files` (type: *string* or *array of strings*, default: `["%B.aux", "%B.bbl", "%B.bcf", "%B-blx.bib", "%B.blg", "%B.fls", "%B.idx", "%B.ilg", "%B.ind", "%B.log", "%B.nav", "%B.out", "%B.run.xml", "%B.snm", "%B.toc", "%B.vrb"]`)
* `clobber_files` (type: *string* or *array of strings*, default: `["%B.pdf", "%B.dvi", "%B.ps", "%B.synctex.gz"]`)
* `dvipdf` (type: *string*, default: `"dvipdfmx"`)
* `dvips` (type: *string*, default: `"dvips"`)
* `extra_clean_files` (type: *string* or *array of strings*, default: `[]`)
* `latex` (type: *string*, default: `"lualatex"`)
* `llmk_version` (type: *string*)
* `makeindex` (type: *string*, default: `"makeindex"`)
* `makeglossaries` (type: *string*, default: `"makeglossaries"`)
* `max_repeat` (type: *integer*, default: `5`)
* `output_directory` (type: *string*)
* `programs` (type: *table*)
	* \<program name\>
		* `args` (type: *string* or *array of strings*, default: `["%T"]`)
		* `aux_file` (type: *string*)
		* `aux_empty_size` (type: *integer*)
		* `command` (type: *string*, **required**)
		* `generated_target` (type: *boolean*, default: `false`)
		* `opts` (type: *string* or *array of strings*)
		* `postprocess` (type: *string*)
		* `target` (type: *string*, default: `"%S"`)
* `ps2pdf` (type: *string*, default: `"ps2pdf"`)
* `sequence` (type: *array of strings*, default: `["latex", "bibtex", "makeindex", "makeglossaries", "dvipdf"]`)
* `source` (type: *string* or *array of strings*, only for `llmk.toml`)

### Default `programs` table

The following is the default values in the `programs` table in TOML format.

```toml
[programs.bibtex]
command = "bibtex"
target = "%B.bib"
args = ["%B"]
postprocess = "latex"

[programs.dvipdf]
command = "dvipdfmx"
target = "%B.dvi"
generated_target = true

[programs.dvips]
command = "dvips"
target = "%B.dvi"
generated_target = true

[programs.latex]
command = "lualatex"
opts = ["-interaction=nonstopmode", "-file-line-error", "-synctex=1", '-output-directory="%o"']
aux_file = "%B.aux"
aux_empty_size = 9

[programs.makeindex]
command = "makeindex"
target = "%B.idx"
generated_target = true
postprocess = "latex"

[programs.makeglossaries]
command = "makeglossaries"
target = "%B.glo"
generated_target = true
postprocess = "latex"
opts = ['-d "%o"']
args = ["%b.glo"]

[programs.ps2pdf]
command = "ps2pdf"
target = "%B.ps"
generated_target = true
```

## Building and testing

Some maintenance tasks are defined as [Rake](https://github.com/ruby/rake) tasks. To run these tasks, please install the dependencies first:

```shell
bundle install
```

### Generating all documentation

The following will generate both the PDF and the manpage in `doc/` directory.

```shell
rake doc
```

### Running tests

The following will run all tests in `spec/` directory.

```shell
rake test
```

Alternatively, you can give spec names with the `--list` (`-l`) option for this task. E.g., following will run only `spec/help_spec.rb` and `spec/version_spec.rb`:

```shell
rake test -- -l help,version
```

### Showing all available tasks

Following will show all available tasks with a short description.

```shell
rake -T
```

In addition to that, for options available tasks, e.g., `rake test`, you can get options information with `-h` option for each task:

```shell
rake test -- -h
```

## Links to other materials

* [Reference manual](http://mirrors.ctan.org/support/light-latex-make/llmk.pdf): it describes the full specification.
* [Talk in TUG 2020](https://www.youtube.com/watch?v=kzqlNHKmzBo): the author talked about the design concept with a demonstration.
* [TUGboat article](https://www.tug.org/TUGboat/tb41-2/tb128asakura-llmk.pdf): the post-proceedings of the above talk.

## Acknowledgements

This project has been supported by the [TeX Development Fund](https://www.tug.org/tc/devfund/) created by the TeX Users Group (No. 29). I would like to thank all contributors and the people who gave me advice and suggestions for new features for the llmk project.

## License

Copyright 2018-2025 Takuto Asakura ([wtsnjp](https://twitter.com/wtsnjp))

This software is licensed under [the MIT license](./LICENSE).

### Third-party software

* [toml.lua](https://github.com/jonstoler/lua-toml): Copyright 2017 Jonathan Stoler. Licensed under [the MIT license](https://github.com/jonstoler/lua-toml/blob/master/LICENSE).

---

Takuto Asakura ([wtsnjp](https://twitter.com/wtsnjp))
