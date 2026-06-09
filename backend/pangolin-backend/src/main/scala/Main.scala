package pangolin

import cats.effect.{IO, IOApp, ExitCode}
import fs2.concurrent.Topic
import org.http4s.blaze.server.BlazeServerBuilder
import scala.concurrent.ExecutionContext
import sttp.model.sse.ServerSentEvent

object PangolinHttp4sServer extends IOApp {

  private val ec = scala.concurrent.ExecutionContext.Implicits.global

  override def run(args: List[String]): IO[ExitCode] = {
    Topic[IO, api.Message].flatMap { topic => 
      BlazeServerBuilder[IO]
        .withExecutionContext(ec)
        .bindHttp(8080, "0.0.0.0")
        .withHttpApp(api.router(topic))
        .serve
        .compile
        .drain
        .as(ExitCode.Success)
    }
  }
}
