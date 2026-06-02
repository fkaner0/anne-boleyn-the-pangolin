package pangolin

import cats.syntax.all.*
import cats.effect.IO
import com.augustnagro.magnum.{
  DbCodec,
  Id,
  PostgresDbType,
  Repo,
  Spec,
  Table,
  TableInfo,
  connect,
  sql,
}
import org.postgresql.ds.PGSimpleDataSource

object repo {

  trait Positioned {
    val x: Int
    val y: Int
    val rotation: Int
    val aspectRatio: Double
    val scale: Double
  }

  case class ProfileImageCreator(
      userId: Int,
      url: String,
      x: Int,
      y: Int,
      rotation: Int,
      aspectRatio: Double,
      scale: Double,
  ) extends Positioned derives DbCodec

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
  ) extends Positioned derives DbCodec

  object ProfileImage {
    val Table = TableInfo[ProfileImageCreator, ProfileImage, Int]
  }

  case class ProfileTextBoxCreator(
      userId: Int,
      title: String,
      body: String,
      x: Int,
      y: Int,
      rotation: Int,
      aspectRatio: Double,
      scale: Double,
  ) extends Positioned derives DbCodec

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
  ) extends Positioned derives DbCodec

  object ProfileTextBox {
    val Table = TableInfo[ProfileTextBoxCreator, ProfileTextBox, Int]
  }

  case class ProfileCreator(
      name: String,
      location: String,
      profileImageUrl: String,
  ) derives DbCodec

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

  private val dataSource: javax.sql.DataSource = {
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

  private val profileImageRepo = Repo[ProfileImageCreator, ProfileImage, Int]
  private val profileTextBoxRepo =
    Repo[ProfileTextBoxCreator, ProfileTextBox, Int]
  private val profileRepo = Repo[ProfileCreator, Profile, Int]

  private def profileImagesSpec(userId: Int) = Spec[ProfileImage]
    .where(sql"${ProfileImage.Table.userId} = $userId")

  private def profileTextBoxesSpec(userId: Int) = Spec[ProfileTextBox]
    .where(sql"${ProfileTextBox.Table.userId} = $userId")

  val getRecommendations = IO.blocking {
    connect(dataSource) {
      profileRepo.findAll.asRight
    }
  }

  def getProfile(userId: Int) = IO.blocking {
    connect(dataSource) {
      profileRepo
        .findById(userId)
        .map { profile =>
          val images = profileImageRepo.findAll(profileImagesSpec(userId))
          val textBoxes =
            profileTextBoxRepo.findAll(profileTextBoxesSpec(userId))
          (profile, images, textBoxes)
        }
        .toRight(())
    }
  }
}
