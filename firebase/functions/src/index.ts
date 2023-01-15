import * as functions from "firebase-functions";
import algoliasearch from "algoliasearch";
import {validateFilters, constructQuery} from "./utils";

const ALGOLIA_ID = process.env.ALGOLIA_ID || "";
const ALGOLIA_ADMIN_KEY = process.env.ALGOLIA_ADMIN_KEY || "";
const ALGOLIA_SEARCH_KEY = process.env.ALGOLIA_SEARCH_KEY || "";
const ALGOLIA_INDEX_NAME = process.env.ALGOLIA_INDEX_NAME || "";
const adminClient = algoliasearch(ALGOLIA_ID, ALGOLIA_ADMIN_KEY);
const adminIndex = adminClient.initIndex(ALGOLIA_INDEX_NAME);

// Cloud Functions for generating algolia indexes
exports.onPostCreated = functions.firestore.document("Posts/{postId}")
    .onCreate((snap, context) => {
      const post = snap.data();
      const creationDate= post.creationDate as string;
      const birthday = post.birthday as string;
      const id = context.params.postId as string;
      const creationTimestamp = new Date(creationDate).getTime();
      const birthdayTimestamp = new Date(birthday).getTime();
      post.objectID = id;
      post.creationTimestamp = creationTimestamp;
      post.birthdayTimestamp = birthdayTimestamp;
      return adminIndex.saveObject(post);
    });

exports.onPostDeleted = functions.firestore.document("Posts/{postId}")
    .onDelete((snap, context) => {
      const id : string = context.params.postId;
      return adminIndex.deleteObject(id);
    });

exports.onPostModified = functions.firestore.document("Posts/{postId}")
    .onUpdate((change, context) => {
      const post = change.after.data();
      const id = context.params.postId as string;
      const birthday = post.birthday as string;
      const birthdayTimestamp = new Date(birthday).getTime();
      // In case birthday was modified
      post.birthdayTimestamp = birthdayTimestamp;
      post.objectID = id;
      const objects = [post];
      return adminIndex.partialUpdateObjects(objects);
    });

// Cloud Functions for querying algolia indexes as express app
import * as express from "express";
import * as cors from "cors";

const searchClient = algoliasearch(ALGOLIA_ID, ALGOLIA_SEARCH_KEY);
const searchIndex = searchClient.initIndex(ALGOLIA_INDEX_NAME);
const app = express();
app.use(cors({
  origin: true,
}));
app.get("/", (req, res) => {
  const text = req.query.text as string;
  const page = req.query.page as string;
  const num = req.query.num as string;

  let fields = req.query.fields;
  let operators = req.query.operators;
  let values = req.query.values;

  if (typeof fields === "string") {
    fields = [fields];
  }
  if (typeof operators === "string") {
    operators = [operators];
  }
  if (typeof values === "string") {
    values = [values];
  }

  const fieldArray = fields as string[];
  const operatorArray = operators as string[];
  const valueArray = values as string[];

  const pageNum = Number(page) || 0;
  const hitsPerPage = Number(num) || 5;

  const result = validateFilters(fieldArray, operatorArray, valueArray);
  if (!result.valid) {
    res.status(400).send({
      fields: fields,
      operators: operators,
      values: values,
      message: result.message,
    });
  } else {
    const query = constructQuery(fieldArray, operatorArray, valueArray);
    console.log(query);
    searchIndex.search(text, {
      filters: query,
      page: pageNum,
      hitsPerPage: hitsPerPage,
    }).then( (hits) => {
      // res.send(hits);
      res.send({
        hits,
      });
    }).catch((error) => {
      res.send(error);
    });
  }
});


exports.search = functions.https.onRequest(app);

import {initializeApp} from "firebase-admin/app";
initializeApp();
