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
  'reshape2',
  'R.matlab'
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

### behavioural data ####
dat <- read_excel(paste0('PATHTOEXCEL'),"WinVars4Vivien.xlsx") # get path to winzorised variables
savePath <- 'SAVEPATH'# path to folder to save all plots

dat <- melt(dat, id.vars = c("ID"), variable.name = "nback") # transpose data
dat$nback <- as.factor(dat$nback) # n-back level as factor
dat$ID <- as.factor(dat$ID) # n-back level as factor

### SD Bold Data ####
plsDat <- readMat('masked_taskPLSN152_allNets.mat')
plsDat <- as.data.frame(plsDat)
plsDat <- plsDat*-1
plsDat$ID <- rownames(plsDat)

plsDat <- melt(plsDat, id.vars = c("ID"), variable.name = "nback") # transpose data
plsDat$nback <- as.factor(plsDat$nback) # n-back level as factor
plsDat$ID <- as.factor(plsDat$ID) # n-back level as factor

### PCAdim Data ####
pcaDat <- readMat("CobraN152_PCAdim_temp_allNets.mat")
pcaDat$ID <- NULL
pcaDat <- as.data.frame(pcaDat)
pcaDat$ID <- rownames(pcaDat)

pcaDat <- melt(pcaDat, id.vars = c("ID"), variable.name = "nback") # transpose data
pcaDat$nback <- as.factor(pcaDat$nback) # n-back level as factor
pcaDat$ID <- as.factor(pcaDat$ID) # n-back level as factor


### Color palettes ####
BluePalette <- c("#90a9be","#477093") # Behav
GreenPalette <- c("#659652","#43724A") # PLS
pcaPallette <- c("#5f9ea0", "#49796b")
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
  } else if(var == "vis_pls"){
    x <- c("BS.vis.1","BS.vis.2")
    miny <- 12
    maxy <- 58
    limitsPlot <- c(miny,maxy)
    breaksPlot <- seq(miny,maxy,11) 
    titleY <-  expression(paste("SD"["BOLD Visual"]))
  } else if(var == "dan_pls"){
    x <- c("BS.DAN.1","BS.DAN.2")
    miny <- 5
    maxy <- 30
    limitsPlot <- c(miny,maxy)
    breaksPlot <- seq(miny,maxy,5) 
    titleY <-  expression(paste("SD"["BOLD DAN"]))
  } else if(var == "fpn_pls"){
    x <- c("BS.FPN.1","BS.FPN.2")
    miny <- 2
    maxy <- 20
    limitsPlot <- c(miny,maxy)
    breaksPlot <- seq(miny,maxy,6) 
    titleY <-  expression(paste("SD"["BOLD FPN"]))
  } else if(var == "dmn_pls"){
    x <- c("BS.DMN.1","BS.DMN.2")
    miny <- 5
    maxy <- 30
    limitsPlot <- c(miny,maxy)
    breaksPlot <- seq(miny,maxy,5) 
    titleY <-  expression(paste("SD"["BOLD DMN"]))
  } else if(var == "st_pls"){
    x <- c("BS.BGHAT.Morel.1","BS.BGHAT.Morel.2")
    miny <- 0.3
    maxy <- 1.5
    limitsPlot <- c(miny,maxy)
    breaksPlot <- seq(miny,maxy,0.5) 
    titleY <-  expression(paste("SD"["BOLD Striato-thalamic"]))
  } else if(var == "st_pca"){
    x <- c("PCAdim.BGHAT.2","PCAdim.BGHAT.3")
    miny <- 13
    maxy <- 25
    limitsPlot <- c(miny,maxy)
    breaksPlot <- seq(miny,maxy,4) 
    titleY <-  expression(paste("PCAdim"[" Striato-thalamic"]))
  } else if(var == "vis_pca"){
    x <- c("PCAdim.Vis.2","PCAdim.Vis.3")
    miny <- 6
    maxy <- 23
    limitsPlot <- c(miny,maxy)
    breaksPlot <- seq(miny,maxy,4) 
    titleY <-  expression(paste("PCAdim"[" Visual"]))
  } else if(var == "dan_pca"){
    x <- c("PCAdim.DAN.2","PCAdim.DAN.3")
    miny <- 7
    maxy <- 23
    limitsPlot <- c(miny,maxy)
    breaksPlot <- seq(miny,maxy,4) 
    titleY <-  expression(paste("PCAdim"[" DAN"]))
  } else if(var == "fpn_pca"){
    x <- c("PCAdim.FPN.2","PCAdim.FPN.3")
    miny <- 10
    maxy <- 24
    limitsPlot <- c(miny,maxy)
    breaksPlot <- seq(miny,maxy,4) 
    titleY <- expression(paste("PCAdim"[" FPN"]))
  } else if(var == "dmn_pca"){
    x <- c("PCAdim.DMN.2","PCAdim.DMN.3")
    miny <- 11
    maxy <- 24
    limitsPlot <- c(miny,maxy)
    breaksPlot <- seq(miny,maxy,4) 
    titleY <-  expression(paste("PCAdim"[" DMN"]))
  }
  
  # Select variables and plot
  dat_tmp <- dat[(dat$nback %in% x),]
  
  dat_tmp <- droplevels(dat_tmp) # drop all unused factor levels

  # Summarise data across subjects
  dat_summary <- summarySEwithin(data = dat_tmp, measurevar="value", withinvars="nback",idvar="ID",
                                 na.rm = FALSE, conf.interval = 0.95, .drop = TRUE)
  print(dat_summary)
  
  # Calculate two-sided paired t-test
  nback2 = dat_tmp$value[dat_tmp$nback == unique(dat_tmp$nback)[1]]
  nback3 = dat_tmp$value[dat_tmp$nback == unique(dat_tmp$nback)[2]]
  print(t.test(nback2, nback3, paired = TRUE, alternative = "two.sided"))
  
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
                       labels = function(x) sprintf("%.0f", x)) + #ifelse(x == 0, "0", x)
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

### Make Brain Plots ####
all_vars <- c("vis_pls", "fpn_pls", "dmn_pls", "dan_pls", "st_pls")
for (i in 1:length(all_vars)) {
  curr_var = all_vars[i]
  plot.main(plsDat,curr_var,colPlot=GreenPalette)
}


all_vars <- c("vis_pca", "fpn_pca", "dmn_pca", "dan_pca", "st_pca")
for (i in 1:length(all_vars)) {
  curr_var = all_vars[i]
  plot.main(pcaDat,curr_var,colPlot=pcaPallette)
}

