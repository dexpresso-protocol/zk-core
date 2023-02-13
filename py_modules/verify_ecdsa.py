import json

from ecdsa import SECP256k1
from ecdsa.ellipticcurve import PointJacobi
from web3 import Web3
from eth_utils.crypto import keccak
from eth_keys.datatypes import PrivateKey
from ecdsa.numbertheory import inverse_mod


p = 21888242871839275222246405745257275088548364400416034343698204186575808495617

account_addr = "0x2A982B7CD7f91e180841B7CBDd1DDb0f6433aAb1"
priv_key = "21dd248b7b138c179ef8e07497be50d16e94614ca9bdd25af608deffe6b8aa6e"
inputs = json.load(open("/home/vargzum/dexpresso/zk-core/circuits/order_hash/inputs/good_input.json", "r"))
raw_order = bin(int(inputs["FeeRatio"]))[2:].zfill(16)[::-1] \
          + bin(int(inputs["OrderID"]))[2:].zfill(64)[::-1] \
          + bin(int(inputs["ValidUntil"]))[2:].zfill(64)[::-1] \
          + bin(int(inputs["ChainID"]))[2:].zfill(64)[::-1] \
          + bin(int(inputs["RatioSellArg"]))[2:].zfill(256)[::-1] \
          + bin(int(inputs["RatioBuyArg"]))[2:].zfill(256)[::-1] \
          + "".join((inputs["SellTokenAddress"])) \
          + "".join((inputs["BuyTokenAddress"]))

plain_ints = [(int(raw_order[i*8:i*8+8], 2)) for i in range(130)]

plain_bytes = bytearray(plain_ints)

hash_result = keccak(plain_bytes)
plain_message = int(hash_result.hex(), 16) % p

signature = Web3().eth.account._sign_hash(bytes.fromhex(hash_result.hex()), priv_key)
r_bytes = bytes.fromhex(hex(signature.r)[2:].zfill(64))
s_bytes = bytes.fromhex(hex(signature.s)[2:].zfill(64))
priv_obj = PrivateKey(bytes.fromhex(priv_key))
pkX_bytes = priv_obj.public_key.to_bytes()[:32]
pkY_bytes = priv_obj.public_key.to_bytes()[32:]

print("pubkey_X:", int(pkX_bytes.hex(), 16))
print("pubkey_Y:", int(pkY_bytes.hex(), 16))
print("r:       ", int(r_bytes.hex(), 16))
print("s:       ", int(s_bytes.hex(), 16))


print(Web3().eth.account._recover_hash(hash_result, signature=signature.signature.hex()[2:]))

q = SECP256k1.generator.order()

m = int(hash_result.hex(), 16)
s = signature.s
r = signature.r
G = SECP256k1.generator
P = PointJacobi.from_bytes(data=priv_obj.public_key.to_bytes(), curve=SECP256k1.curve)
s_i = inverse_mod(s, q)
r_i = inverse_mod(r, q)
R = (((s_i * m) % q) * G) + (((r * s_i) % q) * P)

assert R.x() == r
print("Signature is verified")

print('Calculating T and U . . .')
T = r_i * R
U = ((-r_i * m) % q) * G
W = (-r_i % q) * G
assert s * T + m * W == P
print("T & W are verified")

TAG_POINT_JACOBI_FULL = '04'  # This is for the Rust implementation --> libsecp256k1
print("Serialization of T:")
print(hex(T.x())[2:] + hex(T.y())[2:])
print("Serialization of W:")
print(hex(W.x())[2:] + hex(U.y())[2:])

print('Computing powers of T & W . . .')
pre_t = []  # int[32][256][2][4]
pre_w = []  # int[32][256][2][4]
for i in range(0,32):
    inner_list_t = []
    inner_list_w = []
    power = (2 ** (i * 8)) % q
    for j in range(0, 256):
        l = (j * power) % q
        if l == 0:
            inner_list_t.append(
                [
                    ["0", "0", "0", "0"],
                    ["0", "0", "0", "0"]
                ]
            )
            inner_list_w.append(
                [
                    ["0", "0", "0", "0"],
                    ["0", "0", "0", "0"]
                ]
            )
        else:
            tmp_t = l * T
            x_register_t = hex(tmp_t.x())[2:].zfill(64)
            y_register_t = hex(tmp_t.y())[2:].zfill(64)
            inner_list_t.append(
                [
                    [str(int(x_register_t[k*16:(k+1)*16], 16)) for k in range(4)][::-1],
                    [str(int(y_register_t[k*16:(k+1)*16], 16)) for k in range(4)][::-1]
                ]
            )

            tmp_w = l * W
            x_register_w = hex(tmp_w.x())[2:].zfill(64)
            y_register_w = hex(tmp_w.y())[2:].zfill(64)
            inner_list_w.append(
                [
                    [str(int(x_register_w[k*16:(k+1)*16], 16)) for k in range(4)][::-1],
                    [str(int(y_register_w[k*16:(k+1)*16], 16)) for k in range(4)][::-1]
                ]
            )
    pre_t.append(inner_list_t)
    pre_w.append(inner_list_w)


# u_x_split_reg = [str(int(hex(U.x())[2:].zfill(64)[i*16:(i+1)*16], 16)) for i in range(4)][::-1]
# u_y_split_reg = [str(int(hex(U.y())[2:].zfill(64)[i*16:(i+1)*16], 16)) for i in range(4)][::-1]

s_split_reg = [str(int(hex(s)[2:].zfill(64)[i*16:(i+1)*16], 16)) for i in range(4)][::-1]
m_split_reg = [str(int(hex(m)[2:].zfill(64)[i*16:(i+1)*16], 16)) for i in range(4)][::-1]

final_inputs = {
    "TPreComputes": pre_t,
    "WPreComputes": pre_w,
    "s": s_split_reg,
    "m": m_split_reg
}
json.dump(final_inputs, open("good_input.json", "w"), indent=4)

# address = 243171113955163990010132169187901351983909677745 % p
# print(hex(address))