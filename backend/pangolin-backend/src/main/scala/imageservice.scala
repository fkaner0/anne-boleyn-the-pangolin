package pangolin

import com.cloudinary.Cloudinary
import com.cloudinary.utils.ObjectUtils
import io.github.cdimascio.dotenv.Dotenv
import scala.jdk.CollectionConverters.given
import imageUploaderAPI.ImageURL
import java.awt.Image

object imageservice {
    import imageUploaderAPI.{CloudinaryImageUploader, ImageUploadType}

    private final lazy val dotenv = Dotenv.load()
    private final val API_KEY = sys.env.getOrElse("CLOUDINARY_API_KEY", dotenv.get("CLOUDINARY_API_KEY"))
    private final val API_SECRET = sys.env.getOrElse("CLOUDINARY_API_SECRET", dotenv.get("CLOUDINARY_API_SECRET"))
    private final val CLOUD_ID = "dvacw0gsi"

    private final val BedroomWallUploader = CloudinaryImageUploader(API_KEY, API_SECRET, CLOUD_ID, "user_wall_default")

    def uploadBedroomWallImage(inputFile: ImageUploadType) = {
        BedroomWallUploader.upload(inputFile)
    }

    def deleteBedroomWallImage(url: String) = {
        BedroomWallUploader.delete(ImageURL(url))
    }
}

private object imageUploaderAPI {
    /// TODO: can newtype these xoxo
    case class ImageURL(value: String)

    type ImageUploadType = Array[Byte] | ImageURL

    trait ImageUploader {
        def upload(imageFile: ImageUploadType): Option[ImageURL]
    }

    object CloudinaryMisc { 
        case class ImageAssetID(value: String)
        case class ImagePublicID(value: String)
        case class ImageTypeSuffix(value: String)

        def getAccessUrl(api_key: String, api_secret: String, cloud_id: String)
            = s"cloudinary://$api_key:$api_secret@$cloud_id"

        def imageUrlFromPublicId(cloud_id: String, publicID: ImagePublicID, fileSuffix: ImageTypeSuffix): ImageURL
            = ImageURL(s"https://res.cloudinary.com/$cloud_id/image/upload/${publicID.value}.${fileSuffix.value}")

        private final val cloudinaryUrlSegments = 5

        def publicIdFromImageURL(imageURL: ImageURL): Option[ImagePublicID]
            = {
                // remove http:// section if it exists
                val pathParts = imageURL.value
                    .stripPrefix("https://")
                    .stripPrefix("http://")
                    .split("/")
                // NB: this will fail if we returned the 'versioned' url on upload (gives length 6).
                // I've added this to make sure we're consistent.
                if (pathParts.length != cloudinaryUrlSegments) return None
                val nameParts = pathParts.last.split("\\.")
                if (nameParts.length != 2) return None
                Some(ImagePublicID(nameParts.head))
            }

        case class ImageUploadResults(
            cloudId: String,    
            publicId: ImagePublicID,
            imgType: ImageTypeSuffix,
        ) {
            import ImageUploadResults.*

            val url: ImageURL = imageUrlFromPublicId(cloudId, publicId, imgType)
        }

        object ImageUploadResults {
            def fromMap(cloudId: String, uploadResMap: Map[String, String]): Option[ImageUploadResults] =
                for {
                    publicId <- uploadResMap.get("public_id")
                    imgType <- uploadResMap.get("format")
                } yield ImageUploadResults(cloudId, ImagePublicID(publicId), ImageTypeSuffix(imgType))
            }
        }


    /* Uploader for Cloudinary API */
    class CloudinaryImageUploader(
        api_key: String,
        api_secret: String,
        private val cloud_id: String,
        // Name of upload preset. see:
        // https://cloudinary.com/documentation/image_upload_api_reference#upload_required_parameters
        private val uploadPreset: String,
    ) extends ImageUploader {
        import CloudinaryMisc.*

        private final val cloudinaryUploader
            = Cloudinary(getAccessUrl(api_key, api_secret, cloud_id)).uploader()

        private def getUploadResult(imageFile: ImageUploadType): Map[String, String] =
            /* NB: the returned values are:
                asset_folder, signature, format, resource_type, secure_url,
                created_at, asset_id, ............, width, height, etc.
            */
            val imageInput: Object = imageFile match {
                case ImageURL(url) => url
                case otherImgSrc => otherImgSrc
            }

            cloudinaryUploader.unsignedUpload(
                imageInput, uploadPreset, null
            ).asInstanceOf[java.util.Map[String, String]]
                .asScala.toMap

        private def getDestroyResult(publicId: String): Map[String, String] = {
            cloudinaryUploader.destroy(
                publicId, ObjectUtils.asMap("resource_type","image")
            ).asInstanceOf[java.util.Map[String, String]]
                .asScala.toMap
        }

        private val upload_public_id_field = "public_id"

        def upload(imageFile: ImageUploadType): Option[ImageURL] =
            ImageUploadResults.fromMap(cloud_id, getUploadResult(imageFile)).map(_.url)

        def delete(fileUrl: ImageURL): Boolean = publicIdFromImageURL(fileUrl) match {
            case Some(ImagePublicID(pid)) => getDestroyResult(pid).getOrElse("result", "error") == "ok"
            case None => false
        }
    }
}
