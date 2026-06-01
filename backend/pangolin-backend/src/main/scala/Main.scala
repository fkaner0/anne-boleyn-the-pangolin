import cats.effect.*
import cats.syntax.all.*
import sttp.tapir.*
import sttp.tapir.server.netty.sync.NettySyncServer
import sttp.tapir.generic.auto.*
import sttp.tapir.json.upickle.*
import upickle.default.*
import sttp.tapir.server.interceptor.cors.{CORSConfig, CORSInterceptor}
import sttp.tapir.server.netty.sync.NettySyncServerOptions
import scala.concurrent.Future
import sttp.tapir.server.interceptor.RequestInterceptor
import sttp.model.headers.Origin
import sttp.model.Method
import scala.concurrent.duration.DurationInt
import sttp.tapir.server.http4s.{Http4sServerOptions, Http4sServerInterpreter}
import org.http4s.HttpRoutes

import sttp.client4.httpclient.HttpClientSyncBackend
import scala.concurrent.ExecutionContext
import org.http4s.blaze.server.BlazeServerBuilder
import org.http4s.server.Router
import sttp.client4.SyncBackend
import sttp.client4.*

import org.postgresql.ds.PGSimpleDataSource
import org.postgresql.xa.PGXADataSource

import com.augustnagro.magnum.*

case class Recommendation(
    userId: Int,
    name: String,
    location: String,
    bio: String,
    profileImageUrl: String,
    rejected: Boolean,
)
object Recommendation {
  given ReadWriter[Recommendation] = macroRW
}

case class Image(
    url: String,
    x: Int,
    y: Int,
    rotation: Int,
)
object Image {
  given ReadWriter[Image] = macroRW
}

case class TextBox(
    title: String,
    body: String,
    x: Int,
    y: Int,
    rotation: Int,
)
object TextBox {
  given ReadWriter[TextBox] = macroRW
}

case class Profile(
    userId: Int,
    name: String,
    location: String,
    profileImageUrl: String,
    images: Vector[Image],
    textBoxes: Vector[TextBox],
)
object Profile {
  given ReadWriter[Profile] = macroRW
}

val dataSource: javax.sql.DataSource = {
  val ds = PGSimpleDataSource()
  ds.setDatabaseName("pangolindb")
  ds.setUser("pangolindbuser")
  ds.setPassword(
    sys.env.getOrElse("DB_PASSWORD", os.read(os.pwd / "db-password.txt")),
  )
  ds.setPortNumber(5432)
  ds.setUrl(
    "jdbc:postgresql://dpg-d8cbgu3eo5us73eq2hl0-a.frankfurt-postgres.render.com",
  )
  ds
}

val transactor = Transactor(dataSource)

val defaultImageUrl = "https://via.placeholder.com/150"

object PangolinHttp4sServer extends IOApp {

  val profileEndpoint = endpoint.get
    .in("profile" / path[Int]("userId"))
    .out(jsonBody[Profile])

  val reccomendationsEndpoint = endpoint.get
    .in("recommendations")
    .out(jsonBody[Vector[Recommendation]])

  val rejectProfileEndpoint = endpoint.put
    .in("profile" / path[Int]("userId"))
    .in(jsonBody[Boolean])

  given ec: ExecutionContext =
    scala.concurrent.ExecutionContext.Implicits.global

  val http4sOptions: Http4sServerOptions[IO] = Http4sServerOptions
    .customiseInterceptors[IO]
    .corsInterceptor(
      CORSInterceptor.customOrThrow(
        CORSConfig.default.allowAllHeaders.allowAllOrigins.allowAllMethods
          .maxAge(42.seconds), // TODO
      ),
    )
    .options

  val serverInterpreter = Http4sServerInterpreter[IO](http4sOptions)

  val recommendationsRoutes: HttpRoutes[IO] =
    serverInterpreter.toRoutes(
      reccomendationsEndpoint.serverLogic(name =>
        ???
      ),
    )

  val profileRoutes: HttpRoutes[IO] = serverInterpreter.toRoutes(profileEndpoint.serverLogic { userId =>
      ???
    }
  )

  val rejectProfileRoutes: HttpRoutes[IO] = serverInterpreter.toRoutes(rejectProfileEndpoint.serverLogic {
      (userId, rejected) =>
        ???
    }
  )

  override def run(args: List[String]): IO[ExitCode] =
    BlazeServerBuilder[IO]
      .withExecutionContext(ec)
      .bindHttp(8080, "0.0.0.0")
      .withHttpApp(
        Router(
          "/" -> recommendationsRoutes,
          "/" -> profileRoutes,
          "/" -> rejectProfileRoutes,
        ).orNotFound,
      )
      .resource
      .useForever
}
