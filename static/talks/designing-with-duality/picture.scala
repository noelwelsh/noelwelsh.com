//> using dep org.creativescala::doodle:0.28.0

import cats.effect.unsafe.implicits.global
import doodle.core.*
import doodle.core.format.*
import doodle.syntax.all.*
import doodle.java2d.*

@main def go(): Unit =
  val frame = Frame.default.withBackground(Color.black)
  val picture = Picture.circle(200).beside(Picture.square(200)).strokeColor(Color.white).strokeWidth(5.0).noFill
  picture.write[Png]("picture.png", frame)
