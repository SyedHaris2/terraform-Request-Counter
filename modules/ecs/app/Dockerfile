FROM node:20-alpine
WORKDIR /app
RUN echo '\
const express = require("express");\
const redis = require("redis");\
const client = redis.createClient({\
  url: `redis://default:${process.env.REDIS_PASSWORD}@${process.env.REDIS_HOST}:${process.env.REDIS_PORT}`\
});\
client.connect();\
const app = express();\
app.get("/health", (_, res) => res.send("ok")); \
app.get("/", async (_, res) => {\
  const cnt = await client.incr("counter");\
  res.send(`Request #${cnt}\n`);\
});\
app.listen(3000, () => console.log("up"));' > index.js
RUN npm init -y && npm install express redis
CMD ["node","index.js"]