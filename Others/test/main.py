from fastapi import FastAPI
import os
import asyncio
from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
import json
import numpy as np
from tensorflow import keras
from sklearn.preprocessing import LabelEncoder
import random
import pickle

app = FastAPI(debug=True)

origins = [
    "http://localhost.tiangolo.com",
    "https://localhost.tiangolo.com",
    "http://localhost",
    "http://localhost:4001",
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

with open("C:/Users/Srijon Mallick/Downloads/RP_CHATBOT/website.json") as file:
    data = json.load(file)
model = keras.models.load_model('C:/Users/Srijon Mallick/Downloads/RP_CHATBOT/chat_model.h5')
with open('C:/Users/Srijon Mallick/Downloads/RP_CHATBOT/tokenizer.pickle', 'rb') as handle:
    tokenizer = pickle.load(handle)
with open('C:/Users/Srijon Mallick/Downloads/RP_CHATBOT/label_encoder.pickle', 'rb') as enc:
    lbl_encoder = pickle.load(enc)
max_len = 20


@app.get("/get/{input}")
async def response(input: str):
    result = model.predict(keras.preprocessing.sequence.pad_sequences(tokenizer.texts_to_sequences([input]),
                                                                      truncating='post', maxlen=max_len))
    tag = lbl_encoder.inverse_transform([np.argmax(result)])
    for i in data['intents']:
        if i['tag'] == tag:
            return np.random.choice(i['responses'])

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
