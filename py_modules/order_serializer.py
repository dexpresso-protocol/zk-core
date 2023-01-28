import json
from web3 import Web3
import eth_utils


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

tmpp1 = int(raw_order[0:250][::-1], 2)
tmpp2 = int(raw_order[250:500][::-1], 2)
tmpp3 = int(raw_order[500:750][::-1], 2)
tmpp4 = int(raw_order[750:1000][::-1], 2)
tmpp5 = int(raw_order[1000:1040][::-1], 2)
tmpp6 = (tmpp1 + tmpp2) % p
tmpp7 = (tmpp3 + tmpp4) % p
tmpp8 = (tmpp5 + tmpp6) % p
final = (tmpp7 + tmpp8) % p

print(final)
