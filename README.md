# Using Dafny for verifying "Toy" Compilers

## Tables of Contents

- [Using Dafny for verifying "Toy" Compilers](#using-dafny-for-verifying-toy-compilers)
  - [Tables of Contents](#tables-of-contents)
  - [TL;DR](#tldr)
  - [Development Environment](#development-environment)
    - [IDE](#ide)
    - [Programming Languages](#programming-languages)

## TL;DR

This project aims to build a few Python-based compilers for simple languages (Ari, Arisu, ArisuS), with formal verifications done using Dafny. 
The verified code will be generated as Python code (to be intergrated with the rest of the compilers).

The initial language (which we call Ari) is based on one of the examples officially [provided by Dafny.](https://github.com/dafny-lang/dafny/tree/master/Source/IntegrationTests/TestFiles/LitTests/LitTest/examples/Simple_compiler)

## Development Environment

### IDE

We used [VSCode](https://code.visualstudio.com/) as the main IDE for the development of the compiler. The [Python profile template](https://code.visualstudio.com/docs/editor/profiles#_python-profile-template) was used to set up the environment; then [ANTLR4 grammar syntax support](https://marketplace.visualstudio.com/items?itemName=mike-lischke.vscode-antlr4) and [Dafny](https://marketplace.visualstudio.com/items?itemName=dafny-lang.ide-vscode) extensions were installed.

AI-assisted coding was enabled using [Github Copilot](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot), and external use of AI tools like [ChatGPT](https://chatgpt.com/) was also used in the development.

- Note: You can do testing and drafting code by creating a `testzone` folder in the root directory, as `.gitignore` is set to ignore this folder.

For non-technical work:

- [Markdown extension pack](https://marketplace.visualstudio.com/items?itemName=walkme.Markdown-extension-pack) and [Github Markdown Preview](https://marketplace.visualstudio.com/items?itemName=bierner.github-markdown-preview) for writing the documentation.
  - Note: [Instant Markdown](https://marketplace.visualstudio.com/items?itemName=dbankier.vscode-instant-markdown) is removed since weird "pop out browser" behavior keeps happening.
  - Note: `ocaml` language annotation to `dafny` code blocks to enable syntax highlighting.
- [nyan-mode](https://marketplace.visualstudio.com/items?itemName=zakudriver.nyan-mode) for the cute and funny nyan cat progress bar.
- [Doki Theme](https://marketplace.visualstudio.com/items?itemName=unthrottled.doki-theme) for the cute and funny anime themes and backgrounds.

To reproduce the given environment, you can install the extensions yourself, or create a new VSCode profile based on the file `.vscode/DafnyDevEnv (With ANTLR 4 and Python 3).code-profile` in this repository.

### Programming Languages

- The Python 3.11 environment is managed using [uv](https://github.com/astral-sh/uv), with dependencies such as `antlr4-python3-runtime>=4.13.2` and `dafnyruntimepython>=4.9.0`. More information can be found in the `pyproject.toml` file.

- The generated Dafny code is expected to be Python 3.7 compatible (as of Dafny 4.9.0), while the Python environment is set to 3.11. Further compatibility checks will be done in the future, as for now, the generated code is still integrated with the Python codebase.
