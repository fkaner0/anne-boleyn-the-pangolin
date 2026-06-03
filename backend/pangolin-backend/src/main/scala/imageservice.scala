
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
    private final val CLOUD_NAME = "dvacw0gsi"

    private final val URL = s"cloudinary://$API_KEY:$API_SECRET@$CLOUD_NAME"

    private final val cloudinary = Cloudinary(URL)
    private final val cloudinaryUploader = cloudinary.uploader()
    private final val BedroomWallUploader = CloudinaryImageUploader(cloudinaryUploader, "user_wall_default")

    // def uploadImage(file: String) = {
    //     cloudinary.uploader().upload(
    //         file, params1
    //     )
    // }
    // def deleteImage(file: String) = {
    //     cloudinary.api().
    // }

    @main
    def uploadPangolinPicture() = {
        // val inputFile = "https://images.fineartamerica.com/images/artworkimages/mediumlarge/2/pangolin-corina-st-martin.jpg"
        val inputFile = "https://th.bing.com/th/id/R.f353f9ab6e2f4d3dd0950a40ff2b6e67?rik=5az2iS4uLjkAIA&pid=ImgRaw&r=0"
        
        BedroomWallUploader.upload(inputFile)
    }


}

private object imageUploaderAPI {
    /// TODO: can newtype this xoxo
    case class ImageURL(url: String)

    trait ImageUploader:
        /// TODO: input type?
        def upload(inputFile: String): Option[ImageURL]


    /* Uploader for Cloudinary API */
    class CloudinaryImageUploader(
        cloudinaryUploader: com.cloudinary.Uploader,
        // Name of upload preset. see:
        // https://cloudinary.com/documentation/image_upload_api_reference#upload_required_parameters
        val uploadPreset: String,
    ) extends ImageUploader {
        private def getUploadResult(inputFile: String): Map[String, String] =
            /* NB: the returned values are:
                asset_folder, signature, format, resource_type, secure_url,
                created_at, asset_id, ............, width, height, etc.
            */
            cloudinaryUploader.unsignedUpload(
                inputFile, uploadPreset, null
            ).asInstanceOf[java.util.Map[String, String]]
            .asScala.toMap

        /// TODO: 'secure_url' or 'url'?
        private val urlField = "secure_url"

        def upload(inputFile: String): Option[ImageURL] = {
            val resMap = getUploadResult(inputFile)
            resMap.get(urlField).map(ImageURL(_))
        }
    }
}
