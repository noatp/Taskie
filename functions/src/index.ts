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
const db = admin.firestore();


export const addRewardToUserBalance = functions.https.onCall(async (data, context) => {
  // Check for authenticated user
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "The function must be called while authenticated."
    );
  }

  const householdId: string = data.householdId;
  const choreId: string = data.choreId;

  // Validate input
  if (!householdId || !choreId) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "The function requires valid 'householdId' and 'choreId'."
    );
  }

  try {
    // Construct the path to the chore document
    const choreRef = db.collection("households").doc(householdId).collection("chores").doc(choreId);
    const choreDoc = await choreRef.get();

    if (!choreDoc.exists) {
      throw new functions.https.HttpsError(
        "not-found",
        `Chore with ID ${choreId} not found in household ${householdId}.`
      );
    }

    const choreData = choreDoc.data();
    if (!choreData) {
      throw new functions.https.HttpsError(
        "internal",
        "Failed to retrieve chore data."
      );
    }

    const acceptorID: string = choreData.acceptorID;
    const rewardAmount: number = choreData.rewardAmount;

    // Reference to the user document
    const userRef = db.collection("users").doc(acceptorID);

    // Perform an atomic transaction to update the user's balance
    await db.runTransaction(async (transaction) => {
      const userDoc = await transaction.get(userRef);

      if (!userDoc.exists) {
        throw new functions.https.HttpsError(
          "not-found",
          `User with ID ${acceptorID} not found.`
        );
      }

      // Get current balance and update it
      const currentBalance: number = userDoc.data()?.balance || 0;
      const newBalance = currentBalance + rewardAmount;

      transaction.update(userRef, {balance: newBalance});
    });

    return {message: `Reward of ${rewardAmount} added to user ${acceptorID}'s balance.`};
  } catch (error) {
    console.error("Error updating balance: ", error);
    throw new functions.https.HttpsError("unknown", "An error occurred while updating the balance.");
  }
});
