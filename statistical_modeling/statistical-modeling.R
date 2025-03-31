library(dplyr)
library(readr)

data <- read_csv("../final_clean_nfl.csv")
data <- arrange(data, data$Salary)
attach(data)


# MODEL 1: Salary ~ catchRate
# plot histograms (or boxplots) of each salary
boxplot(Salary)
hist(Salary)

model1 <- lm(Salary~catchRate)
summary(model1)

plot(catchRate, Salary)
abline(model1, col="red")

qqnorm(model1$residuals)
qqline(model1$residuals)
plot(model1$fitted.values, model1$residuals)
abline(h=0)


# MODEL 1 - CAPPED OUTLIERS
q1 <- quantile(Salary, 0.25)
q3 <- quantile(Salary, 0.75)
iqr <- q3 - q1
lower <- q1 - 1.5*iqr
upper <- q3 + 1.5*iqr

capped_sal <- ifelse(Salary < lower, lower,
               ifelse(Salary > upper, upper, Salary))

boxplot(capped_sal)
hist(capped_sal)

model2 <- lm(capped_sal~catchRate)
summary(model2)

qqnorm(model2$residuals)
qqline(model2$residuals)
plot(model2$fitted.values, model2$residuals)
abline(h=0)

plot(catchRate, capped_sal)
abline(model2, col="red")


# MODEL 1 - REMOVED OUTLIERS
removed_sal <- Salary[1:80]

boxplot(removed_sal)
hist(removed_sal)

model.rem <- lm(Salary~catchRate, data=data.frame(Salary=Salary[1:80], 
                                                  catchRate=catchRate[1:80]))
summary(model.rem)

plot(catchRate[1:80], removed_sal)
abline(model.rem, col="red")

# check residuals
qqnorm(model.rem$residuals)
qqline(model.rem$residuals)
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

boxplot(b.salary)
plot(catchRate, b.salary)

b.model <- lm(b.salary~catchRate)
summary(b.model)

plot(catchRate, b.salary)
abline(b.model, col="red")

qqnorm(b.model$residuals)
qqline(b.model$residuals)
plot(b.model$fitted.values, b.model$residuals)
abline(h=0)


# AIC to compare models
AIC(model.rem)
AIC(model1, model2, b.model)

# box-cox has lowest AIC, but removed outliers has lowest adjusted R^2
# (can't compare two models with different # of observations)


# OTHER MODELS
# Explore possible relationships
# remove Rec.1st, Rec.FUM, Salary (collinear, outliers)
new_data <- data %>% select(Rec, Yds, TD, X20., X40., X20.39, X1st.,
                            Rec.YAC.R, Tgts, catchRate)
pairs(new_data)

# Rec.YAC.R (Not Using)
# plot(catchRate, Rec.YAC.R)
#yac.catchrate <- lm(catchRate~Rec.YAC.R)
# summary(yac.catchrate)
# qqnorm(yac.catchrate$residuals)
# plot(yac.catchrate$fitted.values, yac.catchrate$residuals)
# abline(h=0)


# POISSON MODELS
# Rec ~ Yds
hist(Rec)

rec.yds <- glm(Rec ~ Yds, family='poisson')
summary(rec.yds)

qqnorm(rec.yds$residuals)
qqline(rec.yds$residuals)

plot(rec.yds$fitted.values, rec.yds$residuals)
abline(h=0)

plot(Rec~Yds)
lines(x=Yds, y=predict(rec.yds, data, type = "response")*10, col="red")



# TD ~ Yds
hist(TD)

td.yds <- glm(TD ~ Yds, family='poisson')
summary(td.yds)

plot(TD~Yds)

qqnorm(td.yds$residuals)
qqline(td.yds$residuals)
plot(td.yds$fitted.values, td.yds$residuals)
abline(h=0)


# TD ~ Rec.1st (Not Using)
#hist(TD)
#plot(TD ~ Rec.1st)
#td.rec.1st <- glm(TD ~ Rec.1st, family='poisson')
#summary(td.rec.1st)
#qqnorm(td.rec.1st$residuals)
#plot(td.rec.1st$fitted.values, td.rec.1st$residuals)
#abline(h=0)


# MULTIPLE REGRESSION
# step-wise selection on TD
td_model_data <- data[,c(-1, -2, -5, -13)]

full_td_model <- lm(TD~., data=td_model_data)
td_step <- step(full_td_model, direction="backward")
summary(td_step)

qqnorm(td_step$residuals)
qqline(td_step$residuals)
plot(td_step$fitted.values, td_step$residuals)
abline(h=0)

# step-wise selection on Salary
sal_model_data <- data[,c(-1, -2, -13, -14)]
full_sal_model <- lm(Salary~., data=sal_model_data)

sal_step <- step(full_sal_model, direction="backward")
summary(sal_step)

qqnorm(sal_step$residuals)
qqline(sal_step$residuals)
plot(sal_step$fitted.values, sal_step$residuals)
abline(h=0)


# DASHBOARDS 
# Source: https://rstudio.github.io/DT/options.html
library(DT)

# predict salaries from catchRate (using best model 1)
pred_salary <- data.frame(Player=Player[1:80],
                          catchRate=round(catchRate[1:80], 3),
                          predicted=round(predict(model.rem, newdata=data.frame(
                            catchRate=catchRate[1:80]))),
                          actual=removed_sal)

# predict touchdowns (using step-wise model)
pred_td <- data.frame(Player=Player, Rec.over.40.yds=X40., Rec.1st=Rec.1st, 
                      Tgts=Tgts, predicted=round(predict(td_step, 
                                newdata=data.frame(X40.=X40., Rec.1st=Rec.1st,
                                                   Tgts=Tgts),type='response')),
                      actual=TD)

# export prediction data
write.csv(pred_salary, "./salary_predictions.csv")
write.csv(pred_td, "./td_predictions.csv")
