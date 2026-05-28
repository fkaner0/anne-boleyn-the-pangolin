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

case class Recommendation(userId: Int, name: String, location: String, bio: String, profileImageUrl: String)
object Recommendation {
  given ReadWriter[Recommendation] = macroRW

  def fromProfile(profile: Profile): Recommendation = {
    Recommendation(profile.userId, profile.name, profile.location, profile.bio, profile.profileImageUrl)
  }
}

case class Profile(userId: Int, name: String, location: String, bio: String, profileImageUrl: String, imageUrls: List[String])
object Profile {
  given ReadWriter[Profile] = macroRW
}

val defaultImageUrl = "https://via.placeholder.com/150"

val tim = Profile(
  userId = 0,
  name = "Tim Johnson",
  location = "Harrow, London",
  bio = "Budding watercolour artist, been enjoying painting ponds.",
  profileImageUrl = defaultImageUrl,
  imageUrls = List(defaultImageUrl)
)

val sally = Profile(
  userId = 1,
  name = "Sally Parks",
  location = "Hammersmith, London",
  bio = "I love apples. I love still life. I love drawing apples in still life.",
  profileImageUrl = defaultImageUrl,
  imageUrls = List(defaultImageUrl, defaultImageUrl)
)

val selena = Profile(
  userId = 2,
  name = "Selena Davis",
  location = "Richmond, London",
  bio = "Finger painting fanatic, check out my pangolin art.",
  profileImageUrl = "https://via.placeholder.com/150",
  imageUrls = List(defaultImageUrl, defaultImageUrl, defaultImageUrl)
)

val profiles = List(tim, sally, selena)
val recommendations = profiles.map(Recommendation.fromProfile)

object PangolinHttp4sServer extends IOApp {

  val profileEndpoint = endpoint
    .get
    .in("profile" / path[Int]("userId"))
    .out(jsonBody[Profile])
    .handle { userId =>
      userId match {
        case 0 => Right(tim)
        case 1 => Right(sally)
        case 2 => Right(selena)
        case _ => Left(s"Unknown user ID $userId")
      }
    }

  val reccomendationsEndpoint: PublicEndpoint[Unit, Unit, List[Recommendation], Any] = endpoint
    .get
    .in("recommendations")
    .out(jsonBody[List[Recommendation]])
  
  val recommendationsRoutes: HttpRoutes[IO] =
    Http4sServerInterpreter[IO]().toRoutes(reccomendationsEndpoint.serverLogic(name => IO(Right(
      recommendations
    ))))

  given ec: ExecutionContext = scala.concurrent.ExecutionContext.Implicits.global

  // val http4sOptions: Http4sServerOptions[IO] =
  //   Http4sServerOptions.customiseInterceptors
  //     .corsInterceptor(CORSInterceptor.customOrThrow(
  //     CORSConfig.default
  //       .allowAllHeaders
  //       .allowAllOrigins
  //       .allowAllMethods
  //       // .allowMethods(Method.GET)
  //       // .allowHeaders()
  //       // .allowCredentials
  //       .maxAge(42.seconds) // TODO
  //   )).options

  // @main
  // def main(): Unit = {
  //   // NettySyncServer(nettyServerOptions).port(8080)
  //   //   .addEndpoint(reccomendationsEndpoint)
  //   //   .addEndpoint(profileEndpoint)
  //   //   .startAndWait()

  // }

  override def run(args: List[String]): IO[ExitCode] =
    BlazeServerBuilder[IO]
      .withExecutionContext(ec)
      .bindHttp(8080, "localhost")
      .withHttpApp(Router("/" -> recommendationsRoutes).orNotFound)
      .resource
      .useForever
}
