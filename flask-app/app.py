from flask import Flask
import socket
import os

app = Flask(__name__)

@app.route('/')
def hello():
    hostname = socket.gethostname()
    version = os.environ.get('APP_VERSION', '1.0.0')
    return f'''
    <h1>Hello from K3s Cluster!</h1>
    <p><strong>Container ID:</strong> {hostname}</p>
    <p><strong>Version:</strong> {version}</p>
    <p><strong>Status:</strong> Running on Kubernetes</p>
    '''

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)