import Appsignal from "@appsignal/javascript"
import { plugin as pathDecoratorPlugin } from "@appsignal/plugin-path-decorator"
import { plugin as breadcrumbsConsolePlugin } from "@appsignal/plugin-breadcrumbs-console"
import { plugin as breadcrumbsNetworkPlugin } from "@appsignal/plugin-breadcrumbs-network"
 
export const appsignal = new Appsignal({key: process.env.APPSIGNAL_FRONTEND_KEY})

appsignal.use(pathDecoratorPlugin())
appsignal.use(breadcrumbsConsolePlugin())
appsignal.use(breadcrumbsNetworkPlugin())