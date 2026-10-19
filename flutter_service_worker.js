self.addEventListener('install', function(event) { self.skipWaiting(); });
self.addEventListener('activate', function(event) {
  event.waitUntil(
    caches.keys().then(function(cacheNames) {
      return Promise.all(cacheNames.map(function(c) { return caches.delete(c); }));
    }).then(function() { return self.registration.unregister(); })
  );
});
