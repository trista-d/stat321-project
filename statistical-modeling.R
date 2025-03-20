library(dplyr)
library(readr)

data <- read_csv("final_clean_nfl.csv")
data <- arrange(data, data$Salary)
attach(data)




boxplot(Salary)
#boxplot(log(Salary))

# capping outliers
q1 <- quantile(Salary, 0.25)
q3 <- quantile(Salary, 0.75)
iqr <- q3 - q1
lower <- q1 - 1.5*iqr
upper <- q3 + 1.5*iqr


sal <- ifelse(Salary < lower, lower,
                 ifelse(Salary > upper, upper, Salary))

boxplot(sal)
plot(catchRate, sal)

model2 <- lm(sal~catchRate)
summary(model2)

qqnorm(model2$residuals)
plot(model2$fitted.values, model2$residuals)
abline(h=0)

# predict top/bottom salaries
# start with all variables, cut them out

boxplot(Salary[1:80])

plot(catchRate[1:80], Salary[1:80])
plot(catchRate[1:80], log(Salary[1:80]))



model <- lm(Salary[1:80]~catchRate[1:80])
summary(model)

qqnorm(model$residuals)
plot(model$fitted.values, model$residuals)
abline(h=0)
