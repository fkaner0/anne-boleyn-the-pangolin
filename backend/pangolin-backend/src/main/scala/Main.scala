import sttp.tapir.*
import sttp.tapir.server.netty.sync.NettySyncServer
import sttp.tapir.generic.auto.*
import sttp.tapir.json.upickle.*
import upickle.default.*

case class Recommendation(name: String, location: String, bio: String, profileImageUrl: String)
object Recommendation {
  given ReadWriter[Recommendation] = macroRW
}

val reccomendations = List(
  Recommendation(
    name = "Tim Johnson",
    location = "Harrow, London",
    bio = "Budding watercolour artist, been enjoying painting ponds.",
    profileImageUrl = "https://via.placeholder.com/150",
  ),
  Recommendation(
    name = "Sally Parks",
    location = "Hammersmith, London",
    bio = "I love apples. I love still life. I love drawing apples in still life.",
    profileImageUrl = "https://via.placeholder.com/150",
  ),
  Recommendation(
    name = "Selena Davis",
    location = "Richmond, London",
    bio = "Finger painting fanatic, check out my pangolin art.",
    profileImageUrl = "https://via.placeholder.com/150",
  )
)

val reccomendationEndpoint = endpoint
  .get
  .in("recommendations")
  .out(jsonBody[List[Recommendation]])
  .handleSuccess { _ => reccomendations }

@main
def main(): Unit = {
  NettySyncServer().port(8080)
    .addEndpoint(reccomendationEndpoint)
    .startAndWait()
}
