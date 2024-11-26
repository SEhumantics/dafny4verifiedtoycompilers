# Grammar for the Ari language

----

## Grammar

Here is the ANTLR grammar for Ari:

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

The grammar defines a simple language with two statements: `print` and `set`. The `print` statement takes an expression and prints its value. The `set` statement assigns an expression to a variable. An expression can be an integer constant, a variable, or an addition or subtraction of two expressions.

The lexer rules are also simple. `VAR` (for variable) is a sequence of lowercase letters. `INT` (for integer) is a sequence of digits. `WS` (for whitespace) is a sequence of spaces, tabs, and newlines.

----

## Navigation

- [Back to the README](../README.md)
- [Next: Verification of the Lexer and Parser](verification_lexer_parser.md)