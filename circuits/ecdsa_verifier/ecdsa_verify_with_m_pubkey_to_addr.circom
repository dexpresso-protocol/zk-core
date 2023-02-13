pragma circom 2.0.6;
include "./ecdsa_verify_with_m.circom";
include "./circom-ecdsa-circuits/zk-identity/eth.circom";

template ECDSAVerifyPubKeyToAddr(n, k) {
    signal input s[k];
    signal input m[k];
    signal input TPreComputes[32][256][2][4]; // T = r^-1 * R
    signal input WPreComputes[32][256][2][4]; // W = r^-1 * G
    // signal input U[2][k]; // -(m * r^-1 * G)
    signal output addr;

    component ecdsaVerify = ECDSAVerifyWithM(n, k);

    var stride = 8;
    var num_strides = div_ceil(n * k, stride);

    for (var i = 0; i < num_strides; i++) {
        for (var j = 0; j < 2 ** stride; j++) {
            for (var l = 0; l < k; l++) {
                ecdsaVerify.TPreComputes[i][j][0][l] <== TPreComputes[i][j][0][l];
                ecdsaVerify.TPreComputes[i][j][1][l] <== TPreComputes[i][j][1][l];
                ecdsaVerify.WPreComputes[i][j][0][l] <== WPreComputes[i][j][0][l];
                ecdsaVerify.WPreComputes[i][j][1][l] <== WPreComputes[i][j][1][l];
            }
        }
    }

    for (var i = 0; i < k; i++) {
        ecdsaVerify.s[i] <== s[i];
        ecdsaVerify.m[i] <== m[i];
    }

    component flattenPub = FlattenPubkey(n, k);
    for (var i = 0; i < k; i++) {
        flattenPub.chunkedPubkey[0][i] <== ecdsaVerify.pubKey[0][i];
        flattenPub.chunkedPubkey[1][i] <== ecdsaVerify.pubKey[1][i];
    }

    component pubToAddr = PubkeyToAddress();
    for (var i = 0; i < 512; i++) {
        pubToAddr.pubkeyBits[i] <== flattenPub.pubkeyBits[i];
    }

    addr <== pubToAddr.address;
}
component main = ECDSAVerifyPubKeyToAddr(64, 4);