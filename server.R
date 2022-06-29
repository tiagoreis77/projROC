
library(shiny)
library(ROCR)

shinyServer(function(input, output, session){
  
  data <- reactive({
    req(input$file1)
    fileIn <- input$file1
    df <- read.csv(fileIn$datapath, header = input$header, sep = input$sep)
    
    updateSelectInput(session, inputId = "prediction", label = "Prediction",
                      choices = names(df), selected = names(df)[1])
    updateSelectInput(session, inputId = "response", label = "Response",
                      choices = names(df), selected = names(df))
    updateSelectInput(session, inputId = "addprediction", label = "Add Prediction",
                      choices = names(df), selected = names(df)[1])
    updateSelectInput(session, inputId = "addresponse", label = "Add Response",
                      choices = names(df), selected = names(df))
    
    return(df)
  })
  
  output$contents <- renderTable({
    data()
  })
  
  
  output$MyCurve <- renderPlot({
    x <- data()[, c(input$prediction, input$response, input$addprediction, input$addresponse)]
    Pred = ROCR::prediction(x[[input$prediction]], x[[input$response]])
    Perf_auc = ROCR::performance(Pred, measure = "auc")
    
    if(Perf_auc@y.values > 0.5){
      Perf = ROCR::performance(Pred, measure = "tpr", x.measure = "fpr")
      plot(Perf, main = "ROC Curve", xlab = "False Positive Rate", ylab = "True Positive Rate", col = 2)
      abline(coef = c(0, 1), col = "grey")
    }
    else{
      Pred = ROCR::prediction(-x[[input$prediction]], x[[input$response]])
      Perf = ROCR::performance(Pred, measure = "tpr", x.measure = "fpr")
      plot(Perf, main = "ROC Curve", xlab = "False Positive Rate", ylab = "True Positive Rate", col = 2)
      abline(coef = c(0, 1), col = "grey")
    }
    
    if(input$add == T){
      Pred_Add = ROCR::prediction(x[[input$addprediction]], x[[input$addresponse]])
      Perf_Add_auc = ROCR::performance(Pred_Add, measure = "auc")
      if(Perf_Add_auc@y.values > 0.5){
        Perf_Add = ROCR::performance(Pred_Add, measure = "tpr", x.measure = "fpr")
        plot(Perf, main = "Two ROC Curves", xlab = "False Positive Rate", ylab = "True Positive Rate", col = 2)
        plot(Perf_Add, add = T, col = 3)
        abline(coef = c(0, 1), col = "grey")
      }
      else{
        Pred_Add = ROCR::prediction(-x[[input$addprediction]], x[[input$addresponse]])
        Perf_Add = ROCR::performance(Pred_Add, measure = "tpr", x.measure = "fpr")
        plot(Perf, main = "Two ROC Curves", xlab = "False Positive Rate", ylab = "True Positive Rate", col = 2)
        plot(Perf_Add, add = T, col = 3)
        abline(coef = c(0, 1), col = "grey")
      }
    }
  })
  
  output$AUC <- renderPrint({
    x <- data()[, c(input$prediction, input$response)]
    x = na.omit(x)
    z <- data()[, c(input$addprediction, input$addresponse)]
    z = na.omit(z)
    Pred_x = ROCR::prediction(x[[input$prediction]], x[[input$response]])
    Perf_x = ROCR::performance(Pred_x, measure = "auc")
    Pred_z = ROCR::prediction(z[[input$addprediction]], z[[input$addresponse]])
    Perf_z = ROCR::performance(Pred_z, measure = "auc")
    
    if(input$add == T){
      if(Perf_x@y.values > 0.5 & Perf_z@y.values > 0.5){
        print("Area Under the Curve 1 (Red)")
        print(Perf_x@y.values)
        print("Area Under the Curve 2 (Green)")
        print(Perf_z@y.values)
      }
      else if(Perf_x@y.values < 0.5 & Perf_z@y.values < 0.5){
        Pred_x = ROCR::prediction(-x[[input$prediction]], x[[input$response]])
        Perf_x = ROCR::performance(Pred_x, measure = "auc")
        Pred_z = ROCR::prediction(-z[[input$addprediction]], z[[input$addresponse]])
        Perf_z = ROCR::performance(Pred_z, measure = "auc")
        print("Area Under the Curve 1 (Red)")
        print(Perf_x@y.values)
        print("Area Under the Curve 2 (Green)")
        print(Perf_z@y.values)
      }
      else if(Perf_x@y.values < 0.5){
        Pred_x = ROCR::prediction(-x[[input$prediction]], x[[input$response]])
        Perf_x = ROCR::performance(Pred_x, measure = "auc")
        print("Area Under the Curve 1 (Red)")
        print(Perf_x@y.values)
        print("Area Under the Curve 2 (Green)")
        print(Perf_z@y.values)
      }
      else if(Perf_z@y.values < 0.5){
        Pred_z = ROCR::prediction(-z[[input$addprediction]], z[[input$addresponse]])
        Perf_z = ROCR::performance(Pred_z, measure = "auc")
        print("Area Under the Curve 1 (Red)")
        print(Perf_x@y.values)
        print("Area Under the Curve 2 (Green)")
        print(Perf_z@y.values)
      }
    }
    else{
      if(Perf_x@y.values > 0.5){
        print("Area Under the Curve")
        print(Perf_x@y.values)
      }
      else{
        Pred_x = ROCR::prediction(-x[[input$prediction]], x[[input$response]])
        Perf_x = ROCR::performance(Pred_x, measure = "auc")
        print("Area Under the Curve")
        print(Perf_x@y.values)
      }
    }
  })
  
  output$plot_clickinfo <- renderText({
    sprintf("Coordinates of the Selected Point\nX-axis: %.4f\nY-axis: %.4f", input$plot_click$x, input$plot_click$y)
  })
})
