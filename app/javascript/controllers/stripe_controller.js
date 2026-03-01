import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['elements', 'errors']
  static values = {
    intentSecret: String,
    returnUrl: String,
  }

  connect() {
    this.clientKey = document
      .querySelector('meta[name=stripe-client-key')
      .getAttribute('content')
    this.client = Stripe(this.clientKey)

    const options = {
      clientSecret: this.intentSecretValue,
      // Fully customizable with appearance API.
      appearance: {
        /*...*/
      },
    }

    // Set up Stripe.js and Elements using the SetupIntent's client secret
    this.elements = this.client.elements(options)

    // Create and mount the Payment Element
    const paymentElementOptions = { layout: 'accordion' }
    const paymentElement = this.elements.create(
      'payment',
      paymentElementOptions
    )
    paymentElement.mount(this.elementsTarget)
  }

  async submit(event) {
    event.preventDefault()

    const { error } = await this.client.confirmSetup({
      elements: this.elements,
      confirmParams: {
        return_url: this.returnUrlValue,
      },
    })

    if (error) {
      // This point will only be reached if there is an immediate error when
      // confirming the payment. Show error to your customer (for example, payment
      // details incomplete)
      this.errorsTarget.textContent = error.message
    } else {
      // Your customer will be redirected to your `return_url`. For some payment
      // methods like iDEAL, your customer will be redirected to an intermediate
      // site first to authorize the payment, then redirected to the `return_url`.
    }
  }

  disconnect() {}
}
