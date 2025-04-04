# Install and load required packages
library(rsconnect)

# Obtain account information and add account to rsconnect
rsconnect::setAccountInfo(
  name='keni-17', 
  token='****', 
  secret='****'
)

# Prepare shiny app and deploy app based on file location
rsconnect::deployApp("C:/Users/kenic/OneDrive/Documents/GitHub/stat321-project/nflapp")

# note the deployment url for future reference
# url: <https://keni-17.shinyapps.io/nflapp/>