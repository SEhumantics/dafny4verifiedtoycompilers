/**
This modules defines the base types for the Ari language.

Currently, only the `nativeint` type is defined.
*/
module NativeTypes {
  /**
  The native integer type: a 32-bit signed integer.

  Ranging from `-0x8000_0000` to `0x7FFF_FFFF`, inclusive (equivalent to `[-2_147_483_648 ; 2_147_483_647]`).
  */
  newtype nativeint = n: int | -0x8000_0000 <= n < 0x8000_0000
}

