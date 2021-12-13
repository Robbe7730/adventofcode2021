print_board <- function(mat) {
  for(y in 1:nrow(mat)) {
    for(x in 1:ncol(mat)) {
      if (mat[y, x] == 0) {
        cat(".")
      } else {
        cat("#")
      }
    }
    cat("\n")
  }
}

f <- file("stdin")
open(f)

mat<-matrix(0)

while(length(line <- readLines(f, n=1, warn=FALSE)) > 0 && line != '') {
  line_split <- unlist(strsplit(line, ','))
  x <- strtoi(line_split[1]) + 1
  y <- strtoi(line_split[2]) + 1

  while (x > ncol(mat)) {
    mat <- cbind(mat, rep(0, nrow(mat)))
  }

  while (y > nrow(mat)) {
    mat <- rbind(mat, rep(0, ncol(mat)))
  }

  mat[y,x] = 1
}

line <- readLines(f, n=1, warn=FALSE)
line_split <- unlist(strsplit(substring(line, 12), '='))
axis <- line_split[1]
index <- strtoi(line_split[2]) + 1
if (axis == 'y') {
  new_mat = matrix(0, nrow=nrow(mat)/2, ncol=ncol(mat))
  folded_x <- function(x) {
    return (x)
  }
  folded_y <- function(y) {
    if (y < index) {
      return (y)
    } else if (y > index) {
      return (2*index - y)
    } else {
      return (0)
    }
  }
} else {
  new_mat = matrix(0, nrow=nrow(mat), ncol=ncol(mat)/2)
  folded_x <- function(x) {
    if (x < index) {
      return (x)
    } else if (x > index) {
      return (2*index - x)
    } else {
      return (0)
    }
  }
  folded_y <- function(y) {
    return (y)
  }
}

for(y in 1:nrow(mat)) {
  for(x in 1:ncol(mat)) {
    new_x = folded_x(x);
    new_y = folded_y(y);
    if (mat[y, x] == 1) {
     new_mat[new_y, new_x] <- 1
    }
  }
}

mat <- new_mat

print(sum(mat))
