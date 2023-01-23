#load shiny library
library(shiny)

# define the vaf column names
dat <-  read.csv("data4correlation.csv")
selectVars <- colnames(dat)
axis_options <- list(
  "D2 Striatum" = "Z_DGwin_SEM_striatum",
  "ΔSDBold Striato-thalamic with Dopamine (z-score)" = "Z_DGwin_BS_SD3min2_with_DA",
  "ΔSDBold Visual (z-score)" = "Z_DGwin_TaskSD_avg_Yeo1_Vis_32change",
  "ΔSDBold DAN (z-score)" = "Z_DGwin_TaskSD_avg_Yeo3_DAN_32change",
  "ΔSDBold FPN (z-score)" = "Z_DGwin_TaskSD_avg_Yeo6_FPN_32change",
  "ΔSDBold DMN (z-score)" = "Z_DGwin_TaskSD_avg_Yeo7_DMN_32change",
  "ΔPCAdim Striato-thalamic (z-score)" = "Z_DGwin_PCAdimTEMP_BGHATMorel_32change",
  "ΔPCAdim Visual (z-score)" = "Z_DGwin_PCAdimTEMP_Yeo1_Vis_32change",
  "ΔPCAdim DAN (z-score)" = "Z_DGwin_PCAdimTEMP_Yeo3_DAN_32change",
  "ΔPCAdim FPN (z-score)" ="Z_DGwin_PCAdimTEMP_Yeo6_FPN_32change",
  "ΔPCAdim DMN (z-score)" = "Z_DGwin_PCAdimTEMP_Yeo7_DMN_32change",
  "ΔBoundary Separation (a) (z-score)" = "Z_DGwin_HDDMwBias_a_3min2back",
  "ΔDrift Rate (v) (z-score)" = "Z_DGwin_HDDMwBias_v_3min2back",
  "ΔNon-Decision Time (t) (z-score)" = "Z_DGwin_HDDMwBias_t_3min2back",
  "ΔStarting Point (z) (z-score)" = "Z_DGwin_HDDMwBias_z_3min2back",
  "ΔDrift Criterion (dc) (z-score)" = "Z_DGwin_HDDMwBias_dc_3min2back",
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
  "2-back Criterion (dc)" = "DGwin_HDDMwBias_dc_2back",
  "3-back Criterion (dc)" = "DGwin_HDDMwBias_dc_3back",
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



# set up front end
shinyUI(fixedPage(
  br(),
  h5("Bivariate correlations from:"),
  span("Garrett, D. D., Kloosterman, N. A., Epp, S., Chopurian, V., Kosciessa, J. Q., Waschke, L.,
      Skowron, A., Shine, J. M., Perry, A., Salami, A., 
      Rieckmann, A., Papenberg, G., Wåhlin, A., Karalija, N.,
      Andersson, M., Riklund, K., Lövdén, M., Bäckman, L., Nyberg, L.
      & Lindenberger, U. (2023).",
      strong("Dynamic regulation of neural variability during working memory reflects dopamine, 
      functional integration, and decision-making.")),
  br(), br(),
  # set up the UI layout with a side and main panel
  sidebarLayout(
    
    # set the side panel to allow for user input
    sidebarPanel(
      selectInput(inputId="x_axis", label="Select X variable", 
                  choices=axis_options, selected="Z_DGwin_HDDMwBias_a_3min2back",
                  width = 400),
      selectInput(inputId="y_axis", label="Select Y variable", 
                  choices=axis_options, selected="Z_DGwin_BS_SD3min2_with_DA",
                  width = 400)
    ),

    # set the plot panel
    mainPanel(
      plotOutput("scatterPlot",height = 400, width = 400),
      br()
    )
  )
))