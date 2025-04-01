library(rsconnect)

rsconnect::setAccountInfo(
  name='trista-d',
  token='E229A847143AB6D5FFC7EC12AF3A9FB4',
  secret='oe8kGrZZxSvUayAXyK2Txkf7EDmbq1VIwRyUsa22')

rsconnect::deployApp("./salary/")
rsconnect::deployApp("./touchdowns/")
