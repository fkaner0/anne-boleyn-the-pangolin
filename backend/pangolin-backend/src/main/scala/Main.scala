package pangolin

import cats.effect.{IO, IOApp, ExitCode}
import fs2.concurrent.Channel
import org.http4s.blaze.server.BlazeServerBuilder
import scala.concurrent.ExecutionContext
import sttp.model.sse.ServerSentEvent

object PangolinHttp4sServer extends IOApp {

  private val ec = scala.concurrent.ExecutionContext.Implicits.global

  override def run(args: List[String]): IO[ExitCode] = {
    Channel.unbounded[IO, api.Message].flatMap { channel => 
      BlazeServerBuilder[IO]
        .withExecutionContext(ec)
        .bindHttp(8080, "0.0.0.0")
        .withHttpApp(api.router(channel))
        .serve
        .compile
        .drain
        .as(ExitCode.Success)
    }
  }
}
