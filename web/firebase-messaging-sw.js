importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

// We need to initialize the app here for background messages on Web
firebase.initializeApp({
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_AUTH_DOMAIN",
  projectId: "shopspot-influencer",
  storageBucket: "YOUR_STORAGE_BUCKET",
  messagingSenderId: "631713688963",
  appId: "YOUR_APP_ID",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png',
    data: payload.data // Pass structured payload into notification data
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});

self.addEventListener('notificationclick', function(event) {
  event.notification.close();

  const payloadData = event.notification.data;
  const targetUrl = '/'; // Can be customized based on route in payload if needed

  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then(function(clientList) {
      // If a window is already open, focus it and send payload
      for (let i = 0; i < clientList.length; i++) {
        const client = clientList[i];
        if (client.url.includes(self.registration.scope) && 'focus' in client) {
          client.postMessage({ type: 'FCM_NOTIFICATION_CLICK', data: payloadData });
          return client.focus();
        }
      }
      
      // If no window is open, open a new one
      if (clients.openWindow) {
        // Here we could append query parameters ?route=... based on payload
        return clients.openWindow(targetUrl);
      }
    })
  );
});
