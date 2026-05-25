from kiteconnect import KiteConnect

api_key = "5rv0bafkudcng70k"
api_secret = "6fchrx81765z8hmxsnzwv2sdk9bijrta"

kite = KiteConnect(api_key=api_key)

print("Login URL:")
print(kite.login_url())

request_token = input("Paste request_token here: ")

data = kite.generate_session(
    request_token,
    api_secret=api_secret
)

print("\nACCESS TOKEN:")
print(data["access_token"])