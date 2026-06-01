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
    rejected: Boolean
)
object Recommendation {
  given ReadWriter[Recommendation] = macroRW

  def fromProfile(profile: Profile): Recommendation = {
    Recommendation(
      profile.userId,
      profile.name,
      profile.location,
      profile.bio,
      profile.profileImageUrl,
      profile.rejected
    )
  }
}

case class Profile(
    userId: Int,
    name: String,
    location: String,
    bio: String,
    profileImageUrl: String,
    imageUrls: List[String],
    rejected: Boolean
)
object Profile {
  given ReadWriter[Profile] = macroRW
}

val dataSource: javax.sql.DataSource = {
  val ds = PGSimpleDataSource()
  ds.setDatabaseName("pangolindb")
  ds.setUser("pangolindbuser")
  ds.setPassword(
    sys.env.getOrElse("DB_PASSWORD", os.read(os.pwd / "db-password.txt"))
  )
  ds.setPortNumber(5432)
  ds.setUrl(
    "jdbc:postgresql://dpg-d8cbgu3eo5us73eq2hl0-a.frankfurt-postgres.render.com"
  )
  ds
}

val transactor = Transactor(dataSource)

val defaultImageUrl = "https://via.placeholder.com/150"

var tim = Profile(
  userId = 0,
  name = "Tim Johnson",
  location = "Hounslow, London",
  bio = "Budding watercolour artist, been enjoying painting ponds.",
  profileImageUrl = defaultImageUrl,
  imageUrls = List(defaultImageUrl),
  rejected = false
)

var sally = Profile(
  userId = 1,
  name = "Sally Parks",
  location = "Hammersmith, London",
  bio =
    "I love apples. I love still life. I love drawing apples in still life.",
  profileImageUrl = defaultImageUrl,
  imageUrls = List(defaultImageUrl, defaultImageUrl),
  rejected = false
)

var selena = Profile(
  userId = 2,
  name = "Selena Davis",
  location = "Hampstead, London",
  bio = "Finger painting fanatic, check out my pangolin art.",
  profileImageUrl = "https://via.placeholder.com/150",
  imageUrls = List(defaultImageUrl, defaultImageUrl, defaultImageUrl),
  rejected = false
)

def profiles = Vector(tim, sally, selena)
def recommendations =
  profiles.map(Recommendation.fromProfile).filter(!_.rejected)

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
          .maxAge(42.seconds) // TODO
      )
    )
    .options

  val serverInterpreter = Http4sServerInterpreter[IO](http4sOptions)

  val recommendationsRoutes: HttpRoutes[IO] =
    serverInterpreter.toRoutes(
      reccomendationsEndpoint.serverLogic(name =>
        IO(Right(recommendations.filter(!_.rejected)))
      )
    )

  val profileRoutes: HttpRoutes[IO] =
    serverInterpreter.toRoutes(profileEndpoint.serverLogic { userId =>
      userId match {
        case 0 => IO(Right(tim))
        case 1 => IO(Right(sally))
        case 2 => IO(Right(selena))
        case _ => IO(Left(()))
      }
    })

  val rejectProfileRoutes: HttpRoutes[IO] =
    serverInterpreter.toRoutes(rejectProfileEndpoint.serverLogic {
      (userId, rejected) =>
        userId match {
          case 0 => {
            tim = tim.copy(rejected = rejected)
            IO(Right(()))
          }
          case 1 => {
            sally = sally.copy(rejected = rejected)
            IO(Right(()))
          }
          case 2 => {
            selena = selena.copy(rejected = rejected)
            IO(Right(()))
          }
          case _ => IO(Left(()))
        }
    })

  override def run(args: List[String]): IO[ExitCode] =
    BlazeServerBuilder[IO]
      .withExecutionContext(ec)
      .bindHttp(8080, "0.0.0.0")
      .withHttpApp(
        Router(
          "/" -> recommendationsRoutes,
          "/" -> profileRoutes,
          "/" -> rejectProfileRoutes
        ).orNotFound
      )
      .resource
      .useForever
}
