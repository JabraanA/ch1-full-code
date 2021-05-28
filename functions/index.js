const functions = require("firebase-functions");
const admin = require("firebase-admin");

const serviceAccount = require("./sa.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://challenge1-310911-default-rtdb.firebaseio.com",
});

const express = require("express");
const app = express();
const db = admin.firestore();

const cors = require("cors");
app.use(cors({origin: true}));

const increment = admin.firestore.FieldValue.increment(1);

// Routes
app.get("/hello-world", (req, res) => {
  return res.status(200).send("Hello World!");
});

// Read
app.get("/api/read/:id", (req, res) => {
  (async () => {
    try {
      const document = db.collection("counter").doc(req.params.id);
      document.update({count: increment});
      const count = await document.get();
      const response = count.data();

      return res.status(200).send(response);
    } catch (error) {
      console.log(error);
      return res.status(500).send(error);
    }
  })();
});
// Put request
app.put('/api/update/:id', (req, res) => {
  (async() => {
      try {
          const document = db.collection('counter').doc(req.params.id);

          document.update( {count: increment});
          let counter = await document.get();
          let response = counter.data();

          return res.status(200).send(response);
      }
      catch (error) {
          console.log(error);
          return res.status(500).send(error);
      }
  })();
});

// Export the api to Firebase Cloud Functions
exports.app = functions.https.onRequest(app);
