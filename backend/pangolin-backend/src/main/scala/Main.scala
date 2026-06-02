import cats.effect.*
import cats.syntax.all.*
import sttp.tapir.*
import sttp.tapir.generic.auto.*
import sttp.tapir.json.upickle.*
import upickle.default.*
import sttp.tapir.server.interceptor.cors.{CORSConfig, CORSInterceptor}
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

case class ProfileImageCreator(
    userId: Int,
    url: String,
    x: Int,
    y: Int,
    rotation: Int,
    aspectRatio: Double,
    scale: Double,
) derives DbCodec
object ProfileImageCreator {
  given ReadWriter[ProfileImageCreator] = macroRW
}

@Table(PostgresDbType)
case class ProfileImage(
    @Id id: Int,
    userId: Int,
    url: String,
    x: Int,
    y: Int,
    rotation: Int,
    aspectRatio: Double,
    scale: Double,
) derives DbCodec

object ProfileImage {
  given ReadWriter[ProfileImage] = macroRW
  val Table = TableInfo[ProfileImageCreator, ProfileImage, Int]
}

val profileImageRepo = Repo[ProfileImageCreator, ProfileImage, Int]

case class ProfileTextBoxCreator(
    userId: Int,
    title: String,
    body: String,
    x: Int,
    y: Int,
    rotation: Int,
    aspectRatio: Double,
    scale: Double,
) derives DbCodec
object ProfileTextBoxCreator {
  given ReadWriter[ProfileTextBoxCreator] = macroRW
}

@Table(PostgresDbType)
case class ProfileTextBox(
    @Id id: Int,
    userId: Int,
    title: String,
    body: String,
    x: Int,
    y: Int,
    rotation: Int,
    aspectRatio: Double,
    scale: Double,
) derives DbCodec

object ProfileTextBox {
  given ReadWriter[ProfileTextBox] = macroRW
  val Table = TableInfo[ProfileTextBoxCreator, ProfileTextBox, Int]
}

val profileTextBoxRepo = Repo[ProfileTextBoxCreator, ProfileTextBox, Int]

case class ProfileCreator(
    name: String,
    location: String,
    profileImageUrl: String,
) derives DbCodec
object ProfileCreator {
  given ReadWriter[ProfileCreator] = macroRW
}

@Table(PostgresDbType)
case class Profile(
    @Id id: Int,
    name: String,
    location: String,
    profileImageUrl: String,
) derives DbCodec

object Profile {
  val Table = TableInfo[ProfileCreator, Profile, Int]
}

val profileRepo = Repo[ProfileCreator, Profile, Int]

case class FullProfile(
    userId: Int,
    name: String,
    location: String,
    profileImageUrl: String,
    images: Vector[ProfileImage],
    textBoxes: Vector[ProfileTextBox],
)

object FullProfile {
  given ReadWriter[FullProfile] = macroRW
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
    "jdbc:postgresql://dpg-d8cbgu3eo5us73eq2hl0-a.frankfurt-postgres.render.com/",
  )
  ds
}

val transactor = Transactor(dataSource)

val defaultImageUrl = "https://via.placeholder.com/150"

object PangolinHttp4sServer extends IOApp {

  val profileEndpoint = endpoint.get
    .in("profile" / path[Int]("userId"))
    .out(jsonBody[FullProfile])

  val reccomendationsEndpoint = endpoint.get
    .in("recommendations")
    .out(jsonBody[Vector[Recommendation]])

  val rejectProfileEndpoint = endpoint.put
    .in("profile" / path[Int]("userId"))
    .in(jsonBody[Boolean])

  val insertProfileEndpoint = endpoint.put
    .in("profile")
    .in(jsonBody[ProfileCreator])

  val insertProfileImageEndpoint = endpoint.put
    .in("profile" / "image")
    .in(jsonBody[ProfileImageCreator])

  val insertProfileTextBoxEndpoint = endpoint.put
    .in("profile" / "textBox")
    .in(jsonBody[ProfileTextBoxCreator])

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

  val recommendationsRoutes: HttpRoutes[IO] = serverInterpreter.toRoutes(
    reccomendationsEndpoint.serverLogic { _ =>
      IO.blocking(
        connect(dataSource) {
          profileRepo.findAll.map {
            case Profile(id, name, location, profileImageUrl) =>
              Recommendation(
                userId = id,
                name = name,
                location = location,
                bio = "",
                profileImageUrl = profileImageUrl,
                rejected = false,
              )
          }.asRight
        },
      )
    },
  )

  private def profileImagesSpec(userId: Int) = Spec[ProfileImage]
    .where(sql"${ProfileImage.Table.userId} = $userId")

  private def profileTextBoxesSpec(userId: Int) = Spec[ProfileTextBox]
    .where(sql"${ProfileTextBox.Table.userId} = $userId")

  val profileRoutes: HttpRoutes[IO] = serverInterpreter.toRoutes(
    profileEndpoint.serverLogic { userId =>
      IO.blocking(
        transact(dataSource) {
          profileRepo
            .findById(userId)
            .map { case Profile(userId, name, location, profileImageUrl) =>
              val images = profileImageRepo.findAll(profileImagesSpec(userId))
              val textBoxes =
                profileTextBoxRepo.findAll(profileTextBoxesSpec(userId))
              FullProfile(
                userId = userId,
                name = name,
                location = location,
                profileImageUrl = profileImageUrl,
                images = images,
                textBoxes = textBoxes,
              )
            }
            .toRight(())
        },
      )
    },
  )

  val rejectProfileRoutes: HttpRoutes[IO] = serverInterpreter.toRoutes(
    rejectProfileEndpoint.serverLogic { (userId, rejected) =>
      // TODO: Remove
      IO(().asRight)
    },
  )

  val insertProfileRoutes = serverInterpreter.toRoutes(
    insertProfileEndpoint.serverLogic { profileCreator =>
      IO.blocking {
        connect(dataSource) {
          profileRepo.insert(profileCreator).asRight
        }
      }
    },
  )

  val insertProfileImageRoutes = serverInterpreter.toRoutes(
    insertProfileImageEndpoint.serverLogic { profileImageCreator =>
      IO.blocking {
        connect(dataSource) {
          profileImageRepo.insert(profileImageCreator).asRight
        }
      }
    },
  )

  val insertProfileTextBoxRoutes = serverInterpreter.toRoutes(
    insertProfileTextBoxEndpoint.serverLogic { profileTextBoxCreator =>
      IO.blocking {
        connect(dataSource) {
          profileTextBoxRepo.insert(profileTextBoxCreator).asRight
        }
      }
    },
  )

  override def run(args: List[String]): IO[ExitCode] = {
    BlazeServerBuilder[IO]
      .withExecutionContext(ec)
      .bindHttp(8080, "0.0.0.0")
      .withHttpApp(
        Router(
          "/" -> recommendationsRoutes,
          "/" -> profileRoutes,
          "/" -> rejectProfileRoutes,
          "/" -> insertProfileRoutes,
          "/" -> insertProfileImageRoutes,
          "/" -> insertProfileTextBoxRoutes,
        ).orNotFound,
      )
      .resource
      .useForever
  }
}
