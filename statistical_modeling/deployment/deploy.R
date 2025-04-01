library(rsconnect)

rsconnect::setAccountInfo(
  name='trista-d',
  token='******',
  secret='*****')

rsconnect::deployApp("./salary/")
rsconnect::deployApp("./touchdowns/")
