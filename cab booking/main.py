import os

from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
from google.cloud import firestore
from google.oauth2 import service_account
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

# Replace with the path to your own service account key file
service_account_key_path = "D:\SA Project\Flutter-with-micro-service\cab booking\cab-service-e8116-firebase-adminsdk-h9z2s-2687faaf70.json"

# Initialize a Firestore client
credentials = service_account.Credentials.from_service_account_file(
    service_account_key_path)
db = firestore.Client(credentials=credentials)

app = FastAPI()

origins = [
    "http://localhost.tiangolo.com",
    "https://localhost.tiangolo.com",
    "http://localhost",
    "http://localhost:8080",
    "http://localhost:4000",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/request/")
async def get_requests():
    request_ref = db.collection("request")
    requests = [doc.to_dict() for doc in request_ref.stream()]
    return JSONResponse(content=requests)


@app.get("/request/{id}")
async def get_request_by_id(id: str):
    request_ref = db.collection("request")
    query_ref = request_ref.where(u'userEmail', u'==', id)
    requests = [doc.to_dict() for doc in query_ref.stream()]
    return JSONResponse(content=requests)


@app.get("/nextrequestid")
async def get_next_request_id():
    last_ref = db.collection('request')

    query = last_ref.order_by(
        "id", direction=firestore.Query.DESCENDING).limit(1)
    result = [doc.to_dict() for doc in query.stream()]
    if len(result) == 1:
        # return int(result[0]['id']+1)
        return JSONResponse(content=result)
    else:
        return {}
    # return current_id + 1


@app.post("/createrequest")
async def create_request(request: dict):
    try:
        doc_ref = db.collection('request').document()
        doc_ref.set(request)
        return {"id": doc_ref.id}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.put("/update/{document}")
async def update_request(document: str, data: dict):
    doc_ref = db.collection(u'request').document(document)
    doc_ref.update(data)
    return {"message": "Data updated successfully"}


# if __name__ == "__main__":
#     port = int(os.environ.get("PORT", 8001))
#     uvicorn.run("main:app", host="0.0.0.0", port=port, log_level="info")


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
