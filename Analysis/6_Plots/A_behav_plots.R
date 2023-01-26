### This scripts makes the raincloud plots for
### DDM parameters, as well as RT and Accuracy 

### Clean up workspace ####
rm(list=ls(pos = ".GlobalEnv"), pos = ".GlobalEnv")
graphics.off()
par(mfrow=c(1,1))

### Load libraries ####
packages <- c(
  'tidyverse',
  'cowplot',
  'Rmisc',
  'see',
  'readxl',
  'reshape2'
)

packages.check <- lapply(
  packages,
  FUN = function(x) {
    if (!require(x, character.only = TRUE)) {
      install.packages(x, dependencies = TRUE)
      library(x, character.only = TRUE)
    }
  }
)

### Load Data ####
dat <- read_excel(paste0('PATHTOEXCEL'),"WinVars4Vivien.xlsx") # get path to winzorised variables
savePath <- 'SAVEPATH' # path to folder to save all plots

dat <- melt(dat, id.vars = c("ID"), variable.name = "nback") # transpose data
dat$nback <- as.factor(dat$nback) # n-back level as factor
dat$ID <- as.factor(dat$ID) # n-back level as factor

### Color palettes ####
BluePalette <- c("#90a9be","#477093")

### Plot Main Function ####
# dat - dataset with winzorised variables
# var - variable name
# colPlot - color palette for plot (should include 2 colors)
plot.main <- function(dat,var,colPlot) {
  
  # Define all variable names and axis tick
  if(var == "a") {
    x <- c("DGwin_HDDMwBias_a_2back","DGwin_HDDMwBias_a_3back")
    miny <- 1.2
    maxy <- 2.0
    limitsPlot <- c(miny,maxy)
    breaksPlot <- c(1.2,1.4,1.6,1.8,2.0)
    titleY <-  expression(paste("Boundary Separation (a)")) 
    
  } else if(var == "z"){
    x <- c("DGwin_HDDMwBias_z_2back","DGwin_HDDMwBias_z_3back")
    limitsPlot <- c(0.445,0.70)
    breaksPlot <- c(0.45, 0.5, 0.55, 0.60, 0.65, 0.70)
    titleY <-  expression(paste("Starting Point (z)")) 

  } else if(var == "t"){
    x <- c("DGwin_HDDMwBias_t_2back","DGwin_HDDMwBias_t_3back")
    miny <- 0.15
    maxy <- 0.90
    limitsPlot <- c(miny,maxy)
    breaksPlot <- c(0.15,0.30,0.45,0.60,0.75,0.90)
    titleY <-  expression(paste("Non-Decision Time (t)"))
    
  } else if(var == "dc"){
    x <- c("DGwin_HDDMwBias_dc_2back","DGwin_HDDMwBias_dc_3back")
    miny <- -0.80
    maxy <- 0
    limitsPlot <- c(miny,maxy)
    breaksPlot <- c(0,-0.2,-0.4,-0.6,-0.8)
    titleY <-  expression(paste("Drift Bias (dc)"))
    
  } else if(var == "v"){
    x <- c("DGwin_HDDMwBias_v_2back","DGwin_HDDMwBias_v_3back")
    limitsPlot <- c(0.0,2.4)
    breaksPlot <- seq(0.0,2.4,0.4)
    titleY <-  expression(paste("Drift Rate (v)"))
  
  } else if(var == "rt"){
    x <- c("DGwin_RT_2back","DGwin_RT_3back")
    miny <- 0.6 
    maxy <- 1.2
    limitsPlot <- c(miny,maxy)
    breaksPlot <- seq(miny,maxy,0.2) 
    titleY <-  expression(paste("RT"))
  } else if(deparse(substitute(dat)) == "rtsd"){
    x <- c("DGwin_RTsd_2back","DGwin_RTsd_3back")
    miny <- 0.10
    maxy <- 0.40
    limitsPlot <- c(miny,maxy)
    breaksPlot <- seq(miny,maxy,0.1) 
    titleY <-  expression(paste("RT"["SD"]))
  } else if(var == "acc"){
    x <- c("DGwin_ACC_2back","DGwin_ACC_3back")
    miny <- 0.4
    maxy <- 1
    limitsPlot <- c(miny,maxy)
    breaksPlot <- seq(miny,maxy,0.2) 
    titleY <-  expression(paste("Accuracy"))
  }
  
  # Select variables and plot
  dat_tmp <- dat[(dat$nback %in% x),]
  dat_tmp <- droplevels(dat_tmp) # drop all unused factor levels
  
  # Summarise data across subjects
  dat_summary <- summarySEwithin(data = dat_tmp, measurevar="value", withinvars="nback",idvar="ID",
                                 na.rm = FALSE, conf.interval = 0.95, .drop = TRUE)
  
  # plot
  plot <- dat_tmp %>% 
    ggplot(aes(x = nback, y = value, fill = nback)) +
    geom_line(aes(x = nback, y = value, group = ID), color = colPlot[1], alpha = .30,
              size=0.3,
              position = position_dodge2(width=0.2)) +
    geom_violinhalf(data= dat_tmp[dat_tmp$nback == x[1],],mapping=aes(fill = nback[1], color=nback[1]),
                    flip=T,
                    position= position_nudge(x =-0.22)
    ) +
    geom_violinhalf(data= dat_tmp[dat_tmp$nback == x[2],],mapping=aes(fill = nback[2], color=nback[2]),
                    flip=F,
                    position= position_nudge(x =0.22)
    ) +
    geom_point(aes(x = as.numeric(nback), y = value, group = ID, color=nback),
               position = position_dodge2(width=0.2),
               size = 1.8, shape = 16, alpha = 0.4) +
    geom_pointrange(data=dat_summary, aes(y = value, ymin=value-sd, ymax=value+sd),
                    color="white", size=1.3,fatten = 3,
                    position = position_nudge(x = c(-0.21,0.21))) +
    stat_summary(fun=mean, colour="black", geom="line", aes(group = 1),
                 size=0.5,
                 position= position_nudge(x =c(-0.24, 0.24))
    ) +
    geom_pointrange(data=dat_summary, aes(y = value, ymin=value-sd, ymax=value+sd),
                    color="black", size=1,fatten = 2,
                    position = position_nudge(x = c(-0.21,0.21)))+
    expand_limits(x = c(0,3), y = 0)+
    scale_fill_manual(values = colPlot) +
    scale_colour_manual(values = colPlot) +
    theme_cowplot() +
    theme(legend.position= "none",
          legend.title=element_blank(),
          axis.text.y = element_text(size = 12),
          axis.text.x = element_text(size = 14),
          axis.title = element_text(size = 18)) +
    scale_y_continuous(limits =limitsPlot, expand = c(0,0), breaks= breaksPlot,#c(1.2,1.7,2.2),
                       labels = function(x) sprintf("%.1f", x)) + #ifelse(x == 0, "0", x)
    labs(color = element_blank(),
         x = "Memory Load",
         y = titleY) + 
    scale_x_discrete(labels=c("2-back", "3-back"))
  
  plotName = var
  plotName = paste(substr(plotName,1,1))
  
  print(plot)
  
  ggsave(filename = paste0(savePath, plotName,"_",var,"_plot.svg"),
         plot = plot, width = 3, height = 3.5, device = "svg",unit = "in", dpi=300)
}



### Make plots ####
# select all variables we want to plot
all_vars <- c("a", "t", "z", "dc", "v",
                "rt", "rtsd","acc")

for (i in 1:length(all_vars)) {
  curr_var = all_vars[i]
  plot.main(dat,curr_var,colPlot=BluePalette)
}


