/**
This module defines concepts for the AST of the Ari language.

AST nodes and relevant semantics are defined in this module.
*/
module AriAST {

  /**
  The binary operators supported by the language.

  Possible values: 
    - `Add` for addition.
    - `Sub` for subtraction.
  */
  datatype BinOp =
      Add
    | Sub

  /**
  The expression nodes of the AST.

  Possible values:
    - `Const` for integer constants.
    - `Var` for variable references.
    - `Op` for binary operations.
  */
  datatype Expr =
    | Const(n: int)
    | Var(v: string)
    | Op(op: BinOp, e1: Expr, e2: Expr)

  /**
  The statement nodes of the AST.

  Possible values:
    - `Skip` for empty statements.
    - `Print` for printing an expression.
    - `Assign` for assigning a value to a variable.
    - `Seq` for sequencing two statements (to incrementally build a program).
  */
  datatype Stmt =
    | Skip
    | Print(e: Expr)
    | Assign(v: string, e: Expr)
    | Seq(s1: Stmt, s2: Stmt)

  /**
  The context type for the interpreter.

  Purpose:
    - Is a mapping from variable names to integer values.
  */
  type Context = map<string, int>

  /**
  Interprets an expression in a given context.

  The expression is evaluated in the given context, where:
    - `Const(n)` evaluates to `n`.
    - `Var(v)` evaluates to the value of `v` in the context, or `0` if `v` is not in the context.
    - `Op(op, e1, e2)` evaluates to the result of applying the binary operator `op` to the results
      of evaluating `e1` and `e2`.
  */
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

  /**
  The result of interpreting a statement.

  Contains:
    - The resulting context.
    - The output of the statement (as a sequence of integers).
  */
  datatype InterpResult = InterpResult(ctx: Context, output: seq<int>)

  /**
  Interprets a statement in a given context.

  Performs pattern matching on the statement:
    - `Skip` results in no change to the context and an empty output.
    - `Print(e)` results in the evaluation of `e` in the context and the result as the output.
    - `Assign(v, e)` results in the evaluation of `e` in the context and the value assigned to `v`.
    - `Seq(s1, s2)` results in the interpretation of `s1` in the context, followed by the interpretation
      of `s2` in the resulting context.
  */
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

  /**
  Interprets a statement in a given context.

  Returns the output of the statement.
  
  - Note: This function is a wrapper around `interpStmt'` that only returns the output.
  */
  function interpStmt(s: Stmt, ctx: Context) : seq<int> {
    interpStmt'(s, ctx).output
  }
}