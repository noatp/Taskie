/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */


// Start writing functions
// https://firebase.google.com/docs/functions/typescript

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

exports.createUserInUsersCollection = functions.firestore
  .document("households/{householdId}/members/{memberId}")
  .onCreate((snap, context) => {
    const householdId = context.params.householdId;
    const memberId = context.params.memberId;

    const userDoc = {
      householdId: householdId,
    };

    return admin.firestore().collection("users").doc(memberId).set(userDoc)
      .then(() => console.log("User document for ${memberId} created"))
      .catch((error) => console.error("Error creating user document: ", error));
  });
