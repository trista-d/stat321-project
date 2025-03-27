library(dplyr)
library(readr)

data <- read_csv("final_clean_nfl.csv")
data <- arrange(data, data$Salary)
attach(data)


# MODEL 1: Salary ~ catchRate
boxplot(Salary)

plot(catchRate, Salary)

model <- lm(Salary~catchRate)
summary(model)

plot(catchRate, Salary)
abline(model, col="red")

qqnorm(model$residuals)
plot(model$fitted.values, model$residuals)
abline(h=0)


# Cap outliers
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

plot(catchRate, Salary)
abline(model, col="red")

# remove outliers
boxplot(Salary[1:80])

plot(catchRate[1:80], Salary[1:80])

model.rem <- lm(Salary[1:80]~catchRate[1:80])
summary(model.rem)

plot(catchRate[1:80], Salary[1:80])
abline(model.rem, col="red")

qqnorm(model.rem$residuals)
plot(model.rem$fitted.values, model.rem$residuals)
abline(h=0)


# box-cox transformation
# https://www.r-bloggers.com/2022/10/box-cox-transformation-in-r/
MASS::boxcox(model) # CI in plot does not contain 1, so continue with transform

# default = 6
options(digits=10)

b <- MASS::boxcox(model)
lambda <- b$x[which.max(b$y)]

b.salary <- (Salary^lambda - 1) / lambda

boxplot(b_salary)
plot(catchRate, b.salary)


b.model <- lm(b.salary~catchRate)
summary(b.model)

plot(catchRate, b.model)
abline(b.model, col="red")

qqnorm(b.model$residuals)
plot(b.model$fitted.values, b.model$residuals)
abline(h=0)

# best results from removing outliers, ok results from box-cox transformation


# OTHER MODELS
# remove Rec.1st, Rec.FUM, Salary (collinear)
new_data <- data %>% select(Rec, Yds, TD, X20., X40., X20.39, X1st.,
                            Rec.YAC.R, Tgts, catchRate)
pairs(new_data)

# Rec.YAC.R
plot(catchRate, Rec.YAC.R)
yac.catchrate <- lm(catchRate~Rec.YAC.R)
summary(yac.catchrate)
qqnorm(yac.catchrate$residuals)
plot(yac.catchrate$fitted.values, yac.catchrate$residuals)
abline(h=0)

model3 <- lm(TD ~ Rec * Yds)
summary(model3)


# Rec ~ Yds
plot(Rec~Yds)
rec.yds <- glm(Rec ~ Yds, family='poisson')
summary(rec.yds)

qqnorm(rec.yds$residuals)
plot(rec.yds$fitted.values, rec.yds$residuals)
abline(h=0)

# POISSON MODELS:
# TD ~ Yds
hist(TD)
plot(TD~Yds)
td.yds <- glm(Rec ~ Yds, family='poisson')
summary(td.yds)

qqnorm(td.yds$residuals)
plot(td.yds$fitted.values, td.yds$residuals)
abline(h=0)


# TD ~ Rec.1st
hist(TD)
plot(TD ~ Rec.1st)
td.rec.1st <- glm(TD ~ Rec.1st, family='poisson')
summary(td.rec.1st)

qqnorm(td.rec.1st$residuals)
plot(td.rec.1st$fitted.values, td.rec.1st$residuals)
abline(h=0)

# TODO
# predict top/bottom salaries + other values for models
# k-means clustering?

# stepwise selection for multiple regression (don't have to visualize)
# step-wise selection to predict TD
td_model_data <- data[,c(-1, -2, -5)]
# td_model_data$Salary <- b.salary

full_model <- lm(TD~., data=td_model_data)
s <- step(full_model, direction="backward")
summary(s)
plot(s)

