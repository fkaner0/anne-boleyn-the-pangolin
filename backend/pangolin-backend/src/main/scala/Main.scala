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

val reccomendationsEndpoint = endpoint
  .get
  .in("recommendations")
  .out(jsonBody[List[Recommendation]])
  .handleSuccess { _ => 
    { 
      println("handling recommendation")
      recommendations
    }
  }

val nettyServerOptions: NettySyncServerOptions =
  NettySyncServerOptions.customiseInterceptors
    .corsInterceptor(CORSInterceptor.customOrThrow(
    CORSConfig.default
      .allowAllHeaders
      .allowAllOrigins
      .allowAllMethods
      // .allowMethods(Method.GET)
      // .allowHeaders()
      // .allowCredentials
      .maxAge(42.seconds) // TODO
  )).options

@main
def main(): Unit = {
  NettySyncServer(nettyServerOptions).port(8080)
    .addEndpoint(reccomendationsEndpoint)
    .addEndpoint(profileEndpoint)
    .startAndWait()
}
