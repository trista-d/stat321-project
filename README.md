# NFL Receiver Performance Analysis
## Data
https://www.nfl.com/stats/player-stats/category/receiving/2024/REG/all/receivingreceptions/DESC
https://www.spotrac.com/nfl/rankings/player/_/year/2024/sort/cap_base

## Report
https://drive.google.com/drive/folders/1dXceNzpAEclrKUWVYZj2N565gyCdMTWv?usp=sharing

## Variables
- Rec - # receptions
- Yds - total yards
- TD - receiving touchdowns
- X20 - # rec over 20 yds
- X40 - # rec over 40 yds
- X20.39 # rec between 20 - 39 yds
- Rec.1st - # rec that were 1st downs
- 1st - % rec that were 1st downs = Rec.1st/Rec
- rec.fum - # rec that were fumbles
- YAC.R - receiving yards after catch
- Tgts - # times passed to
- catchRate - Rec / Tgts

## Models
  1. Salary ~ catchRate
      - no changes
      - capped outliers
      - removed outliers
      - box-cox transformation
  2. TD ~ Yds
  3. Step-wise models
    - TD ~ X40. + Rec.1st + Tgts
    - Salary ~ Rec + Yds + TD + Rec.YAC.R
  
  
