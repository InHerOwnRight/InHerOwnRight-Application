document.addEventListener('turbolinks:load', function(event) {
  if (typeof gtag === 'function') {
    gtag('config', 'UA-150192000-1', {
      'page_location': event.data.url
    })
  }
});
