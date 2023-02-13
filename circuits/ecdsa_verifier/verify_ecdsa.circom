pragma circom 2.0.0;

include "../circom-ecdsa/circuits/vocdoni-keccak/keccak.circom";
include "../circom-ecdsa/node_modules/circomlib/circuits/bitify.circom";
include "../circom-ecdsa/circuits/ecdsa.circom";


/**
* This circuit is calculates the hash of the Dexpresso's orders
**/  

template VerifyEthECDSA () {  

  // Declaration of signals.  
  signal input FeeRatio;
  signal input OrderID;
  signal input ValidUntil;
  signal input ChainID;
  signal input RatioSellArg;
  signal input RatioBuyArg;
  signal input SellTokenAddress[160];
  signal input BuyTokenAddress[160];
  signal input r[4];
  signal input s[4];
  signal input pubkeyX[4];
  signal input pubkeyY[4];
  
  signal concatenatedValues[1040]; // size = 1040 = 16 + 3x64 + 2x256 + 2x160 
  // signal msghash[32];

  signal output verified;

  // Serialization and concatenation of inputs
  component maxFeeRatio_bits = Num2Bits(16);
  maxFeeRatio_bits.in <== FeeRatio;
  for (var i = 0; i < 16; i += 1) {
    concatenatedValues[0 + i] <== maxFeeRatio_bits.out[i];
  }
  
  component orderID_bits = Num2Bits(64);
  orderID_bits.in <== OrderID;
  for (var i = 0; i < 64; i += 1) {
    concatenatedValues[16 + i] <== orderID_bits.out[i];
  }
  
  component validUntil_bits = Num2Bits(64);
  validUntil_bits.in <== ValidUntil;
  for (var i = 0; i < 64; i += 1) {
    concatenatedValues[80 + i] <== validUntil_bits.out[i];
  }
  
  component chainID_bits = Num2Bits(64);
  chainID_bits.in <== ChainID;
  for (var i = 0; i < 64; i += 1) {
    concatenatedValues[144 + i] <== chainID_bits.out[i];
  }
  
  component ratioSellArg_bits = Num2Bits(256);
  ratioSellArg_bits.in <== RatioSellArg;
  for (var i = 0; i < 256; i += 1) {
    concatenatedValues[208 + i] <== ratioSellArg_bits.out[i];
  }
  
  component ratioBuyArg_bits = Num2Bits(256);
  ratioBuyArg_bits.in <== RatioBuyArg;
  for (var i = 0; i < 256; i += 1) {
    concatenatedValues[464 + i] <== ratioBuyArg_bits.out[i];
  }

  for (var i = 0; i < 160; i += 1) {
    concatenatedValues[720 + i] <== SellTokenAddress[i];
  }

  for (var i = 0; i < 160; i += 1) {
    concatenatedValues[880 + i] <== BuyTokenAddress[i];
  }
  
  // compute SHA256 of the serialized values
  component keccak = Keccak(1040, 256);
  for (var i = 0; i < 1040 / 8; i += 1) {
    for (var j = 0; j < 8; j++) {
      keccak.in[8*i + j] <== concatenatedValues[8*i + (7-j)];
    }
  }
  
  // convert the last 256 bits (32 bytes) into the number corresponding to hash of
  // the output of keccak is 32 bytes. bytes are arranged from largest to smallest
  // but bytes themselves are little-endian bitstrings of 8 bits
  // we just want a little-endian bitstring of them.
  component bits2Num= Bits2Num(256);
  for (var i = 0; i < 32; i++) {
    for (var j = 0; j < 8; j++) {
      bits2Num.in[8*i + j] <== keccak.out[256 - 8*(i+1) + j];
    }
  }

  // orderHash <== bits2Num.out;

  // Prepare msghash as the input of the Verify Signature method
  component serial2BytesAray[4];
  for (var i = 0; i < 4; i++) {
    serial2BytesAray[i] = Bits2Num(64);
    for (var j = 0; j < 64; j++) {
      serial2BytesAray[i].in[j] <== keccak.out[256 - 64*(i+1) + j];
    }
  }

  // Build a VerifyECDSA circuit with the size of 256 bits = 32 bytes
  component verify = ECDSAVerifyNoPubkeyCheck(64, 4);
  for (var i = 0; i < 4; i++) {
    verify.r[i] <== r[i];
    verify.s[i] <== s[i];
    verify.msghash[i] <== serial2BytesAray[i].out;
    verify.pubkey[0][i] <== pubkeyX[i];
    verify.pubkey[1][i] <== pubkeyY[i];
  }
  
  verified <== verify.result;
}

component main = VerifyEthECDSA();
