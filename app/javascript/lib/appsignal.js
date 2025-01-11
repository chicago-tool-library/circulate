import Appsignal from '@appsignal/javascript'

export const appsignal = new Appsignal({
  key: process.env.APPSIGNAL_FRONTEND_KEY,
})
