package pangolin

import cats.effect.{IO, IOApp, ExitCode}
import org.http4s.blaze.server.BlazeServerBuilder
import scala.concurrent.ExecutionContext

object PangolinHttp4sServer extends IOApp {

  private val ec = scala.concurrent.ExecutionContext.Implicits.global

  override def run(args: List[String]): IO[ExitCode] = {
    BlazeServerBuilder[IO]
      .withExecutionContext(ec)
      .bindHttp(8080, "0.0.0.0")
      .withHttpApp(api.router)
      .resource
      .useForever
  }
}
