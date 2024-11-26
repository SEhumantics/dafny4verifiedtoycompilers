# Verification of the Semantic Analysis phase - Part 2. Defining the compiler and related data structures

----

## Table of Contents

- [Verification of the Semantic Analysis phase - Part 2. Defining the compiler and related data structures](#verification-of-the-semantic-analysis-phase---part-2-defining-the-compiler-and-related-data-structures)
  - [Table of Contents](#table-of-contents)
  - [Compiler-related data structures](#compiler-related-data-structures)
    - [`AriCompilerDSLinkedList`](#aricompilerdslinkedlist)
    - [`AriCompilerDSStackMachine`](#aricompilerdsstackmachine)
      - [Data structures](#data-structures)
      - [Interpretation functions](#interpretation-functions)
  - [Navigation](#navigation)

----

## Compiler-related data structures

In this section, we define the data structures that are used by the compiler of the Ari language (which are stored in the `ari\CompilerDS.dfy` file). An Ari program is basically a stack machine, where the statements are executed in a stack-based manner.
First, we define a linked list data structure (`AriCompilerDSLinkedList`) that will be used to represent the stack.
Then, we define the data structure that represents the stack machine (`AriCompilerDSStackMachine`), which contains the relevant data structures for the stack machine and their operations.

----

### `AriCompilerDSLinkedList`

The `AriCompilerDSLinkedList` data structure is defined as follows:

```ocaml
datatype List<T> =
    Nil
  | Cons(head: T, tail: List<T>)

function Concat<T>(l1: List<T>, l2: List<T>) : List<T>
{
  match l1 {
    case Nil => l2
    case Cons(head, tail) => Cons(head, Concat<T>(tail, l2))
  }
}
```

The `List<T>` datatype is a simple linked list data structure, which consist of two constructors: `Nil` and `Cons`. The `Nil` constructor represents an empty list, while the `Cons` constructor represents a list with a head element (`head`) and a tail list (`tail`, contains the remaining elements beside `head`). The parameter `T` is the type of the elements in the list, to support generic lists.

Some examples of `List<T>` are:

- `Nil` - an empty list (`Null`).
  - This is the "base case" of the linked list data structure.
- `Cons(1, Nil)` - a list with one element (`1 -> Null`).
  - The `1` is the head element, and `Nil` is the tail list (empty list).
- `Cons(1, Cons(2, Nil))` - a list with two elements (`1 -> 2 -> Null`).
  - The `1` is the head element, and `Cons(2, Nil)` is the tail list. In the tail list, `2` is the head element, and `Nil` is the tail list (empty list).
- `Cons(1, Cons(2, Cons(3, Nil)))` - a list with three elements (`1 -> 2 -> 3 -> Null`).
  - Similar to the previous example, but with three elements. First, `1` is the head element, and `Cons(2, Cons(3, Nil))` is the tail list. In the tail list, `2` is the head element, and `Cons(3, Nil)` is the tail list. In the second tail list, `3` is the head element, and `Nil` is the tail list (empty list).

The linked list also has a `Concat` function that concatenates two lists. The `Concat` function takes two lists (`l1` and `l2`) and returns a new list that contains all the elements of `l1` followed by all the elements of `l2`. The function is also parameterized by the type `T` of the elements in the list.

- If `l1` is an empty list (`Nil`), then the result is `l2` (since the concatenation of an empty list with any list `l` is the list `l` itself).
- If `l1` is a non-empty list (`Cons(head, tail)`), then the result is a new list with `head` as the head element and the concatenation of `tail` and `l2` as the tail list.

----

### `AriCompilerDSStackMachine`

#### Data structures

The `AriCompilerDSStackMachine` data structure is defined as follows:

```ocaml
datatype Instr =
  | PushConst(n: int)
  | PushVar(v: string)
  | PopAdd
  | PopSub
  | PopPrint
  | PopVar(v: string)

type Program = List<Instr>
```

The `Instr` datatype represents the instructions of the stack machine. The instructions are:

- Push instructions:
  - `PushConst(n: int)` - push a constant integer `n` onto the stack.
  - `PushVar(v: string)` - push the value of the register `v` onto the stack.
- Pop instructions:
  - `PopAdd` - pop two values from the stack, add them, and push the result back onto the stack.
  - `PopSub` - pop two values from the stack, subtract them, and push the result back onto the stack.
  - `PopPrint` - pop a value from the stack and print it.
  - `PopVar(v: string)` - pop a value from the stack and store it in the register `v`.

As mentioned earlier, an Ari program is basically a stack machine (based on a linked list of instructions). The `Program` type is a list of instructions (`List<Instr>`), which represents the program to be executed by the stack machine.

The concept of a "register" is also mentioned, which will be introduced right here, along with the "state" concept:

```ocaml
type RegisterFile = map<string, int>

datatype State =
  State(stack: List<int>, regs: RegisterFile, output: seq<int>)
```

The `RegisterFile` type is a map that maps register names (strings) to integer values. It represents the register file of the stack machine, where the values of the registers are stored.

The `State` datatype represents the state of the stack machine at a given point in time. It consists of three components:

- `stack` - the stack of the stack machine, which is a list of integers.
- `regs` - the register file of the stack machine, which is a map that maps register names to integer values.
- `output` - the output of the stack machine, which is a sequence of integers that have been printed by the `PopPrint` instruction.
  - Reminder: `output: seq<int>` is also introduced in the `InterpResult` datatype (see [the part on the interpretation functions for statements](verification_semantic_analysis_pt1#interpretation-functions)).

#### Interpretation functions

The interpretation functions for the instructions of the stack machine are defined as follows:

```ocaml
function interpInstr(instr: Instr, st: State) : State {
  match (instr, st.stack) {
    case (PushConst(n), stack) =>
      st.(stack := Cons(n, stack))
    case (PushVar(v), stack) =>
      var val := if v in st.regs.Keys then st.regs[v] else 0;
      st.(stack := Cons(val, stack))

    case (PopAdd, Cons(n2, Cons(n1, restOfStack))) =>
      st.(stack := Cons(n1 + n2, restOfStack))
    case (PopSub, Cons(n2, Cons(n1, restOfStack))) =>
      st.(stack := Cons(n1 - n2, restOfStack))
    case (PopPrint, Cons(n, restOfStack)) =>
      st.(stack := restOfStack, output := st.output + [n])
    case (PopVar(v), Cons(n, restOfStack)) =>
      st.(stack := restOfStack, regs := st.regs[v := n])

    case (PopAdd, _) => st
    case (PopSub, _) => st
    case (PopPrint, _) => st
    case (PopVar, _) => st
  }
}
```

The `interpInstr` function takes an instruction (`instr`) and the current state of the stack machine (`st`) and returns the new state of the stack machine after executing the instruction. The result comes from pattern matching on the instruction and the stack of the state:

- For the "push" instructions:
  - `PushConst(n)` - push the constant integer `n` onto the stack.
    - The new state's stack is the old stack with `n` pushed onto it.
  - `PushVar(v)` - push the value of the register `v` onto the stack.
    - The new state's stack is the old stack with the value of the register `v` (or `0` if `v` is not in the state's register file) pushed onto it.
- For the "pop" instructions:
  - `PopAdd` - pop two values from the stack, add them, and push the result back onto the stack.
    - The new state's stack is the old stack with the result of adding the two popped values pushed onto it.
  - `PopSub` - pop two values from the stack, subtract them, and push the result back onto the stack.
    - The new state's stack is the old stack with the result of subtracting the two popped values pushed onto it.
  - `PopPrint` - pop a value from the stack and print it.
    - The new state's stack is the old stack with the popped value removed, and the output is the old output with the popped value appended to it.
  - `PopVar(v)` - pop a value from the stack and store it in the register `v`.
    - The new state's stack is the old stack with the popped value removed, and the register file is the old register file with the value of `v` set to the popped value.

As some of the instructions are not valid for certain stack states (e.g., popping from an empty stack), the function returns the old state in those cases.

- `PopAdd` and `PopSub` require at least two elements on the stack.
- `PopPrint` and `PopVar` require at least one element on the stack.

The interpretation function for programs (a `Program` is a `List<Instr>`) is defined as follows:

```ocaml
function interpProg'(p: Program, st: State) : State {
  match p {
    case Nil => st
    case Cons(instr, restOfProg) =>
      interpInstr(instr, interpProg'(restOfProg, st))
  }
}
```

The `interpProg'` function takes a program (`p`) and the current state of the stack machine (`st`) and returns the new state of the stack machine after executing the program. The result comes from pattern matching on the program:

- If the program is empty (`Nil`), the result is the current state.
- If the program is a non-empty list (`Cons(instr, restOfProg)`), the result is the new state after executing the instruction `instr` and the rest of the program `restOfProg`.
  - For context, a non-empty program is a non-empty list of instructions, where the first instruction is `instr`, followed by the rest of the program `restOfProg`.
  - The function `interpProg'` in this case returns an execution of the "first" instruction `instr` mentioned above, using the `interpInstr(instr: Instr, st: State)` function. The first parameter of `interpInstr` is the current instruction `instr`, and the second parameter is the result of the recursive call to `interpProg'` with the rest of the program `restOfProg` and the current state `st` (which returns a new state for each instruction interpretation).

There is also the function `interpProg`, which is a wrapper around `interpProg'` for a program `p` and an empty state (with a given input register file `input`). Note that the `EmptyState` is defined as a state with an empty stack of integers (`stack: List<int>`), an empty register file (`regs: RegisterFile`), and an empty output sequence of integers (`output: seq<int>`). The `interpProg` function is defined as follows:

```ocaml
const EmptyState := State(Nil, map[], [])

function interpProg(p: Program, input: RegisterFile) : seq<int> {
  interpProg'(p, EmptyState.(regs := input)).output
}
```

The `interpProg` function takes a program (`p`) and an input register file (`input`) and returns the output sequence of integers produced by executing the program with the given input. The result comes from calling `interpProg'` with the program `p` and an empty state with the input register file `input`, and then extracting the output sequence from the resulting state.

----

## Navigation

- [Back to the README](../README.md)
- [Prev: Verification of the Semantic Analysis phase - Part 1. Defining the AST and rewrite rules](verification_semantic_analysis.md)
- [Next: TODO](todo.md)
