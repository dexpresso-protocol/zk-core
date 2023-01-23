# zk-core

The repository contains circuits and building blocks of ZK version of the Dexpresso platform.

## Structure
The `ceremony` dicrectory contains phase one powers of Tao.  
All circuits are implemented separately inside `circuits` directory.
Each circuit contais following sub-folders:
- `ceremony`: includes phase two powers of Tao. this is necessary for _groth16_ based SNARKs.
- `inputs`: contains json files for example bad and good inputs for the circuit.
- `proofs`: example proofs generated with inputs from the `inputs` directory.

## Helpful Commands List
### Compiling a circuit
`circom YOUR-CIRCUIT.circom --r1cs --wasm --sym --c`
### Building the witness
it is recommended to do it using the `cpp` version

`cd YOUR-CIRCUIT_cpp`

`make`

`./YOUR-CIRCUIT ../inputs/good_input.json ../proofs/good_witness.wtns`

### build powers of Tau for the circuit
This is only needed if we use `Groth16`, which we do.

`snarkjs groth16 setup ../YOUR-CIRCUIT.r1cs ../../../ceremony/pot19_final.ptau OUR-CIRCUIT_0000.zkey`

Now you should contribute to the zkey. Repeat this step as much as you have time (increase the numbers of the files):

`snarkjs zkey contribute YOUR-CIRCUIT_0000.zkey YOUR-CIRCUIT_0001.zkey --name="necro 1" -v`

Finally, it is time to export the final verification key

`snarkjs zkey export verificationkey YOUR-CIRCUIT_[LAST-NUMBER-IN-PREV-STEP].zkey verification_key.json`

Now the verification key is available in `verification_key.json` file.

### prooving
`snarkjs groth16 prove ../ceremony/YOUR-CIRCUIT_0001.zkey ../proofs/good_witness.wtns good_proof.json good_public.json`

### verifying
`snarkjs groth16 verify ../ceremony/verification_key.json good_public.json good_proof.json`

The output should be something like this

`[INFO]  snarkJS: OK!`