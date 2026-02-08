# Cairo first artifact: Adventurer core codec

## Why this first

- Deterministic and testable: pure pack/unpack logic, no RPC dependency.
- Directly useful for MCP integration: converts LS2 packed felt state into structured fields.
- Reduces risk for later tooling: shared canonical decoding avoids inconsistent parsing in TS and analytics.

## Implemented

Path: `cairo/src/lib.cairo`

- `AdventurerCore` compact struct
- `unpack_adventurer_core(felt252) -> AdventurerCore`
- `pack_adventurer_core(AdventurerCore) -> felt252`
- Bit layout and constants aligned to LS2 `death-mountain` implementation

## Tests

- roundtrip pack/unpack
- zero-state unpack behavior

Run:

```bash
cd cairo
scarb test
```

## Next Cairo increments

1) Add overflow/bounds guard helper for valid LS2 ranges
2) Add bag codec (`packed_bag` decode)
3) Export test vectors for TS parity tests
