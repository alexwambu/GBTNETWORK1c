from fastapi import FastAPI
from fastapi.responses import HTMLResponse
from apscheduler.schedulers.background import BackgroundScheduler
import subprocess, os, time

app = FastAPI()

COINBASE = os.getenv("COINBASE")

# Auto-claim logic (runs every 24h)
def auto_claim():
    try:
        print("[AUTO-CLAIM] Running daily reward claim…")
        subprocess.run([
            "geth", "attach", "http://localhost:9636",
            "--exec", f'eth.sendTransaction({{from: "{COINBASE}", to: "{COINBASE}", value: 0}})'
        ], check=True)
    except Exception as e:
        print("[AUTO-CLAIM ERROR]", e)

scheduler = BackgroundScheduler()
scheduler.add_job(auto_claim, "interval", hours=24)
scheduler.start()

@app.get("/")
def home():
    return {"status": "GBTNetwork RPC + AutoClaim running"}

@app.get("/add_network", response_class=HTMLResponse)
def add_network_page():
    html = """
    <!DOCTYPE html>
    <html>
    <head><title>Add GBTNetwork</title></head>
    <body>
      <h1>Add GBTNetwork</h1>
      <button id="addNetwork">Add to MetaMask</button>
      <script>
        document.getElementById('addNetwork').addEventListener('click', async () => {
          if (window.ethereum) {
            try {
              await window.ethereum.request({
                method: 'wallet_addEthereumChain',
                params: [{
                  chainId: '0x3e7',
                  chainName: 'GBTNetwork',
                  nativeCurrency: { name: 'GoldBarTether', symbol: 'GBT', decimals: 18 },
                  rpcUrls: ['https://GBTNetwork:9636'],
                  blockExplorerUrls: []
                }]
              });
            } catch (err) { console.error(err); }
          } else {
            alert('MetaMask not found');
          }
        });
      </script>
    </body>
    </html>
    """
    return HTMLResponse(content=html, status_code=200)
