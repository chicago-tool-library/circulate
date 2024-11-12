// If an element to highlight is declared in the document head, add a CSS class
// to highlight it. Remove the class when the highlight animation completes
// so it can be triggered on the same element again if needed.
export function highlightElement () {
  const metaTag = document.querySelector("meta[name='highlight-element']")
  if (metaTag) {
    const elementIDs = metaTag.getAttribute('content').split(',')
    elementIDs.forEach(elementID => {
      const element = document.getElementById(elementID)
      if (element) {
        element.addEventListener('animationend', function (event) {
          element.classList.remove('highlight')
        }, { once: true })
        element.classList.add('highlight')
      }
    })
  }
}
