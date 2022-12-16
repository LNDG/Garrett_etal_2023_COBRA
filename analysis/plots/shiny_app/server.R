# load shiny library
library(shiny)


# set up back end
shinyServer(function(input, output) {

  # load the data
  amlData <-  read.csv("data4correlation.csv")
  library(tidyverse)
  library(cowplot)
  library(ggpubr)
 #install.packages("ggpubr", repos = "https://cloud.r-project.org/", dependencies = TRUE)

  
   ### axis names ####
   axis_labels <- list(
    "D2 Striatum" = "Z_DGwin_SEM_striatum",
    "ΔSDBold Striato-thalamic" = "Z_DGwin_BS_SD3min2_with_DA",
    "ΔSDBold Visual" = "Z_DGwin_TaskSD_avg_Yeo1_Vis_32change",
    "ΔSDBold DAN" = "Z_DGwin_TaskSD_avg_Yeo3_DAN_32change",
    "ΔSDBold FPN" = "Z_DGwin_TaskSD_avg_Yeo6_FPN_32change",
    "ΔSDBold DMN" = "Z_DGwin_TaskSD_avg_Yeo7_DMN_32change",
    "ΔPCAdim Striato-thalamic" = "Z_DGwin_PCAdimTEMP_BGHATMorel_32change",
    "ΔPCAdim Visual" = "Z_DGwin_PCAdimTEMP_Yeo1_Vis_32change",
    "ΔPCAdim DAN" = "Z_DGwin_PCAdimTEMP_Yeo3_DAN_32change",
    "ΔPCAdim FPN" ="Z_DGwin_PCAdimTEMP_Yeo6_FPN_32change",
    "ΔPCAdim DMN" = "Z_DGwin_PCAdimTEMP_Yeo7_DMN_32change",
    "ΔBoundary Separation (a)" = "Z_DGwin_HDDMwBias_a_3min2back",
    "ΔDrift Rate (v)" = "Z_DGwin_HDDMwBias_v_3min2back",
    "ΔNon-Decision Time (t)" = "Z_DGwin_HDDMwBias_t_3min2back",
    "ΔStarting Point (z)" = "Z_DGwin_HDDMwBias_z_3min2back",
    "ΔDrift Criterion (dc)" = "Z_DGwin_HDDMwBias_dc_3min2back",
    "2-back SDBold Striato-thalamic" = "DGwin_TaskSD_avg_BGHATMorel_2back",
    "3-back SDBold Striato-thalamic" = "DGwin_TaskSD_avg_BGHATMorel_3back",
    "2-back SDBold Visual" = "DGwin_TaskSD_avg_Yeo1_Vis_2back",
    "3-back SDBold Visual" = "DGwin_TaskSD_avg_Yeo1_Vis_3back",
    "2-back SDBold DAN" = "DGwin_TaskSD_avg_Yeo3_DAN_2back",
    "3-back SDBold DAN" = "DGwin_TaskSD_avg_Yeo3_DAN_3back",
    "2-back SDBold FPN" = "DGwin_TaskSD_avg_Yeo6_FPN_2back",
    "3-back SDBold FPN" = "DGwin_TaskSD_avg_Yeo6_FPN_3back",
    "2-back SDBold DMN" = "DGwin_TaskSD_avg_Yeo7_DMN_2back",
    "3-back SDBold DMN" = "DGwin_TaskSD_avg_Yeo7_DMN_3back",
    "2-back PCAdim Striato-thalamic" = "DGwin_PCAdimTEMP_BGHATMorel_2back",
    "3-back PCAdim Striato-thalamic" = "DGwin_PCAdimTEMP_BGHATMorel_3back",
    "2-back PCAdim Visual" = "DGwin_PCAdimTEMP_Yeo1_Vis_2back",
    "3-back PCAdim Visual" = "DGwin_PCAdimTEMP_Yeo1_Vis_3back",
    "2-back PCAdim DAN" = "DGwin_PCAdimTEMP_Yeo3_DAN_2back",
    "3-back PCAdim DAN" = "DGwin_PCAdimTEMP_Yeo3_DAN_3back",
    "2-back PCAdim FPN" = "DGwin_PCAdimTEMP_Yeo6_FPN_2back",
    "3-back PCAdim FPN" = "DGwin_PCAdimTEMP_Yeo6_FPN_3back",
    "2-back PCAdim DMN" = "DGwin_PCAdimTEMP_Yeo7_DMN_2back",
    "3-back PCAdim DMN" = "DGwin_PCAdimTEMP_Yeo7_DMN_3back",
    "2-back Boundary Separation (a)" = "DGwin_HDDMwBias_a_2back",
    "3-back Boundary Separation (a)" = "DGwin_HDDMwBias_a_3back",
    "2-back Drift Rate (v)" = "DGwin_HDDMwBias_v_2back",
    "3-back Drift Rate (v)" = "DGwin_HDDMwBias_v_3back",
    "2-back Non-Decision Time (t)"= "DGwin_HDDMwBias_t_2back",
    "3-back Non-Decision Time (t)"= "DGwin_HDDMwBias_t_3back",
    "2-back Drift Criterion (dc)" = "DGwin_HDDMwBias_dc_2back",
    "3-back Drift Criterion (dc)" = "DGwin_HDDMwBias_dc_3back",
    "2-back RT" = "meanRT2",
    "3-back RT" = "meanRT3",
    "ΔRT" = "meanRT3min2",
    "2-back RT (SD)" = "sdRT2",
    "3-back RT (SD)" = "sdRT3",
    "ΔRT (SD)" = "sdRT3min2",
    "2-back Accuracy" = "accuracy2",
    "3-back Accuracy" ="accuracy3",
    "ΔAccuracy" = "accuracy3min2",
    "Digit Symbol (WAIS)" = "WAISscoren.o.correct",
    "Education"="eduy",
    "Age" = "agewave1",
    "Working Memory" = "WM",
    "Speed" ="Speed")
   


  # construct a plot to show the data ####
  output$scatterPlot <- renderPlot({

    res1 <- cor.test(amlData[[input$x_axis]], 
                     amlData[[input$y_axis]], 
                     method="pearson")
    
    res2 <- cor.test(amlData[[input$x_axis]], 
                     amlData[[input$y_axis]], 
                     method="spearman")
    
    title_r1_1 = paste0(" ","Pearson correlation = ",
                        sprintf("%.2f", res1$estimate),
                        ", p < 0.001")
    
    title_r1_2 = paste0(" ","Pearson correlation = ",
                        sprintf("%.2f", res1$estimate),
                        ", p = ",
                        sprintf("%.3f", res1$p.value))
    
    
    title_r2_1 = paste0("\n Spearman correlation = ", 
                        sprintf("%.2f", res2$estimate),
                        ", p < 0.001")
    
    title_r2_2 = paste0("\n Spearman correlation = ", 
                        sprintf("%.2f", res2$estimate),
                        ", p = ",sprintf("%.3f", res2$p.value))
    
    p1 <- ggplot(amlData, aes_string(x=input$x_axis, y=input$y_axis)) + 
          geom_point(size=4, alpha = 0.6,shape=19) + 
          theme_cowplot() +
          geom_smooth(method = "lm",se = FALSE, color = "deeppink", size=1.5) +
          theme(axis.title = element_text(size = 16),
            axis.text = element_text(size = 16),
            plot.title = element_text(size= 14,face = "plain", margin=margin(b=0,t=20)),
            plot.subtitle= element_text(size= 14,face = "plain",margin=margin(t=-10, b=10))) +
          labs(x = names(axis_labels[which(axis_labels == input$x_axis)]), 
               y = names(axis_labels[which(axis_labels == input$y_axis)]))+
      ggtitle(label = if_else(res1$p.value < 0.001, title_r1_1, title_r1_2),
              subtitle = if_else(res2$p.value < 0.001, title_r2_1, title_r2_2))
                   
    p1
    
  })
})