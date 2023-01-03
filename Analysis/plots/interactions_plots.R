## This script makes the interaction plots based on data
## in 2-way_unstandardised_PCAdimxmeanRT_onSDBOLDchange_3min2.xlxs
## Data is extracted manually from interaction excel sheet

### Clean up workspace ####
rm(list=ls(pos = ".GlobalEnv"), pos = ".GlobalEnv")
graphics.off()
par(mfrow=c(1,1))

### Load libraries ####
packages <- c(
  'tidyverse',
  'cowplot')

packages.check <- lapply(
    packages,
    FUN = function(x) {
      if (!require(x, character.only = TRUE)) {
        install.packages(x, dependencies = TRUE)
        library(x, character.only = TRUE)
      }
    }
)


### Set path ####
savePath <- 'SAVEPATH' # path to folder to save all plots

### Colors for plots ####
col_DA_DC <- c("#FBB91FFF")
col_DIM_A <- c("#300A5BFF")
col_DIM_V <- c("#5C162EFF")
col_DIM_T <- c("#87216BFF")
col_DIM_V_FPN <- c("#9C2964FF")
col_DA_DAN <- c("#F8870EFF")

### Main Plot ####
plot.main <- function(dat,colPlot) {
  
  df <- data.frame (yVar  = dat,
                    xVar = as.factor(c(1,1,2,2)),
                    ID = as.factor(c(1,2,1,2)))
  titleY <- expression(paste(Delta, "SD"["BOLD"]))
  
  if(deparse(substitute(dat)) == "DA_DC") {
    limitsPlot <- c(-0.03,0.04)
    breaksPlot <- seq(limitsPlot[1],limitsPlot[2], 0.01)
    titleX <- "Dopamine"
    labelsX <- c("Low", "High")
    labTitle <- "Drift Bias (dc)"
    labGroup <- c("Maintain drift bias towards 'No'", "Revert drift bias back to 'Yes'")
    legPos <-c(.45, .95)
    legJus <- c("left", "top")
    legBox <- "right"
    
  } else if(deparse(substitute(dat)) == "DIM_A"){
    limitsPlot <- c(-0.1,0.08)
    breaksPlot <- seq(limitsPlot[1],limitsPlot[2], 0.02)
    titleX <- "Dimensionality"
    labelsX <- c("Integrate", "Segregate")
    labTitle <- "Boundary  \nSeparation (a)"
    labGroup <- c("Collapse", "Maintain")
    legPos <-c(.45, .95)
    legJus <- c("left", "top")
    legBox <- "right"

  } else if(deparse(substitute(dat)) == "DIM_V"){
    limitsPlot <- c(-0.1,0.08)
    breaksPlot <- seq(limitsPlot[1],limitsPlot[2], 0.02)
    titleX <- "Dimensionality"
    labelsX <- c("Integrate", "Segregate")
    labTitle <- "Drift Rate (v)"
    labGroup <- c("Lose", "Maintain")
    legPos <-c(.45, .95)
    legJus <- c("left", "top")
    legBox <- "right"
    
  } else if(deparse(substitute(dat)) == "DIM_T"){
    limitsPlot <- c(-0.1,0.08)
    breaksPlot <- seq(limitsPlot[1],limitsPlot[2], 0.02)
    titleX <- "Dimensionality"
    labelsX <- c("Integrate", "Segregate")
    labTitle <- "Non-Decision Time (t)"
    labGroup <- c("Maintain", "Increase")
    legPos <-c(.45, .95)
    legJus <- c("left", "top")
    legBox <- "right"
    
  } else if(deparse(substitute(dat)) == "DIM_V_FPN"){
    limitsPlot <- c(-1,1.2)
    breaksPlot <- seq(limitsPlot[1],limitsPlot[2], 0.2)
    titleX <- "Dimensionality"
    labelsX <- c("Integrate", "Segregate")
    labTitle <- "Drift Rate (v)"
    labGroup <- c("Lose", "Maintain")
    titleY <- expression(paste("FPN ",Delta, "SD"["BOLD"]))
    legPos <-c(.45, .95)
    legJus <- c("left", "top")
    legBox <- "right"
    
  } else if(deparse(substitute(dat)) == "DA_A_DAN"){
    limitsPlot <- c(-0.3,0.6)
    breaksPlot <- seq(limitsPlot[1],limitsPlot[2], 0.1)
    titleX <- "Dopamine"
    labelsX <- c("Low", "High")
    labTitle <- "Boundary \nSeparation (a)"
    labGroup <- c("Collapse", "Maintain")
    titleY <- expression(paste("DAN ",Delta, "SD"["BOLD"]))
    legPos <-c(.35, .95)
    legJus <- c("right", "top")
    legBox <- "left"
  }
  
 plot <- df %>%
    ggplot(aes(x=xVar, y=yVar, group=ID,alpha=ID)) +
    geom_path(aes(alpha=ID),
              color= colPlot,
              size=2,
              #position= position_nudge(x =-0.3)
              ) +
    expand_limits(x = 1, y = 0)+
    geom_hline(yintercept = 0,linetype = "dashed") +
   scale_alpha_manual(values = c(0.5,1),labels=labGroup)+
    theme_cowplot() +
    theme(axis.text.y = element_text(size = 12),
          axis.text.x = element_text(size = 14),
          axis.title = element_text(size = 18),
          legend.position = 'bottom',
          legend.justification = legJus,
         legend.box.just = legBox,
          legend.text=element_text(size=09),
         legend.title =element_text(size=10)
         ) +
   guides(alpha = guide_legend(nrow = 2, byrow = TRUE))+
    scale_y_continuous(limits =limitsPlot, expand = c(0,0), breaks= breaksPlot,#c(1.2,1.7,2.2),
                       labels = function(x) sprintf("%.2f", x)) + #ifelse(x == 0, "0", x)
    labs(alpha = labTitle,#element_blank(),
         x = titleX,
         y = titleY
         ) + 
    scale_x_discrete(labels=labelsX)
  
  ggsave(filename = paste0(savePath,deparse(substitute(dat)),"interaction.svg"),
         plot = plot, width = 5, height = 6, device = "svg",unit = "in", dpi=300)
  
  return(plot)
}

### Make Plots #####
DA_DC <- c(-0.019343671, -0.027620017, 0.032139823, -0.015757104)
plot.main(DA_DC,col_DA_DC)

DIM_A <- c(0.064106877, 0.027004379, -0.075197022, -0.046495203)
plot.main(DIM_A,col_DIM_A)

DIM_V <- c(0.035140429, 0.055970826, -0.051048972, -0.070643253)
plot.main(DIM_V,col_DIM_V)

DIM_T <- c(0.061687486, 0.02942377, -0.072682834, -0.049009391)
plot.main(DIM_T,col_DIM_T)

DIM_V_FPN <- c(0.45412228, 0.990853117, -0.635840613, -0.749460341)
plot.main(DIM_V_FPN,col_DIM_V_FPN)

DA_A_DAN <- c(-0.141, -0.209, 0.519, -0.189)
plot.main(DA_A_DAN,col_DA_DAN)

