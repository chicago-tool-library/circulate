import { Controller } from '@hotwired/stimulus'

const appId = ''
const locationId = ''

export default class extends Controller {
  static targets = ['cardContainer']

  // todo
  // standardize how errors are displayed
  // read square config from page meta tags

  async submit () {
    // validate the amount
    // disable submit button
    // call square to get card-nonce token
    // submit the price and card-nonce to backend
  }

  async generateToken () {
    const tokenResult = await this.card.tokenize()
    if (tokenResult.status === 'OK') {
      return tokenResult.token
    } else {
      let errorMessage = `Tokenization failed with status: ${tokenResult.status}`
      if (tokenResult.errors) {
        errorMessage += ` and errors: ${JSON.stringify(
          tokenResult.errors
        )}`
      }
      // throw new Error(errorMessage);
      return errorMessage
    }
  }

  async connect () {
    try {
      this.payments = window.Square.payments(appId, locationId)
    } catch (e) {
      const statusContainer = document.getElementById(
        'payment-status-container'
      )
      statusContainer.className = 'missing-credentials'
      statusContainer.style.visibility = 'visible'
      console.error(e)

      return
    }
    console.debug(this.cardContainerTarget)

    try {
      this.card = await this.payments.card()
      await this.card.attach(this.cardContainerTarget)
    } catch (e) {
      console.error('Initializing Card failed', e)
    }
  }

  disconnect () {
  }
}
