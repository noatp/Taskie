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
      const expirationTime = admin.firestore.Timestamp.now().toMillis() + (5 * 60 * 1000);
      const expirationTimeTimestamp = admin.firestore.Timestamp.fromMillis(expirationTime);
      const batch = db.batch();
      batch.set(inviteCodeDocRef, {
        householdId: householdId,
        expirationTime: expirationTimeTimestamp,
      });
      batch.update(householdDocRef, {
        inviteCode: code,
        inviteCodeExpirationTime: expirationTimeTimestamp,
      });

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

export const removeInviteCode = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "The function must be called while authenticated.");
  }

  const householdId: string = data.householdId;
  if (!householdId) {
    throw new functions.https.HttpsError("invalid-argument", "The function must be called with a valid householdId.");
  }

  const db = admin.firestore();
  const householdDocRef = db.collection("households").doc(householdId);

  try {
    // Retrieve the household to get the invite code
    const householdDoc = await householdDocRef.get();
    if (!householdDoc.exists) {
      throw new functions.https.HttpsError("not-found", "Household not found.");
    }

    const inviteCode = householdDoc.data()?.inviteCode;
    if (!inviteCode) {
      throw new functions.https.HttpsError("not-found", "No invite code associated with this household.");
    }

    const inviteCodeDocRef = db.collection("inviteCodes").doc(inviteCode);

    // Begin transaction or batch to remove both documents
    const batch = db.batch();
    batch.delete(inviteCodeDocRef);
    batch.update(householdDocRef, {
      inviteCode: admin.firestore.FieldValue.delete(),
      inviteCodeExpirationTime: admin.firestore.FieldValue.delete(),
    });

    // Commit the batch
    await batch.commit();
    console.log("Invite code and references successfully removed.");
    return {success: true};
  } catch (error) {
    console.error("Error removing invite code: ", error);
    throw new functions.https.HttpsError("unknown", "Failed to remove invite code.", error);
  }
});
