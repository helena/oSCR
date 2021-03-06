sim.SCR <- function (N = 100, K = 20, alpha0 = -2.5, sigma = 0.5, discard0 = TRUE,
    array3d = FALSE, ssRes = 0.5, traps_dim = c(5,5), traplocs = NULL, buffer = NULL,
    encmod = c("B","P")[1]){

    if (is.null(traplocs)){
      traplocs <- expand.grid(X=seq(1,traps_dim[1],by=1),Y=seq(1,traps_dim[2],by=1))
    }
    ntraps <- nrow(traplocs)
    if (is.null(buffer)){buffer <- sigma*4}
    Xl <- min(traplocs[, 1] - buffer)
    Xu <- max(traplocs[, 1] + buffer)
    Yl <- min(traplocs[, 2] - buffer)
    Yu <- max(traplocs[, 2] + buffer)
    sx <- runif(N, Xl, Xu)
    sy <- runif(N, Yl, Yu)
    Dens <- N / ((Xu - Xl) * (Yu - Yl))
    S <- cbind(sx, sy)
    D <- e2dist(S, traplocs)
    alpha1 <- 1/(2 * sigma * sigma)
    if (encmod=="B"){
      probcap <- plogis(alpha0) * exp(-alpha1 * D * D)
    } else if (encmod=="P"){
      probcap <- exp(alpha0) * exp(-alpha1 * D * D)
    }
    Y <- matrix(NA, nrow = N, ncol = ntraps)
    for (i in 1:nrow(Y)) {
      if (encmod=="B"){
        Y[i, ] <- rbinom(ntraps, K, probcap[i, ])
      } else if (encmod=="P"){
        Y[i, ] <- rpois(ntraps, probcap[i, ]*K)
      }
    }
    if (discard0) {
        totalcaps <- apply(Y, 1, sum)
        Y <- Y[totalcaps > 0, ]
    }
    dimnames(Y) <- list(1:nrow(Y), paste("trap", 1:ncol(Y), sep = ""))
    if (array3d) {
      Y <- array(NA, dim = c(N, ntraps, K))
        for (i in 1:nrow(Y)) {
          for (j in 1:ntraps) {
            if (encmod=="B"){
              Y[i, j, 1:K] <- rbinom(K, 1, probcap[i, j])
            } else if (encmod=="P"){
              Y[i, j, 1:K] <- rpois(K, probcap[i, j])
            }
          }
        }
        if (discard0) {
          Y2d <- apply(Y, c(1, 2), sum)
          ncaps <- apply(Y2d, 1, sum)
          Y <- Y[ncaps > 0, , ]
        }
    }
    ss <- expand.grid(X=seq(Xl + ssRes/2, Xu - ssRes/2, ssRes),
                      Y=seq(Yl + ssRes/2, Yu - ssRes/2, ssRes))
                      
    list(Y = Y, traplocs = traplocs, xlim = c(Xl, Xu), ylim = c(Yl,
        Yu), N = N, alpha0 = alpha0, alpha1 = alpha1, sigma = sigma,
        K = K, Dens = Dens, ss = ss, n0 = N-nrow(Y))
}
