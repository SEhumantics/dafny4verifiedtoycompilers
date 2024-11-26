# Ari - A simple "Ari"thmetic language

## Introduction

Ari is a simple language that supports arithmetic expressions and variable assignment. It is a toy language (based on [a Dafny's official example](https://github.com/dafny-lang/dafny/tree/master/Source/IntegrationTests/TestFiles/LitTests/LitTest/examples/Simple_compiler)) that is used to demonstrate how to build a simple _formally verified_ compiler using ANTLR 4, Python, and Dafny.

First, we will define the syntax of Ari using ANTLR 4. We will then get a "base" components like lexer and parser generated to Python.
Next, we will implement semantic analysis in Dafny. We then generate Python code from the Dafny code to use it with the generated Python code from the previous step.
Finally, more Python code will be added to be used with the previously generated code. The compiler should now be finished.

The full documentation that explains how the code works will be provided in the `_docs` directory.

## Grammar

```antlr
grammar Ari;

options {
 language = Python3;
}

prog: (s += stmt ';')*;

stmt:
 'print' '(' e = expr ')'      # Print
 | 'set' v = VAR ':=' e = expr # Assign;

expr:
 n = INT                   # Const
 | v = VAR                 # Var
 | e1 = expr '+' e2 = expr # Add
 | e1 = expr '-' e2 = expr # Sub;

VAR: [a-z]+;
INT: [0-9]+;
WS: [ \t\n\r]+ -> skip;
```

See the [grammar documentation](./_docs/grammar.md) for more details.

## Verification

### Lexer and Parser

```txt
TL;DR: No verification since ANTLR 4 is used (trust the industry standard tool).
```

See the [verification of the lexer and parser documentation](./_docs/verification_lexer_parser.md) for more details.

### Semantic Analysis

```txt
These components are defined (and verified) using Dafny.

- AST (nodes and interpretation functions).
- Rewrite rules.
- Compiler-related data structures (i.e., linked list, stack machine, ect.) and their operations (i.e., concatenate list, push/pop instructions into/from the stack, ect.).

TODO: Add more details.

```

See the [verification of the semantic analysis documentation](./_docs/verification_semantic_analysis.md) for more details.
