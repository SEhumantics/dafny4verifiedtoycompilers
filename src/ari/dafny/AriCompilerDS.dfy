/**
This module defines the linked list data structure for the compiler of the Ari language.

As the target language is a simple stack machine, the linked list is used to represent the stack.
*/
module AriCompilerDSLinkedList {
    /**
    The linked list data structure.

    A linked list is either:
      - `Nil` (empty list).
      - `Cons(head, tail)` (a node with a head element `head` and a tail list `tail`).
    
    The linked list is parameterized by the type of elements it contains (`T`).
    */
  datatype List<T> =
      Nil
    | Cons(head: T, tail: List<T>)

    /**
    Concatenates two linked lists.

    Takes two linked lists and concatenates them.
    */
  function Concat<T>(l1: List<T>, l2: List<T>) : List<T>
  {
    match l1 {
      case Nil => l2
      case Cons(head, tail) => Cons(head, Concat<T>(tail, l2))
    }
  }
}

/**
This module defines the stack machine for the compiler of the Ari language.

Relevant data structures and operations are defined in this module.
*/
module AriCompilerDSStackMachine {
  import opened AriCompilerDSLinkedList

  /**
  The stack machine instructions.
  
  An instruction is one of the following:
    - `PushConst(n)` pushes a constant integer `n` onto the stack.
    - `PushVar(v)` reads register `v` and pushes its value onto the stack.
    - `PopAdd` pops two values from the stack, adds them, and pushes the result back.
    - `PopSub` pops two values from the stack, subtracts them, and pushes the result back.
    - `PopPrint` pops a value from the stack and writes it to the output.
    - `PopVar(v)` pops a value from the stack and stores it in register `v`.
  */
  datatype Instr =
    | PushConst(n: int)
    | PushVar(v: string)
    | PopAdd
    | PopSub
    | PopPrint
    | PopVar(v: string)

  /**
  Programs are modeled as linked lists of instructions.
  */
  type Program = List<Instr>

  /**
  The context type for the stack machine (as a register file).

  Currently:
  - Is a mapping from variable names to integer values.
  */
  type RegisterFile = map<string, int>

  /**
  The stack machine state.

  Contains:
  - `stack`: the stack of the machine, represented as a linked list of integers.
  - `regs`: the register file of the machine.
  - `output`: the list of outputs (a sequence of integers), which holds the values printed by the machine.
  */
  datatype State =
    State(stack: List<int>, regs: RegisterFile, output: seq<int>)

  /**
  Interprets an instruction in the context of a stack machine state.

  The instruction is executed in the given state, updating the state accordingly.
    - `PushConst(n)` pushes the constant `n` onto the stack.
    - `PushVar(v)` reads the value of register `v` and pushes it onto the stack 
      (or `0` if `v` is not in the register file).
    - `PopAdd` pops two values from the stack, adds them, and pushes the result back.
    - `PopSub` pops two values from the stack, subtracts them, and pushes the result back.
    - `PopPrint` pops a value from the stack and writes it to the output.
    - `PopVar(v)` pops a value from the stack and stores it in register `v`.

  Invalid cases:
    - If `PopAdd`, `PopSub`, `PopPrint`, or `PopVar` is called with an invalid stack, the state is unchanged.
        - `PopAdd` and `PopSub` require at least two elements on the stack.
        - `PopPrint` and `PopVar` require at least one element on the stack.
  */
  function interpInstr(instr: Instr, st: State) : State {
    match (instr, st.stack) {
      //// Valid cases.
      ////// Push instructions.
      case (PushConst(n), stack) =>
        st.(stack := Cons(n, stack))
      case (PushVar(v), stack) =>
        var val := if v in st.regs.Keys then st.regs[v] else 0;
        st.(stack := Cons(val, stack))

      ////// Pop instructions.
      case (PopAdd, Cons(n2, Cons(n1, restOfStack))) =>
        st.(stack := Cons(n1 + n2, restOfStack))
      case (PopSub, Cons(n2, Cons(n1, restOfStack))) =>
        st.(stack := Cons(n1 - n2, restOfStack))
      case (PopPrint, Cons(n, restOfStack)) =>
        st.(stack := restOfStack, output := st.output + [n])
      case (PopVar(v), Cons(n, restOfStack)) =>
        st.(stack := restOfStack, regs := st.regs[v := n])

      //// Invalid cases.
      case (PopAdd, _) => st
      case (PopSub, _) => st
      case (PopPrint, _) => st
      case (PopVar, _) => st
    }
  }

  /**
  Interprets a program in the context of a stack machine state.

  The program is executed in the given state, updating the state accordingly.

  If the program is:
    - `Nil`, then does nothing.
    - `Cons(instr, restOfProg)`, then interprets the instruction `instr` and then the rest of the program `restOfProg`.
  */
  function interpProg'(p: Program, st: State) : State {
    match p {
      case Nil => st
      case Cons(instr, restOfProg) =>
        interpInstr(instr, interpProg'(restOfProg, st))
    }
  }

  /**
  The initial state of the stack machine.

  Contains:
    - An empty stack (linked list) of integers.
    - An empty register file (mapping from variable names to integer values).
    - An empty output (sequence of integers) which holds the values printed by the machine.
  */
  const EmptyState := State(Nil, map[], [])

  /**
  Interprets a program in the context of an initial stack machine state.

  Returns the output of the program (as a sequence of integers).

  - Note: This function is a wrapper around `interpProg'` that uses the initial state and certain `input` values for the registers.
  */
  function interpProg(p: Program, input: RegisterFile) : seq<int> {
    interpProg'(p, EmptyState.(regs := input)).output
  }
}