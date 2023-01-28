pragma circom 2.0.0;

include "../circom-ecdsa/circuits/vocdoni-keccak/keccak.circom";
include "../circom-ecdsa/node_modules/circomlib/circuits/bitify.circom";


/**
* This circuit is calculates the hash of the Dexpresso's orders
**/  

template CreateOrderHash () {  

  // Declaration of signals.  
  signal input FeeRatio;
  signal input OrderID;
  signal input ValidUntil;
  signal input ChainID;
  signal input RatioSellArg;
  signal input RatioBuyArg;
  signal input SellTokenAddress[160];
  signal input BuyTokenAddress[160];
  
  signal concatenatedValues[1040]; // size = 1040 = 16 + 3x64 + 2x256 + 2x160 
  signal tmpp1;
  signal tmpp2;
  signal tmpp3;
  signal tmpp4;
  signal tmpp5;
  signal tmpp6;
  signal tmpp7;
  signal tmpp8;
  

  signal output orderHash;

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

  component bits2Num1 = Bits2Num(250);
  for (var j = 0; j < 250; j++) {
    bits2Num1.in[j] <== concatenatedValues[j];
  }
  tmpp1 <== bits2Num1.out;

  component bits2Num2 = Bits2Num(250);
  for (var j = 0; j < 250; j++) {
    bits2Num2.in[j] <== concatenatedValues[250 + j];
  }
  tmpp2 <== bits2Num2.out;

  component bits2Num3 = Bits2Num(250);
  for (var j = 0; j < 250; j++) {
    bits2Num3.in[j] <== concatenatedValues[500 + j];
  }
  tmpp3 <== bits2Num3.out;

  component bits2Num4 = Bits2Num(250);
  for (var j = 0; j < 250; j++) {
    bits2Num4.in[j] <== concatenatedValues[750 + j];
  }
  tmpp4 <== bits2Num4.out;

  component bits2Num5 = Bits2Num(40);
  for (var j = 0; j < 40; j++) {
    bits2Num5.in[j] <== concatenatedValues[1000 + j];
  }
  tmpp5 <== bits2Num5.out;

  tmpp6 <== tmpp1 + tmpp2;
  tmpp7 <== tmpp3 + tmpp4;
  tmpp8 <== tmpp5 + tmpp6;
  orderHash <== tmpp7 + tmpp8;
    
  // // compute SHA256 of the serialized values
  // component keccak = Keccak(1040, 256);
  // for (var i = 0; i < 1040 / 8; i += 1) {
  //   for (var j = 0; j < 8; j++) {
  //     keccak.in[8*i + j] <== concatenatedValues[8*i + (7-j)];
  //   }
  // }
  
  // // convert the last 256 bits (32 bytes) into the number corresponding to hash of
  // // the output of keccak is 32 bytes. bytes are arranged from largest to smallest
  // // but bytes themselves are little-endian bitstrings of 8 bits
  // // we just want a little-endian bitstring of them.
  // component bits2Num = Bits2Num(256);
  // for (var i = 0; i < 32; i++) {
  //   for (var j = 0; j < 8; j++) {
  //     bits2Num.in[8*i + j] <== keccak.out[256 - 8*(i+1) + j];
  //   }
  // }

  // orderHash <== bits2Num.out;
}

component main = CreateOrderHash();

