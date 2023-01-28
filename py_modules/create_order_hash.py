import json
from web3 import Web3
from eth_utils.crypto import keccak


p = 21888242871839275222246405745257275088548364400416034343698204186575808495617
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
print(int(hash_result.hex(), 16) % p)
