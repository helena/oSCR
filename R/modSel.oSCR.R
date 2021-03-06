modSel.oSCR <- function(x){

  if(class(x)=="oSCR.fitList"){
    ms <- list()
    #AIC table
    df.out <- data.frame(model = names(x),
                         logL = unlist(lapply(x, function(y) y$rawOutput$minimum)),
                         K = unlist(lapply(x, function(y) length(y$rawOutput$estimate))),
                         AIC = unlist(lapply(x, function(y) y$AIC)))

    df.out$dAIC <- df.out$AIC - min(df.out$AIC)
    df.out$weight <- exp(-0.5 * df.out$dAIC)
    df.out$weight <- df.out$weight / sum(df.out$weight) 
    df.out2 <- df.out[order(df.out$dAIC),]
    df.out2$CumWt <- cumsum(df.out2$weight)
    rownames(df.out2) <- NULL
    ms[["aic.tab"]] <- df.out2

    #coefficient table
    coef.df <- NULL
    aic.df <- NULL
    for(i in 1:length(x)){
      tmp.df <- x[[i]]$coef.mle
      tmp.df$model <- names(x)[i]
      coef.df <- rbind(coef.df,tmp.df)
    }
    coef.tab <- data.frame(tapply(coef.df$mle,list(coef.df$model,coef.df$param),unique))
    coef.tab$model <- rownames(coef.tab)
    coef.tab <- coef.tab[,c("model",setdiff(colnames(coef.tab),"model"))]
    rownames(coef.tab) <- NULL
    coef.out <- merge(coef.tab,df.out[,c("model","AIC")],by="model")
    colnames(coef.out) <- c("model",levels(unlist(sapply(x,function(xx)xx$coef.mle$param))),"AIC")
    
    #se table
    
    if(any(sapply(x,function(xx) is.null(xx$rawOutput$hessian)))){
      print("Standard errors will not be computed: model was likely fit with 'se=FALSE'")

      ms[["coef.tab"]] <- coef.out[order(coef.out$AIC),-ncol(coef.out)]
      ms[["se"]] <- FALSE
      class(ms) <- "oSCR.modSel"
      return(ms)
    
    }else{
      se.df <- NULL
      for(i in 1:length(x)){
        tmp.df <- data.frame(se=sqrt(diag(solve(x[[i]]$rawOutput$hessian))),
                             param=x[[i]]$coef.mle$param)
        tmp.df$model <- names(x)[i]
        se.df <- rbind(se.df,tmp.df)
      }
    se.tab <- data.frame(tapply(se.df$se,list(se.df$model,se.df$param),unique))
    se.tab$model <- rownames(se.tab)
    se.tab <- se.tab[,c("model",setdiff(colnames(se.tab),"model"))]
    rownames(se.tab) <- NULL
    se.out <- merge(se.tab,df.out[,c("model","AIC")],by="model")
    colnames(se.out) <- c("model",levels(unlist(sapply(x,function(xx)xx$coef.mle$param))),"AIC")
    
    ms[["coef.tab"]] <- coef.out[order(coef.out$AIC),-ncol(coef.out)]
    ms[["se.tab"]] <- se.out[order(se.out$AIC),-ncol(se.out)]
    ms[["se"]] <- TRUE
    class(ms) <- "oSCR.modSel"
    return(ms)
    }
  }
  if(class(x)!="oSCR.fitList"){
      print("Object is not of class oSCR.fit or oSCR.fitList")
  }
}
