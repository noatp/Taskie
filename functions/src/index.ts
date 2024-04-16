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

exports.generateInviteCode = functions.https.onCall(async (data, context) => {
  const householdId: string = data.householdId;
  const db = admin.firestore();

  /**
   * Recursively generates a unique 6-digit code and updates the household
   * document without returning it to the client.
   *
   * The code will be used directly from the Firestore 'households' collection
   * by the client.
   */
  async function generateCode(): Promise<{success: boolean}> {
    const code: string = ("000000" + Math.floor(Math.random() * 1000000)
      .toString())
      .slice(-6);
    const inviteCodeDocRef = db.collection("inviteCodes").doc(code);
    const inviteCodeDoc = await inviteCodeDocRef.get();
    const householdDocRef = db.collection("households").doc(householdId);

    if (inviteCodeDoc.exists) {
      // Recursively generate a new code if there's a collision
      console.log("invite code collision");
      return generateCode();
    } else {
      // Code is unique, store it with the householdId
      const batch = db.batch();
      batch.set(inviteCodeDocRef, {householdId: householdId});
      batch.update(householdDocRef, {inviteCode: code});

      try {
        await batch.commit();
        console.log("Invite code generated and saved to household");
        // Simply return a success message or empty object
        return {success: true};
      } catch (error) {
        console.error("Error updating documents: ", error);
        throw new functions.https.HttpsError(
          "unknown",
          "Failed to generate and store invite code",
          error
        );
      }
    }
  }

  return generateCode();
});
