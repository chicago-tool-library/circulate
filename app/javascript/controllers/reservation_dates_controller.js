import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="reservation-dates"
export default class extends Controller {
  targets = ["startDate", "endDate"]
  connect() {
    console.log("ReservationDatesController connected");
    this.setMinEndDate();
  }

  setMinEndDate() {
    console.log("Setting min end date");
  }

  disableInvalidEndDates() {
    console.log("Disabling invalid dates");
    this.setMinEndDate();
  }
}
