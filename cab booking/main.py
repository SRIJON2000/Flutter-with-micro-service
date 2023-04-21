from json import JSONDecodeError
import json
import os

from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
from google.cloud import firestore
from google.oauth2 import service_account
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
import aio_pika

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
    "http://localhost:4001",
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

    query_ref1 = request_ref.where(u'userEmail', u'==', id)

    requests = [doc.to_dict() for doc in query_ref1.stream()]
    return JSONResponse(content=requests)


@app.get("/driverrequest/{id}")
async def get_request_by_id(id: str):
    request_ref = db.collection("request")
    query_ref = request_ref.where(u'driverEmail', u'==', id)
    requests = [doc.to_dict() for doc in query_ref.stream()]
    return JSONResponse(content=requests)


@app.get("/pendingrequest/")
async def get_pending_request_by_id():
    request_ref = db.collection("request")
    query_ref = request_ref.where(u'status', u'==', "Processing")
    query_ref1 = query_ref.where(u'paymentstatus', u'==', "1")
    requests = [doc.to_dict() for doc in query_ref1.stream()]
    return JSONResponse(content=requests)


@app.get("/nextrequestid")
async def get_next_request_id():
    last_ref = db.collection('request')

    query = last_ref.order_by(
        "id", direction=firestore.Query.DESCENDING).limit(1)
    result = [doc.to_dict() for doc in query.stream()]
    print(result)
    if len(result) == 1:
        return int(int(result[0]['id'])+1)
        # return JSONResponse(content=result)
    else:
        return 1
    # return current_id + 1


@app.put("/createrequest")
async def create_request(request: dict):
    try:
        doc_ref = db.collection('request').document()
        doc_ref.set(request)
        return {"id": doc_ref.id}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/updaterequest/{id}/{idname}")
async def update_request(idname: str, id: str, data: dict):
    collection_ref = db.collection(u'request')
    query = collection_ref.where(idname, u'==', id).limit(1)
    docs = query.stream()
    for doc in docs:
        doc_ref = collection_ref.document(doc.id)
        doc_ref.update(data)


async def get_document_id(column_name: str, column_value: str, collection: str):

    collection_ref = db.collection(collection)

    # Create a query to find the document that has the specified column value
    query = collection_ref.where(column_name, '==', column_value).limit(1)

    # Get the first document that matches the query and return its ID
    docs = query.stream()
    for doc in docs:
        return {"documentid": doc.id}

    return {"message": "No document found that matches the specified criteria."}
# if __name__ == "__main__":
#     port = int(os.environ.get("PORT", 8001))
#     uvicorn.run("main:app", host="0.0.0.0", port=port, log_level="info")


@app.delete("/deleterequest/{collection}/{column_name}/{column_value}")
async def delete_row(collection: str, column_name: str, column_value: str):
    try:
        # Query the collection to find the document with the specified column value
        query = db.collection(collection).where(
            column_name, "==", column_value)
        docs = query.stream()

        # If a matching document is found, delete it
        for doc in docs:
            doc.reference.delete()
            return {"message": f"Deleted row with {column_name} = {column_value} from collection {collection}"}

        # If no matching documents are found, return an error message
        return {"message": f"No row found with {column_name} = {column_value} in collection {collection}"}

    except Exception as e:
        return {"message": f"Error deleting row: {str(e)}"}
# Set up RabbitMQ connection


async def connect_rabbitmq():
    connection = await aio_pika.connect_robust("amqp://guest:guest@localhost/")
    channel = await connection.channel()
    queue = await channel.declare_queue("messages")
    return connection, channel, queue

# Listen for messages on the queue


async def receive_messages():
    connection, channel, queue = await connect_rabbitmq()
    async with queue.iterator() as queue_iter:
        async for message in queue_iter:
            async with message.process():
                message_data = json.loads(message.body.decode())
                function_name = message_data["function_name"]
                data = message_data["datatoupdate"]
                id = message_data["id"]
                idname = message_data["idname"]
                if function_name == "updaterequest":
                    await update_request(idname, id, data)

# Define a route to start listening for messages


@app.get("/listen_for_messages")
async def listen_for_messages_route():
    await receive_messages()
    return {"message": "Listening for messages"}


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
