from json import JSONDecodeError
import json
import os
import random
import aio_pika
from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
from google.cloud import firestore
from google.oauth2 import service_account
from fastapi.middleware.cors import CORSMiddleware
import requests
import uvicorn

# Replace with the path to your own service account key file
service_account_key_path = "D:\SA Project\Flutter-with-micro-service\payment\payment-e87d4-firebase-adminsdk-at0tv-a34a2d3435.json"

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


@app.get("/nextpaymentid")
async def get_next_payment_id():
    last_ref = db.collection('payments')

    query = last_ref.order_by(
        "id", direction=firestore.Query.DESCENDING).limit(1)
    result = [doc.to_dict() for doc in query.stream()]
    if len(result) == 1:
        return int(int(result[0]['id'])+1)
        # return JSONResponse(content=result)
    else:
        return 1
    # return current_id + 1


@app.put("/createpayment/{id}")
async def create_request(id: str, request: dict):

    r = await get_confirmation_from_bank()
    if (r == 1):
        # update payment status
        doc_ref = db.collection('payments').document()
        doc_ref.set(request)
        requests.post('http://localhost:8001/updaterequest/' +
                      id + '/' + 'trans_id', json={"paymentstatus": "1"})
        # send_message("updaterequest", "trans_id", id, {"paymentstatus": "1"})
        return 1
    else:
        requests.post('http://localhost:8001/updaterequest/' +
                      id + '/' + 'trans_id', json={"status": "Booking Failed", "driverName": "", "driverPhoneNo": ""})
        return 0


async def get_confirmation_from_bank():
    # return random.randint(0, 1)
    return 0


# Set up RabbitMQ connection
async def connect_rabbitmq():
    connection = await aio_pika.connect_robust("amqp://guest:guest@localhost/")
    channel = await connection.channel()
    queue = await channel.declare_queue("messages")
    return connection, channel, queue

# Send a message to the queue


async def send_message(functioname: str, idname: str, id: str, datatoupdate: dict):
    message_data = {"function_name": functioname,
                    "idname": idname, "id": id, "datatoupdate": datatoupdate}
    message = aio_pika.Message(body=json.dumps(message_data).encode())
    connection, channel, queue = await connect_rabbitmq()
    await channel.default_exchange.publish(message, routing_key="messages")
    await connection.close()

# Define a route to send a message to the other server


# @app.post("/send_message")
# async def send_message_route(message: str):
#     await send_message(message)
#     return {"message": "Message sent"}


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run("main:app", host="0.0.0.0", port=port, log_level="info")
