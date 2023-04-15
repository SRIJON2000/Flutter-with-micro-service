import os

from fastapi import FastAPI
from fastapi.responses import JSONResponse
from google.cloud import firestore
from google.oauth2 import service_account

# Replace with the path to your own service account key file
service_account_key_path = "D:\SA Project Flutter\server\quick-shift-5657c-firebase-adminsdk-aeix7-4107d89eb6.json"

# Initialize a Firestore client
credentials = service_account.Credentials.from_service_account_file(service_account_key_path)
db = firestore.Client(credentials=credentials)

app = FastAPI()

@app.get("/request/")
async def get_drivers():
    drivers_ref = db.collection("request")
    drivers = [doc.to_dict() for doc in drivers_ref.stream()]

    return JSONResponse(content=drivers)



if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run("main:app", host="0.0.0.0", port=port, log_level="info")