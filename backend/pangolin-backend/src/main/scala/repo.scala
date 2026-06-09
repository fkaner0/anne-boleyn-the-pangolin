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
import io.github.cdimascio.dotenv.Dotenv
import org.postgresql.ds.PGSimpleDataSource
import com.augustnagro.magnum.DbCon

object repo {

  trait Positioned {
    val x: Int
    val y: Int
    val rotation: Double
    val aspectRatio: Double
    val scale: Double
  }

  case class ProfileImageCreator(
      userId: Int,
      url: String,
      x: Int,
      y: Int,
      rotation: Double,
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
      rotation: Double,
      aspectRatio: Double,
      scale: Double,
  ) extends Positioned derives DbCodec

  object ProfileImage {
    val Table = TableInfo[ProfileImageCreator, ProfileImage, Int]
  }

  case class ProfileTextboxCreator(
      userId: Int,
      title: String,
      body: String,
      font: Option[String],
      fontARGB: Long,
      backgroundARGB: Long,
      x: Int,
      y: Int,
      rotation: Double,
      aspectRatio: Double,
      scale: Double,
  ) extends Positioned derives DbCodec

  @Table(PostgresDbType)
  case class ProfileTextbox(
      @Id id: Int,
      userId: Int,
      title: String,
      body: String,
      font: Option[String],
      fontARGB: Long,
      backgroundARGB: Long,
      x: Int,
      y: Int,
      rotation: Double,
      aspectRatio: Double,
      scale: Double,
  ) extends Positioned derives DbCodec

  object ProfileTextbox {
    val Table = TableInfo[ProfileTextboxCreator, ProfileTextbox, Int]
  }

  case class ProfileStickerCreator(
      userId: Int,
      name: String,
      x: Int,
      y: Int,
      rotation: Double,
      aspectRatio: Double,
      scale: Double,
  ) extends Positioned derives DbCodec

  @Table(PostgresDbType)
  case class ProfileSticker(
      @Id id: Int,
      userId: Int,
      name: String,
      x: Int,
      y: Int,
      rotation: Double,
      aspectRatio: Double,
      scale: Double,
  ) extends Positioned derives DbCodec

  object ProfileSticker {
    val Table = TableInfo[ProfileStickerCreator, ProfileSticker, Int]
  }

  case class ProfileCreator(
      name: String,
      location: String,
      bio: String,
      wallBackgroundHexARGB: Long,
      profileImageUrl: String,
      age: Int,
  ) derives DbCodec

  @Table(PostgresDbType)
  case class Profile(
      @Id id: Int,
      name: String,
      location: String,
      bio: String,
      wallBackgroundHexARGB: Long,
      profileImageUrl: String,
      age: Int,
  ) derives DbCodec

  object Profile {
    val Table = TableInfo[ProfileCreator, Profile, Int]
  }

  case class ButtonLogCreator(
    userId: Int,
    buttonId: String,
    pressTimestamp: Int,
  )

  @Table(PostgresDbType)
  case class ButtonLog(
    @Id id: Int,
    userId: Int,
    buttonId: String,
    pressTimestamp: Int,
  )

  object ButtonLog {
    val table = TableInfo[ButtonLogCreator, ButtonLog, Int]
  }

  private val dataSource: javax.sql.DataSource = {
    val ds = PGSimpleDataSource()
    ds.setDatabaseName("pangolindb")
    ds.setUser("pangolindbuser")
    ds.setPassword(
      sys.env.getOrElse("DB_PASSWORD", Dotenv.load().get("DB_PASSWORD")),
    )
    ds.setPortNumber(5432)
    ds.setUrl(
      "jdbc:postgresql://dpg-d8cbgu3eo5us73eq2hl0-a.frankfurt-postgres.render.com/",
    )
    ds
  }

  private val profileImageRepo = Repo[ProfileImageCreator, ProfileImage, Int]
  private val profileTextboxRepo = Repo[ProfileTextboxCreator, ProfileTextbox, Int]
  private val profileStickerRepo = Repo[ProfileStickerCreator, ProfileSticker, Int]
 
  private val profileRepo = Repo[ProfileCreator, Profile, Int]

  private val buttonLogRepo = Repo[ButtonLogCreator, ButtonLog, Int]

  private def profileImagesSpec(userId: Int) = Spec[ProfileImage]
    .where(sql"${ProfileImage.Table.userId} = $userId")

  private def profileTextboxesSpec(userId: Int) = Spec[ProfileTextbox]
    .where(sql"${ProfileTextbox.Table.userId} = $userId")

  private def profileStickersSpec(userId: Int) = Spec[ProfileSticker]
    .where(sql"${ProfileSticker.Table.userId} = $userId")

  val getRecommendations = inDatabase {
    profileRepo.findAll.asRight
  }

  def getProfile(userId: Int) = inDatabase {
    profileRepo
      .findById(userId)
      .map { profile =>
        val images = profileImageRepo.findAll(profileImagesSpec(userId))
        val textboxes =
          profileTextboxRepo.findAll(profileTextboxesSpec(userId))
        val stickers =
          profileStickerRepo.findAll(profileStickersSpec(userId))
        (profile, images, textboxes, stickers)
      }
      .toRight(())
  }

  def newProfile(): IO[Either[Nothing, Int]] = inDatabase {
    profileRepo.insertReturning(ProfileCreator(
      name = "no name provided",
      location = "no location provided",
      bio = "no bio provided",
      wallBackgroundHexARGB = 0,
      profileImageUrl = "https://placehold.co/400x400.jpg",
      age = 0,
    )).id.asRight
  }

  private def removeBySpec[EC, E, I](table: Repo[EC, E, I], spec: Spec[E], getId: E => I)(using DbCon)
    = table.deleteAllById(table.findAll(spec).map(getId))
    
  private def addAll[EC, E, I](table: Repo[EC, E, I])(elems: Iterable[EC])(using DbCon)
    = table.insertAll(elems)

  private def removeTextboxes(userId: Int)(using DbCon) = removeBySpec(profileTextboxRepo, profileTextboxesSpec(userId), _.id)
  private def removeImages(userId: Int)(using DbCon) = removeBySpec(profileImageRepo, profileImagesSpec(userId), _.id)
  private def removeStickers(userId: Int)(using DbCon) = removeBySpec(profileStickerRepo, profileStickersSpec(userId), _.id)
  private def addTextboxes(using DbCon) = addAll(profileTextboxRepo)
  private def addImages(using DbCon) = addAll(profileImageRepo)
  private def addStickers(using DbCon) = addAll(profileStickerRepo)

  def updateFullProfile(
        profile: Profile,
        textboxCreators: Iterable[ProfileTextboxCreator],
        imageCreators: Iterable[ProfileImageCreator],
        stickerCreators: Iterable[ProfileStickerCreator],
  ) = repo.inDatabase {
    profileRepo.findById(profile.id) match {
      // Only update profile if the row already exists.
      case Some(_) => {
        repo.profileRepo.update(profile)
        repo.removeTextboxes(profile.id)
        repo.addTextboxes(textboxCreators)
        repo.removeImages(profile.id)
        repo.addImages(imageCreators)
        repo.removeStickers(profile.id)
        repo.addStickers(stickerCreators)
        Right(())
        /// TODO: obviously this is the jankiest most disgusting code ever
        /// but apparently it makes the frontend easier so we will leave as-is for now
        /// (because the frontend can't use our element ids. doesn't help that we have an ugly DB structure)  
      }
      case None => Left("Provided userId does not exist. No profile to update.")
    }
  }

  private def inDatabase[B](f: DbCon ?=> B): IO[B] = IO.blocking {
    connect(dataSource) {
      f
    }
  }

  def logButtonPress(
    userId: Int,
    buttonId: String,
    pressTimestamp: Int,
  ) = inDatabase {
    buttonLogRepo.insert(
      ButtonLogCreator(
        userId = userId,
        buttonId = buttonId,
        pressTimestamp = pressTimestamp,
      )
    ).asRight
  }
}
