from flask import Flask, render_template, request, flash, redirect, url_for, session, send_from_directory
import uuid
import os
import subprocess
import zipfile

# Function to sanitize filenames to avoid directory traversal
def sanitize_filename(filename):
    # Prevent directory traversal by removing any ".." sequences
    return os.path.basename(filename)

# Function to create a tree structure from the extracted files
def make_tree(path, base_url="/static/zips"):
    tree = dict(name=os.path.basename(path), children=[])
    
    try:
        lst = os.listdir(path)
    except OSError:
        pass  
    else:
        for name in lst:
            # Sanitize the filename
            name = sanitize_filename(name)
            fn = os.path.join(path, name)
            url = fn.replace("./static", "/static")
            if os.path.isdir(fn):
                tree['children'].append(make_tree(fn, base_url))
            else:
                tree['children'].append(dict(name=name, url=url))
    
    return tree

# Initialize the Flask application
app = Flask(__name__)
app.config["SECRET_KEY"] = uuid.uuid4().hex

# Define the base directory for file storage
BASE_DIR = "./static/zips"
os.makedirs(BASE_DIR, exist_ok=True)

# Function to check if the file has a valid extension
def allowed_file(filename):
    allowed_extensions = {'zip'}
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in allowed_extensions

# Function to safely extract zip files
def safe_extract_zip(zip_path, extract_to):
    try:
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            # Check for path traversal attempts in the zip file
            for file_info in zip_ref.infolist():
                file_name = file_info.filename
                # Check for absolute paths or directory traversal
                if file_name.startswith('/') or '..' in file_name or file_name.startswith('..'):
                    return False, "Security breach detected: path traversal attempt"
                
                # Extract only files, not directories and not symlinks
                if not file_name.endswith('/'):
                    # Get just the filename without any path
                    safe_name = os.path.basename(file_name)
                    # Extract the file with a safe name
                    source = zip_ref.open(file_info)
                    target = open(os.path.join(extract_to, safe_name), "wb")
                    with source, target:
                        target.write(source.read())
        return True, "Extraction successful"
    except zipfile.BadZipFile:
        return False, "Invalid ZIP file"
    except Exception as e:
        return False, f"Extraction failed: {str(e)}"

# Route for the index page where users upload zip files
@app.route("/", methods=['GET', 'POST'])
def index():
    return render_template("index.j2")

# Route to handle zip file extraction
@app.route("/extract", methods=['GET', 'POST'])
def extract():
    # Check if a file is included in the request
    if 'zipFile' not in request.files:
        return "No file part", 400

    zip_file = request.files['zipFile']
    
    # Check if the file has a valid filename and is a zip file
    if zip_file.filename == '' or not allowed_file(zip_file.filename):
        return "No selected file or invalid file type", 400

    # Create a random directory to store the extracted files
    random_dir = os.path.join(BASE_DIR, str(uuid.uuid4()))
    os.makedirs(random_dir, exist_ok=True)

    # Save the uploaded zip file with a unique name
    zip_path = os.path.join(random_dir, f"{str(uuid.uuid4())}_uploaded.zip")
    zip_file.save(zip_path)

    # Extract the zip file safely
    success, message = safe_extract_zip(zip_path, random_dir)
    os.remove(zip_path)  # Remove the original zip file after extraction
    
    if not success:
        return "Don't hack me", 401

    # Generate the base URL for the extracted files
    base_url = url_for('static', filename=f'zips/{random_dir.split(BASE_DIR + "/")[1]}')
    
    # Generate the file tree structure
    tree = make_tree(random_dir, base_url)

    # Render the view template to display the file tree
    return render_template('view.j2', tree=tree, base_path=random_dir.split(BASE_DIR + '/')[1])

# Start the Flask application
if __name__ == "__main__":
    app.run(debug=True)