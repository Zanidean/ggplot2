#' Define margins.
#'
#' This is a convenience function that creates a grid unit object of the
#' correct length to use for setting margins.
#'
#' @export
#' @param t,b,r,l Dimensions of each margin. (To remember order, think trouble).
#' @param unit Default units of dimensions. Defaults to "pt" so it
#'   can be most easily scaled with the text.
#' @export
#' @examples
#' margin(4)
#' margin(4, 2)
#' margin(4, 3, 2, 1)
margin <- function(t = 0, r = 0, b = 0, l = 0, unit = "pt") {
  structure(unit(c(t, r, b, l), unit), class = c("margin", "unit"))
}


margin_height <- function(grob, margins) {
  if (is.zero(grob)) return(unit(0, "cm"))

  grobHeight(grob) + margins[1] + margins[3]
}

margin_width <- function(grob, margins) {
  if (is.zero(grob)) return(unit(0, "cm"))

  grobWidth(grob) + margins[2] + margins[4]
}

titleGrob <- function(label, x, y, hjust, vjust, angle = 0, gp = gpar(),
                         margin = NULL, side = "t") {
  if (is.null(label))
    return(zeroGrob())

  if (is.null(margin)) {
    margin <- margin(0, 0, 0, 0)
  }

  angle <- angle %% 360
  if (angle == 90) {
    xp <- 1 - vjust
    yp <- hjust
  } else if (angle == 180) {
    xp <- 1 - hjust
    yp <- 1 - vjust
  } else if (angle == 270) {
    xp <- vjust
    yp <- 1 - hjust
  } else {
    xp <- hjust
    yp <- vjust
  }
  x <- x %||% unit(xp, "npc")
  y <- y %||% unit(yp, "npc")

  text_grob <- textGrob(label, x, y, hjust = hjust, vjust = vjust, rot = angle, gp = gp)

  if (side %in% c("l", "r")) {
    widths <- unit.c(margin[4], unit(1, "grobwidth", text_grob), margin[2])
    vp <- viewport(layout = grid.layout(1, 3, widths = widths), gp = gp)
    child_vp <- viewport(name = "text", layout.pos.col = 2)

    heights <- unit(1, "null")
  } else if (side %in% c("t", "b")) {
    heights <- unit.c(margin[1], unit(1, "grobwidth", text_grob), margin[3])
    heights <- unit.c(margin[1], unit(1, "grobheight", text_grob), margin[3])

    vp <- viewport(layout = grid.layout(3, 1, heights = heights), gp = gp)
    child_vp <- viewport(name = "text", layout.pos.row = 2)

    widths <- unit(1, "null")
  }

  gTree(
    children = gList(
      rectGrob(gp = gpar(fill = "grey90")),
      pointsGrob(x[1], y[1], pch = 20, gp = gpar(col = "red")),
      text_grob
    ),
    vp = vpTree(vp, vpList(child_vp)),
    widths = widths,
    heights = heights,
    cl = "titleGrob"
  )
}

#' @export
widthDetails.titleGrob <- function(x) {
  sum(x$widths)
}

#' @export
heightDetails.titleGrob <- function(x) {
  sum(x$heights)
}