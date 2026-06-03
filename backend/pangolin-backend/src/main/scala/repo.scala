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

  case class ProfileTextboxCreator(
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
  case class ProfileTextbox(
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

  object ProfileTextbox {
    val Table = TableInfo[ProfileTextboxCreator, ProfileTextbox, Int]
  }

  case class ProfileStickerCreator(
      userId: Int,
      stickerName: String,
      x: Int,
      y: Int,
      rotation: Int,
      aspectRatio: Double,
      scale: Double,
  ) extends Positioned derives DbCodec

  @Table(PostgresDbType)
  case class ProfileSticker(
      @Id id: Int,
      userId: Int,
      stickerName: String,
      x: Int,
      y: Int,
      rotation: Int,
      aspectRatio: Double,
      scale: Double,
  ) extends Positioned derives DbCodec

  object ProfileSticker {
    val Table = TableInfo[ProfileStickerCreator, ProfileSticker, Int]
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
      sys.env.getOrElse("DB_PASSWORD", Dotenv.load().get("DB_PASSWORD")),
    )
    ds.setPortNumber(5432)
    ds.setUrl(
      "jdbc:postgresql://dpg-d8cbgu3eo5us73eq2hl0-a.frankfurt-postgres.render.com/",
    )
    ds
  }

  private val profileImageRepo = Repo[ProfileImageCreator, ProfileImage, Int]
  private val profileTextboxRepo =
    Repo[ProfileTextboxCreator, ProfileTextbox, Int]
  private val profileStickerRepo = Repo[ProfileStickerCreator, ProfileSticker, Int]
 
  private val profileRepo = Repo[ProfileCreator, Profile, Int]

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
      "Placeholder Name",
      "Placeholder Location",
      "https://placehold.co/400x400.jpg"
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
        userId: Int,
        profile: Profile,
        textboxCreators: Iterable[ProfileTextboxCreator],
        imageCreators: Iterable[ProfileImageCreator],
        stickerCreators: Iterable[ProfileStickerCreator],
  ) = repo.inDatabase {
    profileRepo.findById(userId) match {
      //// TODO: this is wrong I think. why check that a profile exists already? maybe check the userIds match tho?
      case Some(existingProfile) => {
        repo.profileRepo.update(profile)
        repo.removeTextboxes(userId)
        repo.addTextboxes(textboxCreators)
        repo.removeImages(userId)
        repo.addImages(imageCreators)
        repo.removeStickers(userId)
        repo.addStickers(stickerCreators)
        Right(())
      }
      case None => Left(())
    }
  }

  private def inDatabase[B](f: DbCon ?=> B): IO[B] = IO.blocking {
    connect(dataSource) {
      f
    }
  }
}


