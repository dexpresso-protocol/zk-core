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
  signal input chainID;
  signal input RatioSellArg;
  signal input RatioBuyArg;
  signal input SellTokenAddress;
  signal input BuyTokenAddress;
  
  signal concatenatedValues[1040]; // size = 1040 = 16 + 3x64 + 2x256 + 2x160 
  var tmpCnt;
  signal temp3;
  signal temp4;
  
  signal output orderHash;

  // Serialization and concatenation of inputs
  tmpCnt = 0
  component maxFeeRatio_bits = Num2Bits(16);
  maxFeeRatio_bits.in <== maxFeeRatio;
  for (var i = 0; i < 16; i += 1) {
    concatenatedValues[tmpCnt + i] <==maxFeeRatio_bits[i];
    tmpCnt++;
  }

  
  component orderID_bits = Num2Bits(64);
  orderID_bits.in <== orderID;
  for (var i = 0; i < 64; i += 1) {
    concatenatedValues[tmpCnt + i] <==orderID_bits[i];
    tmpCnt++;
  }
  
  component validUntil_bits = Num2Bits(64);
  validUntil_bits.in <== validUntil;
  for (var i = 0; i < 64; i += 1) {
    concatenatedValues[tmpCnt + i] <==validUntil_bits[i];
    tmpCnt++;
  }
  
  component chainID_bits = Num2Bits(64);
  chainID_bits.in <== chainID;
  for (var i = 0; i < 64; i += 1) {
    concatenatedValues[tmpCnt + i] <==chainID_bits[i];
    tmpCnt++;
  }
  
  component ratioSellArg_bits = Num2Bits(256);
  ratioSellArg_bits.in <== ratioSellArg;
  for (var i = 0; i < 256; i += 1) {
    concatenatedValues[tmpCnt + i] <==ratioSellArg_bits[i];
    tmpCnt++;
  }
  
  component ratioBuyArg_bits = Num2Bits(256);
  ratioBuyArg_bits.in <== ratioBuyArg;
  for (var i = 0; i < 256; i += 1) {
    concatenatedValues[tmpCnt + i] <==ratioBuyArg_bits[i];
    tmpCnt++;
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
  component bits2Num = Bits2Num(160);
  for (var i = 0; i < 32; i++) {
    for (var j = 0; j < 8; j++) {
      bits2Num.in[8*i + j] <== keccak.out[256 - 8*(i+1) + j];
    }
  }

  orderHash <== bits2Num.out;
}

component main = CreateOrderHash();

