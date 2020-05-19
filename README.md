# axis-ascon
An AXI-Stream Ascon core configured over AXI-Lite

AXI-Lite register layout:

```
+-------+----+---------+
|Name   |Mode|Range    |
+=======+====+---------+
|Key    | rw |0x00-0x0f|
|Nonce  | rw |0x10-0x1f|
|Mode   | rw |0x20     |
|Status | r- |0x24     |
+-------+----+---------+
```

 * Key: The 128-bit key of ASCON-128
 * Nonce: The 128-bit nonce of ASCON-128

Mode register detail:

```
+----------------------+-----+-----+
|     Unused           | AD? | E/D |
+----------------------+-----+-----+
^                      ^     ^
|                      |     |
31                     1     0
```

 * AD?: 1 if associated data is included, 0 otherwise
 * E/D: 1 if decryption is happening, 0 if encryption is happening

Status register detail:

```
+----------------+--------+--------+
|     Unused     | State  | Valid  |
+----------------+--------+--------+
^                ^        ^
|                |        |
31               15       7
```

 * State:
   * Idle = 0
   * Initialization = 1
   * Associated data = 2
   * Plaintext/Ciphertext = 3
   * Finalization = 4
 * Valid: 0 if decryption was valid and 1 if it was invalid
