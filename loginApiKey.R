# Login using api key generated in mluvii administration interface.
# To login via browser (oob), see loginOOB.R

library(httr)

mluvii_endpoint <- oauth_endpoint(NULL, authorize = NULL, access = "token",
                                  base_url = "https://app.mluvii.com/login/connect")

client_app <- oauth_app('sessionsExample',
                        key = '...',
                        secret = '...')

client_token <- oauth2.0_token(mluvii_endpoint, client_app,
                               client_credentials = TRUE)
