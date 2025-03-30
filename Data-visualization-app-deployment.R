# Step 1: Install and Load Required Packages
library(rsconnect)

# Step 2 and 3: Obtain Account Information and Add Your Account to rsconnect
rsconnect::setAccountInfo(
  name='keni-17', 
  token='C1B0A00830B4DAEF7074432A817D23C2', 
  secret='75HamsLrxEH4wwkEqxpW9vnrRlzsfmVk+Kbtb0Ia'
)

# Step 4 and 5: Prepare your Shiny App and Deploy your App
rsconnect::deployApp("C:/Users/kenic/OneDrive/Documents/4/STAT321/Labs/Lab 4")

# url: <https://keni-17.shinyapps.io/lab_4/>
