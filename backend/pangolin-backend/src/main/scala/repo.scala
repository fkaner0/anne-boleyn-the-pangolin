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
  connect, transact,
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
      profileId: Int,
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
      profileId: Int,
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
      profileId: Int,
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
      profileId: Int,
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
      profileId: Int,
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
      profileId: Int,
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

  case class AccountCreator(
      username: String,
  ) derives DbCodec

  @Table(PostgresDbType)
  case class Account(
      @Id id: Int,
      username: String,
  ) derives DbCodec

  object Account {
    val Table = TableInfo[AccountCreator, Account, Int]
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
  private val accountRepo = Repo[AccountCreator, Account, Int]

  private def profileImagesSpec(profileId: Int) = Spec[ProfileImage]
    .where(sql"${ProfileImage.Table.profileId} = $profileId")

  private def profileTextboxesSpec(profileId: Int) = Spec[ProfileTextbox]
    .where(sql"${ProfileTextbox.Table.profileId} = $profileId")

  private def profileStickersSpec(profileId: Int) = Spec[ProfileSticker]
    .where(sql"${ProfileSticker.Table.profileId} = $profileId")

  val getRecommendations = inDatabase {
    profileRepo.findAll.asRight
  }

  def getProfile(profileId: Int) = inDatabase {
    profileRepo
      .findById(profileId)
      .map { profile =>
        val images = profileImageRepo.findAll(profileImagesSpec(profileId))
        val textboxes =
          profileTextboxRepo.findAll(profileTextboxesSpec(profileId))
        val stickers =
          profileStickerRepo.findAll(profileStickersSpec(profileId))
        (profile, images, textboxes, stickers)
      }
      .toRight(())
  }

  def newUser(username: String): IO[Option[Int]] = inDatabaseWithRollback {
    try {
      accountRepo.insertReturning(AccountCreator(
      username = username
      )).id.some
    } catch {
      case _ => None // I have no idea what sort of error gets thrown
      // Left("Error inserting username into database. Perhaps it already exists?")
    }
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

  private def removeTextboxes(profileId: Int)(using DbCon) = removeBySpec(profileTextboxRepo, profileTextboxesSpec(profileId), _.id)
  private def removeImages(profileId: Int)(using DbCon) = removeBySpec(profileImageRepo, profileImagesSpec(profileId), _.id)
  private def removeStickers(profileId: Int)(using DbCon) = removeBySpec(profileStickerRepo, profileStickersSpec(profileId), _.id)
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
      case None => Left("Provided profileId does not exist. No profile to update.")
    }
  }

  private def inDatabase[B](f: DbCon ?=> B): IO[B] = IO.blocking {
    connect(dataSource) {
      f
    }
  }

  private def inDatabaseWithRollback[B](f: DbCon ?=> B): IO[B] = IO.blocking {
    transact(dataSource) {
      f
      // rolls back when f throws an error
      // oh how I wish we had a nice lil effect system to indicate error thowing
    }
  }
}


