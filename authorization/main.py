import os

from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
from google.cloud import firestore
from google.oauth2 import service_account
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

# Replace with the path to your own service account key file
service_account_key_path = "D:\SA Project\Flutter-with-micro-service\Authorization\quick-shift-5657c-firebase-adminsdk-aeix7-4107d89eb6.json"

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
    "http://localhost:59981",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.post("/login/")
async def authorize(email: str, password: str):
    r = await get_usertype_by_id(email)
    if (r == "Driver"):
        users_ref = db.collection(u'drivers')
        query_ref = users_ref.where(u'email', u'==', email)
        query = query_ref.get()
        userdata = [doc.to_dict() for doc in query_ref.stream()]
        if len(query) == 0:
            # raise HTTPException(status_code=404, detail="Email not found")
            return 0
        else:
            user_doc = query[0]
            if user_doc.to_dict().get('password') == password:
                return 2
            else:
                # raise HTTPException(status_code=401, detail="Unauthorized")
                return 0
    elif (r == "User"):
        users_ref = db.collection(u'users')
        query_ref = users_ref.where(u'email', u'==', email)
        query = query_ref.get()
        userdata = [doc.to_dict() for doc in query_ref.stream()]
        if len(query) == 0:
            # raise HTTPException(status_code=404, detail="Email not found")
            return 0
        else:
            user_doc = query[0]
            if user_doc.to_dict().get('password') == password:
                return 1
                # raise HTTPException(status_code=200, detail="Authorized")
            else:
                # raise HTTPException(status_code=401, detail="Unauthorized")
                return 0
    else:
        return 0


# @app.get("/usertype/{id}")
async def get_usertype_by_id(id: str):
    request_ref = db.collection("userType")
    query_ref = request_ref.where(u'email', u'==', id)
    requests = [doc.to_dict() for doc in query_ref.stream()]
    return requests[0]['type']


async def update_login_status(document: str, data: dict):
    doc_ref = db.collection(u'request').document(document)
    doc_ref.update(data)
    return {"message": "Data updated successfully"}

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 4000))
    uvicorn.run("main:app", host="0.0.0.0", port=port, log_level="info")
