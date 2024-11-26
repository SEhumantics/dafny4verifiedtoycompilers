# Verification of the Semantic Analysis phase - Part 1. Defining the AST and rewrite rules

----

## Table of Contents

- [Verification of the Semantic Analysis phase - Part 1. Defining the AST and rewrite rules](#verification-of-the-semantic-analysis-phase---part-1-defining-the-ast-and-rewrite-rules)
  - [Table of Contents](#table-of-contents)
  - [Abstract Syntax Tree (AST)](#abstract-syntax-tree-ast)
    - [The `Expr` node](#the-expr-node)
    - [The `Stmt` node](#the-stmt-node)
    - [Interpretation functions](#interpretation-functions)
  - [Rewrite Rules](#rewrite-rules)
    - [The `simplifyExpr` function](#the-simplifyexpr-function)
    - [The `simplifyStmt` function](#the-simplifystmt-function)
  - [Navigation](#navigation)

----

## Abstract Syntax Tree (AST)

In this section, we define the components for the abstract syntax tree (AST) of the Ari language (which are stored in the `dafny\AriAST.dfy` file).
First, we define the kinds of nodes that can appear in the AST: `Expr` for expressions and `Stmt` for statements.
Then, we define interpretation functions that evaluate expressions and execute statements.

----

### The `Expr` node

The `Expr` datatype is defined as follows:

```ocaml
datatype BinOp = 
    Add 
  | Sub

datatype Expr =
  | Const(n: int)
  | Var(v: string)
  | Op(op: BinOp, e1: Expr, e2: Expr)
```

The `Expr` datatype represents arithmetic expressions. It has three constructors: `Const` for integer constants, `Var` for variables, and `Op` for binary operations. The `Op` constructor takes a binary operator (`Add` or `Sub` for addition or subtraction, respectively) and two subexpressions.

### The `Stmt` node

The `Stmt` datatype is defined as follows:

```ocaml
datatype Stmt =
  | Skip
  | Print(e: Expr)
  | Assign(v: string, e: Expr)
  | Seq(s1: Stmt, s2: Stmt)
```

The `Stmt` datatype represents statements in the Ari language. It has four constructors: `Skip` for the empty statement, `Print` for printing an expression, `Assign` for assigning an expression to a variable, and `Seq` for sequencing two statements.

_Sequencing_ means executing the first statement followed by the second statement.

----

### Interpretation functions

A context is defined as a mapping from variable names to integer values. The interpretation functions take a context and an expression or statement and return the value of the expression or the updated context after executing the statement.

The context is defined as a map of pairs of strings and integers:

```ocaml
type Context = map<string, int>
```

The interpretation function for expressions is defined as follows:

```ocaml
function interpExpr(e: Expr, ctx: Context): int {
  match e {
    case Const(n) => n
    case Var(v) => if v in ctx.Keys then ctx[v] else 0
    case Op(Add, e1, e2) =>
      interpExpr(e1, ctx) + interpExpr(e2, ctx)
    case Op(Sub, e1, e2) =>
      interpExpr(e1, ctx) - interpExpr(e2, ctx)
  }
}
```

The function `interpExpr` takes an expression `e` and a context `ctx` and returns the value of the expression in the context as an `int`. It uses pattern matching to handle the different cases of expressions:

- For a constant expression, it returns the integer value of the constant.
- For a variable expression, it looks up the value of the variable in the context and returns it.
  - If the variable is not in the context, it returns 0.
- For a binary operation expression, it recursively evaluates the subexpressions and applies the operator to the results.

The interpretation function for statements is defined as follows:

```ocaml
datatype InterpResult = InterpResult(ctx: Context, output: seq<int>)

function interpStmt'(s: Stmt, ctx: Context) : InterpResult
{
  match s {
    case Skip => InterpResult(ctx, [])
    case Print(e) => InterpResult(ctx, [interpExpr(e, ctx)])
    case Assign(v, e) => InterpResult(ctx[v := interpExpr(e, ctx)], [])
    case Seq(s1, s2) =>
      var InterpResult(ctx1, o1) := interpStmt'(s1, ctx);
      var InterpResult(ctx2, o2) := interpStmt'(s2, ctx1);
      InterpResult(ctx2, o1 + o2)
  }
}
```

A datatype `InterpResult` is defined to represent the result of interpreting a statement. It contains the updated context and a sequence of integers representing the output of the statement (the values printed by `Print` statements).

The function `interpStmt'` takes a statement `s` and a context `ctx` and returns an `InterpResult`. It uses pattern matching to handle the different cases of statements:

- For the empty statement `Skip`, it returns the context and an empty output sequence.
  - The context is unchanged, and the output sequence is empty.
- For the `Print` statement, it evaluates the expression and adds the result to the output sequence.
  - The context is also unchanged, and the output sequence contains the value of the printed expression (by calling the `interpExpr` function upon the expression).
  - The `[interpExpr(e, ctx)]` syntax creates a sequence containing the value of the expression `e` in the context `ctx` (by calling the `interpExpr` function).
- For the `Assign` statement, it evaluates the expression and updates the context with the new value of the variable.
  - The context is changed to include the new value of the variable, and the output sequence is empty.
  - The `ctx[v := interpExpr(e, ctx)]` syntax updates the context `ctx` with the new value of the variable `v`. If `v` is not in the context, it initializes it with the given value (by calling the `interpExpr` function).
- For the `Seq` statement, it recursively interprets the first statement, then interprets the second statement with the updated context from the first statement, and concatenates the output sequences.
  - First, an `InterpResult` is obtained by interpreting the first statement `s1` with the context `ctx`. The result is stored as `InterpResult(ctx1, o1)`, where `ctx1` is the updated context and `o1` is the output sequence of the first statement.
  - Then, an `InterpResult` is obtained by interpreting the second statement `s2` with the updated context `ctx1`. The result is stored as `InterpResult(ctx2, o2)`, where `ctx2` is the updated context and `o2` is the output sequence of the second statement.
  - Finally, an `InterpResult` is constructed with the updated context `ctx2` and the concatenated output sequences `o1 + o2`.

There is also the function `interpStmt`, which is a wrapper around `interpStmt'` that ignores the updated context and returns only the output sequence.

```ocaml
function interpStmt(s: Stmt, ctx: Context) : seq<int> {
  interpStmt'(s, ctx).output
}
```

----

## Rewrite Rules

In this section, we define the rewrite rules for the Ari language (which are stored in the `dafny\AriRewriter.dfy` file).
The rewrite rules are used to transform the AST of a program into an equivalent yet simpler form, which can be easier and optimal to reason about.

----

### The `simplifyExpr` function

```ocaml
function simplifyExpr(e: Expr) : Expr
    ensures forall ctx: Context ::
              AriAST.interpExpr(simplifyExpr(e), ctx) 
              == AriAST.interpExpr(e, ctx)
{
  match e {
    case Const(n) => e
    case Var(v) => e
    case Op(op, e1, e2) => 
      var e1' := simplifyExpr(e1);
      var e2' := simplifyExpr(e2);
      match Op(op, e1', e2') {
        case Op(_, Const(0), Const(0)) => Const(0)
        case Op(Add, Const(0), e2') => e2'
        case Op(_, e1', Const(0)) => e1'
        case _ => Op(op, e1', e2')
      }
  }
}
```

The function `simplifyExpr` takes an expression `e` and returns an equivalent yet simpler expression. It uses pattern matching to handle the different cases of expressions:

- For a constant expression, it returns the expression as is.
- For a variable expression, it returns the expression as is.
- For a binary operation expression, it recursively simplifies the subexpressions (from `e1` to `e1'`, and from `e2` to `e2'`) and applies rewrite rules to simplify the expression further.
  - Ignores the operator. If both subexpressions are constant zero, it returns a constant zero (since `0 + 0 = 0` and `0 - 0 = 0`).
  - If the operator is addition and the left subexpression is constant zero, it returns the right subexpression (since `0 + e = e`).
  - Ignores the operator. If the right subexpression is constant zero, it returns the left subexpression (since `e + 0 = e` and `e - 0 = e`).
  - Otherwise, it returns the original expression with the simplified subexpressions (since no further simplification is possible).

The `simplifyExpr` function is annotated with an `ensures` clause (postcondition) that states that the simplified expression has the same value (given by the function `interpExpr`) as the original expression for all contexts. This property is important for correctness, as the simplification should not change the meaning of the expression.

----

### The `simplifyStmt` function

```ocaml
function simplifyStmt(s: Stmt) : Stmt
    ensures forall ctx: Context ::
              AriAST.interpStmt'(simplifyStmt(s), ctx) 
              == AriAST.interpStmt'(s, ctx)
{
  match s {
    case Skip =>
      Skip
    case Print(e) =>
      Print(simplifyExpr(e))
    case Assign(v, e) =>
      Assign(v, simplifyExpr(e))
    case Seq(s1, s2) =>
      var s1' := simplifyStmt(s1);
      var s2' := simplifyStmt(s2);
      match (s1', s2') {
        case (s1', Skip) =>
          s1'
        case (Skip, s2') =>
          s2'
        case (s1', s2') => Seq(s1', s2')
      }
  }
}
```

The function `simplifyStmt` takes a statement `s` and returns an equivalent yet simpler statement. It uses pattern matching to handle the different cases of statements:

- For the empty statement `Skip`, it returns the statement as is.
- For the `Print` statement (of an expression `e`), it simplifies the expression and returns a new `Print` statement with the simplified expression.
- For the `Assign` statement (of a variable `v` and an expression `e`), it simplifies the expression and returns a new `Assign` statement with the simplified expression (and the same variable).
- For the `Seq` statement (of two statements `s1` and `s2`), it recursively simplifies the substatements (from `s1` to `s1'`, and from `s2` to `s2'`) and applies rewrite rules to simplify the statement further.
  - If the first substatement is the empty statement `Skip`, it returns the second substatement.
  - If the second substatement is the empty statement `Skip`, it returns the first substatement.
  - Otherwise, it returns the original statement with the simplified substatements.

The `simplifyStmt` function is annotated with an `ensures` clause (postcondition) that states that the simplified statement has the same output (given by the function `interpStmt'`) as the original statement for all contexts. This property is important for correctness, as the simplification should not change the behavior of the statement.

----

## Navigation

- [Back to the README](../README.md)
- [Prev: Verification of the Semantic Analysis phase](verification_semantic_analysis.md)
- [Next: Verification of the Semantic Analysis phase - Part 2. Defining the compiler and related data structures](verification_semantic_analysis_pt2.md)
