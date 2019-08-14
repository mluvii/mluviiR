# Login using browser.
# To login via an api key generated in mluvii administration interface, see loginApiKey.R

library(httr)

mluvii_endpoint <- oauth_endpoint(NULL, authorize = "authorize", access = "token",
                                  base_url = "https://app.mluvii.com/login/connect")

client_app <- oauth_app('sessionsExample', key = 'publicApiNativeClient')

client_token <- oauth2.0_token(mluvii_endpoint, client_app,
                               scope = "mluviiPublicApi",
                               use_oob = TRUE, cache = FALSE)
