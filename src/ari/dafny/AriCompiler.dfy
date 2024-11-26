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

  /**
  Compiles a statement into a program.

  Takes a statement and compiles it by applying rules:
    - `Skip` compiles to an a program with no instructions.
    - `Assign(v, e)` compiles to `PopVar(v)` followed by the compilation of `e`.
    - `Print(e)` compiles to `PopPrint` followed by the compilation of `e`.
    - `Seq(s1, s2)` compiles to the concatenation of the compilation of `s2` and `s1`.
      - Note: The order of concatenation is reversed to preserve the order of execution, as the stack machine is "last in, first out" (LIFO). `s1` is compiled first, followed by `s2`.
  */
  function compileStmt(s: Stmt): Program {
    match s {
      case Skip => Nil
      case Assign(v, e) => Cons(PopVar(v), compileExpr(e))
      case Print(e) => Cons(PopPrint, compileExpr(e))
      case Seq(s1, s2) => Concat(compileStmt(s2), compileStmt(s1))
    }
  }

  /**
  Lemma to prove that the compilation of a concatenation of two programs is equivalent to the compilation of the first program followed by the compilation of the second program.

  Preconditions:
    - None.

  Postconditions:
    - For all programs `p1` and `p2`, and all states `st`, the result of interpreting the concatenation of `p1` and `p2` in state `st` is the same as the result of interpreting `p1` in the resulting state (from interpreting `p2` in `st`).

  Takes two programs and a state, and automatically proves that the postconditions hold.
  */
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