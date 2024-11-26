/**
This module defines a compiler for the Ari language.

The compiler translates Ari programs into stack machine programs.
*/

/// Import the AST module (file).
include "AriAST.dfy"
/// Import the compiler data structures modules (file).
include "AriCompilerDS.dfy"

module AriCompiler {
/// Import the AST module.
  import opened AriAST
/// Import the compiler data structures modules.
  import opened AriCompilerDSLinkedList
  import opened AriCompilerDSStackMachine

    /**
    Compiles an expression into a program.

    Takes an expression and compiles it by applying rules:
      - `Const(n)` compiles to `PushConst(n)` followed by no instructions.
      - `Var(v)` compiles to `PushVar(v)` followed by no instructions.
      - `Op(Add, e1, e2)` compiles to `PopAdd` followed by the concatenation of the compilation of `e2` and `e1`.
      - `Op(Sub, e1, e2)` compiles to `PopSub` followed by the concatenation of the compilation of `e2` and `e1`.
    */
  function compileExpr(e: Expr): Program {
    match e {
      case Const(n) => Cons(PushConst(n), Nil)
      case Var(v) => Cons(PushVar(v), Nil)
      case Op(Add, e1, e2) => Cons(PopAdd, Concat(compileExpr(e2), compileExpr(e1)))
      case Op(Sub, e1, e2) => Cons(PopSub, Concat(compileExpr(e2), compileExpr(e1)))
    }
  }

  function compileStmt(s: Stmt): Program {
    match s {
      case Skip => Nil
      case Assign(v, e) => Cons(PopVar(v), compileExpr(e))
      case Print(e) => Cons(PopPrint, compileExpr(e))
      case Seq(s1, s2) => Concat(compileStmt(s2), compileStmt(s1))
    }
  }

  lemma interpProg'_Concat(p1: Program, p2: Program, st: State)
    ensures interpProg'(Concat(p1, p2), st) ==
            interpProg'(p1, interpProg'(p2, st))
  {
  }

  lemma {:induction false} compileExprCorrect'(e: Expr, st: State) // FIXME default induction on e, st breaks things
    ensures interpProg'(compileExpr(e), st) ==
            st.(stack := Cons(interpExpr(e, st.regs), st.stack))
  {
    match e {
      case Const(n) =>
      case Var(v) =>
      case Op(op, e1, e2) => // Here's the expanded version of the same proof
        interpProg'_Concat(compileExpr(e2), compileExpr(e1), st);
        compileExprCorrect'(e1, st);
        var st' := st.(stack := Cons(interpExpr(e1, st.regs), st.stack));
        compileExprCorrect'(e2, st');
    }
  }

  lemma {:induction false} compileStmtCorrect'(s: Stmt, st: State)
    ensures interpProg'(compileStmt(s), st) ==
            var InterpResult(ctx', output) :=interpStmt'(s, st.regs);
            st.(regs := ctx', output := st.output + output)
  {
    match s {
      case Skip =>
      case Assign(v, e) =>
        compileExprCorrect'(e, st);
      case Print(e) =>
        compileExprCorrect'(e, st);
      case Seq(s1, s2) =>
        interpProg'_Concat(compileStmt(s2), compileStmt(s1), st);
        compileStmtCorrect'(s1, st);
        compileStmtCorrect'(s2, interpProg'(compileStmt(s1), st));
    }
  }

  lemma compileStmtCorrect(s: Stmt)
    ensures forall input: Context ::
              interpProg'(compileStmt(s), EmptyState.(regs := input)).output ==
              interpStmt'(s, input).output
  {
    forall input: Context {
      compileStmtCorrect'(s, EmptyState.(regs := input));
    }
  }

  lemma compileCorrect(s: Stmt)
    ensures forall input: Context ::
              interpProg(compileStmt(s), input) == interpStmt(s, input)
  {
    compileStmtCorrect(s);
  }
}