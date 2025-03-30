# Step 1: Install and Load Required Packages
library(rsconnect)

# Step 2 and 3: Obtain Account Information and Add Your Account to rsconnect
rsconnect::setAccountInfo(
  name='keni-17', 
  token='****', 
  secret='****'
)

# Step 4 and 5: Prepare your Shiny App and Deploy your App
rsconnect::deployApp("C:/Users/kenic/OneDrive/Documents/GitHub/stat321-project/nflapp")

# url: <https://keni-17.shinyapps.io/nflapp/>
