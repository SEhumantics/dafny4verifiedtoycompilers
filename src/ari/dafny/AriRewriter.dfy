/**
This module defines a rewrite system for the Ari language.

The rewrite system is used to simplify Ari programs (i.e., remove redundant operations).
*/

/// Import the AST module (file).
include "AriAST.dfy"

module AriRewriter {
  /// Import the AST module.
  import opened AriAST

  /**
  Simplifies an expression.

  Preconditions:
    - None.

  Postconditions:
    - For all contexts `ctx`, the result of interpreting the simplified expression is the same as the
    result of interpreting the original expression.

  Takes an expression and simplifies it by applying rules:
    - `Const(n)` is unchanged.
    - `Var(v)` is unchanged.
    - `Op(op, e1, e2)` is simplified as follows (where `e1'` and `e2'` are the simplified versions of `e1` and `e2`):
        - If both `e1'` and `e2'` are `Const(0)`, the result is `Const(0)`.
        - If `op` is `Add` and `e1'` is `Const(0)`, the result is `e2'`.
        - If `e2'` is `Const(0)`, the result is `e1'`.
        - Otherwise, the result is `Op(op, e1', e2')`.
  */
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

  /**
  Simplifies a statement.

  Preconditions:
  - None.

  Postconditions:
  - For all contexts `ctx`, the result of interpreting the simplified statement is the same as the
    result of interpreting the original statement.

  Takes a statement and simplifies it by applying rules:
    - `Skip` is unchanged.
    - `Print(e)` is simplified by calling `Print(simplifyExpr(e))`.
    - `Assign(v, e)` is simplified by calling `Assign(v, simplifyExpr(e))`.
    - `Seq(s1, s2)` is simplified as follows (where `s1'` and `s2'` are the simplified versions of `s1` and `s2`):
        - If `s1'` is `Skip`, the result is `s2'`.
        - If `s2'` is `Skip`, the result is `s1'`.
        - Otherwise, the result is `Seq(s1', s2')`.
  */
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
}