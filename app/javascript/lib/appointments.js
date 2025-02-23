// Given an appointment container, moves it into the appropriate list (either
// pending or completed).
export function arrangeAppointment(id) {
  const element = document.getElementById(id)
  const isCompleted = element.classList.contains('completed')
  const isPulled = element.classList.contains('pulled')
  let newParentSelector

  if (isCompleted) {
    newParentSelector = '.completed-appointments'
  } else if (isPulled) {
    newParentSelector = '.pulled-appointments'
  } else {
    newParentSelector = '.pending-appointments'
  }

  const newParent = document.querySelector(newParentSelector)

  // Insert before an element with a higher sort key
  const inserted = Array.from(newParent.children).some((appointment) => {
    if (appointment.dataset.sortKey > element.dataset.sortKey) {
      appointment.insertAdjacentElement('beforebegin', element)
      return true
    }
    return false
  })

  // If none is found, append to end of list. This also handled empty lists.
  if (!inserted) {
    newParent.appendChild(element)
  }
}
