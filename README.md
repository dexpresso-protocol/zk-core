# zk-core

The repository contains circuits and building blocks of ZK version of the Dexpresso platform.

## Structure
The `ceremony` dicrectory contains phase one powers of Tao.  
All circuits are implemented separately inside `circuits` directory.
Each circuit contais following sub-folders:
- `ceremony`: includes phase two powers of Tao. this is necessary for _groth16_ based SNARKs.
- `inputs`: contains json files for example bad and good inputs for the circuit.
- `proofs`: example proofs generated with inputs from the `inputs` directory.
