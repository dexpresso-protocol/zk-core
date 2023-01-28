import json

hex_data = '0x0000000000000000000000000000000000000000'
raw_number = int(hex_data[2:], 16)
print(json.dumps([str(item) for item in bin(raw_number)[2:].zfill(160)]))
