
import com.cloudinary.Cloudinary
import com.cloudinary.utils.ObjectUtils
import io.github.cdimascio.dotenv.Dotenv
import java.awt.Image
import scala.jdk.CollectionConverters.given

object imageservice {
    import imageUploaderAPI.CloudinaryImageUploader

    private val dotenv = Dotenv.load()
    private final val API_KEY = sys.env.getOrElse("CLOUDINARY_API_KEY", dotenv.get("CLOUDINARY_API_KEY"))
    private final val API_SECRET = sys.env.getOrElse("CLOUDINARY_API_SECRET", dotenv.get("CLOUDINARY_API_SECRET"))
    private final val CLOUD_ID = "dvacw0gsi"

    private final val BedroomWallUploader = CloudinaryImageUploader(API_KEY, API_SECRET, CLOUD_ID, "user_wall_default")

    // def uploadImage(file: String) = {
    //     cloudinary.uploader().upload(
    //         file, params1
    //     )
    // }
    // def deleteImage(file: String) = {
    //     cloudinary.api().
    // }

    @main
    def uploadBedroomWallImageTest() = {
        // val inputFile = "https://images.fineartamerica.com/images/artworkimages/mediumlarge/2/pangolin-corina-st-martin.jpg"
        val inputFile = "https://th.bing.com/th/id/R.f353f9ab6e2f4d3dd0950a40ff2b6e67?rik=5az2iS4uLjkAIA&pid=ImgRaw&r=0"
        
        BedroomWallUploader.upload(inputFile)
    }

    def deleteBedroomWallImageTest() = {
        BedroomWallUploader
    }

}

private object imageUploaderAPI {
    /// TODO: can newtype these xoxo
    case class ImageURL(value: String)

    trait ImageUploader {
        /// TODO: input type?
        def upload(inputFile: String): Option[ImageURL]
    }

    object CloudinaryMisc { 
        case class ImageAssetID(value: String)
        case class ImagePublicID(value: String)
        case class ImageTypeSuffix(value: String)

        def getAccessUrl(api_key: String, api_secret: String, cloud_id: String)
            = s"cloudinary://$api_key:$api_secret@$cloud_id"

        case class ImageUploadResults(
            cloudId: String, /// TODO
            publicId: ImagePublicID,
            imgType: ImageTypeSuffix,
        ) {
            import ImageUploadResults.*

            val url: ImageURL = imageUrlFromPublicId(cloudId, publicId, imgType)
        }

        object ImageUploadResults {

            def imageUrlFromPublicId(cloud_id: String, publicID: ImagePublicID, fileSuffix: ImageTypeSuffix): ImageURL
                = ImageURL(s"https://res.cloudinary.com/$cloud_id/image/upload/${publicID.value}.${fileSuffix.value}")
    
            
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

        private def getUploadResult(inputFile: String): Map[String, String] =
            /* NB: the returned values are:
                asset_folder, signature, format, resource_type, secure_url,
                created_at, asset_id, ............, width, height, etc.
            */
            cloudinaryUploader.unsignedUpload(
                inputFile, uploadPreset, null
            ).asInstanceOf[java.util.Map[String, String]]
            .asScala.toMap

        private val upload_public_id_field = "public_id"

        def upload(inputFile: String): Option[ImageURL] =
            ImageUploadResults.fromMap(cloud_id, getUploadResult(inputFile)).map(_.url)

        def delete(fileUrl: String): Boolean = {
            // cloudinaryUploader.
            ???
        }
    }
}
