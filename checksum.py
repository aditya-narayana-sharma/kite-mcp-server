import hashlib

api_key = "5rv0bafkudcng70k"
request_token = "YOUR_REQUESTL1YE8215L2X6gQKFQ3UELgnvfsUtcBgs"
api_secret = "6fchrx81765z8hmxsnzwv2sdk9bijrta"

checksum = hashlib.sha256(f"{api_key}{request_token}{api_secret}".encode()).hexdigest()
print("Checksum:", checksum)