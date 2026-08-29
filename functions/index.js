const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");

initializeApp();

/**
 * Server-side half of the SOS + Alerts flow: the Flutter app can't push
 * straight to another user's device without a server key, so it just writes
 * the alert to `sos_alerts/{alertId}`. This function picks that up, looks up
 * each notified contact's stored FCM token under `users/{contactId}`, and
 * sends them the push.
 */
exports.sendSosAlert = onDocumentCreated("sos_alerts/{alertId}", async (event) => {
  const alert = event.data?.data();
  if (!alert) return;

  const firestore = getFirestore();
  const messaging = getMessaging();

  const contactIds = alert.notifiedContactIds || [];
  if (contactIds.length === 0) return;

  const contactDocs = await firestore.getAll(
    ...contactIds.map((id) => firestore.collection("users").doc(id))
  );

  const location =
    alert.latitude != null && alert.longitude != null
      ? `https://maps.google.com/?q=${alert.latitude},${alert.longitude}`
      : null;

  const tokens = contactDocs
    .map((doc) => doc.data()?.fcmToken)
    .filter((token) => !!token);

  if (tokens.length === 0) return;

  await messaging.sendEachForMulticast({
    tokens,
    notification: {
      title: "SOS Alert",
      body: location
        ? `A trusted contact needs help. Location: ${location}`
        : "A trusted contact needs help.",
    },
    data: {
      alertId: event.params.alertId,
      fromUserId: alert.userId || "",
      ...(location ? { location } : {}),
    },
  });
});
