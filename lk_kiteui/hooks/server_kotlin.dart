Map<String, String> serverFileContents(String packageId, String projectName) {
  return {
    "AuthenticationEndpoints.kt": authEndpointsFile(packageId, projectName),
    "authHelpers.kt": authHelpersFile(packageId),
    "AwsHandler.kt": awsHandlerFile(packageId),
    "Emails.kt": emailsFile(packageId),
    "Main.kt": mainFile(packageId),
    "Server.kt": serverFile(packageId),
    "UserEndpoints.kt": userEndpointsFile(packageId)
  };
}

String authEndpointsFile(String packageId, String projectName) {
  return '''
package $packageId

import com.lightningkite.UUID
import com.lightningkite.lightningdb.*
import com.lightningkite.lightningserver.auth.AuthType
import com.lightningkite.lightningserver.auth.Authentication
import com.lightningkite.lightningserver.auth.RequestAuth
import com.lightningkite.lightningserver.auth.proof.EmailProofEndpoints
import com.lightningkite.lightningserver.auth.proof.OneTimePasswordProofEndpoints
import com.lightningkite.lightningserver.auth.proof.PasswordProofEndpoints
import com.lightningkite.lightningserver.auth.proof.PinHandler
import com.lightningkite.lightningserver.auth.subject.AuthEndpointsForSubject
import com.lightningkite.lightningserver.core.ServerPath
import com.lightningkite.lightningserver.core.ServerPathGroup
import com.lightningkite.lightningserver.email.Email
import com.lightningkite.lightningserver.email.EmailLabeledValue
import com.lightningkite.lightningserver.exceptions.NotFoundException
import com.lightningkite.lightningserver.settings.generalSettings
import com.lightningkite.toEmailAddress
import kotlinx.html.html
import kotlinx.html.stream.createHTML
import kotlinx.serialization.KSerializer


class AuthenticationEndpoints(path: ServerPath): ServerPathGroup(path){

    // Base for pins that are used in email and phone proofs
    val pins = PinHandler(Server.cache, "pins")

    // Endpoints for proofing you own a specific email for authentication
    val proofEmail = EmailProofEndpoints(
        path = path("proof/email"),
        pin = pins,
        email = Server.email,
        emailTemplate = { to, pin ->
            Email(
                subject = "$projectName Log In",
                to = listOf(EmailLabeledValue(to)),
                html = createHTML(true).let {
                    it.html {
                        emailBase {
                            header("Log In Code")
                            paragraph("Your log in code is:")
                            code(pin)
                            paragraph("If you did not request this code, you can safely ignore this email.")
                        }
                    }
                }
            )
        },
        verifyEmail = { it.toEmailAddress(); true }
    )

    // Endpoints for establishing and verifying otp for a user
    val proofOtp = OneTimePasswordProofEndpoints(path("proof/otp"), Server.database, Server.cache)

    // Endpoints for establishing and validating passwords
    val proofPassword = PasswordProofEndpoints(path("proof/password"), Server.database, Server.cache)

    // Endpoints for establishing a session for a user after generating proofs
    val userAuth = AuthEndpointsForSubject(
        path("user"),
        object : Authentication.SubjectHandler<User, UUID> {
            override val name: String get() = "User"
            override val authType: AuthType get() = AuthType<User>()
            override val idSerializer: KSerializer<UUID>
                get() = Server.users.info.serialization.idSerializer
            override val subjectSerializer: KSerializer<User>
                get() = Server.users.info.serialization.serializer

            override suspend fun fetch(id: UUID): User = Server.users.info.collection().get(id) ?: throw NotFoundException()
            override suspend fun findUser(property: String, value: String): User? = when (property) {
                "email" -> Server.users.info.collection().findOne(condition { it.email eq value.toEmailAddress() }) ?: run {
                    Server.users.info.collection().insertOne(User(email = value.toEmailAddress(), name = ""))!!
                }

//                "phone" -> users.info.collection().findOne(condition { it.phone eq value })
                "_id" -> Server.users.info.collection().get(UUID.parse(value))
                else -> null
            }

            override val knownCacheTypes: List<RequestAuth.CacheKey<User, UUID, *>> = listOf(RoleCacheKey)

            override suspend fun desiredStrengthFor(result: User): Int =
                if (result.role >= UserRole.Admin) Int.MAX_VALUE else 5
        },
        database = Server.database
    )


}
'''
      .trim();
}

String authHelpersFile(String packageId) {
  return '''
package $packageId

import com.lightningkite.UUID
import com.lightningkite.lightningserver.auth.RequestAuth
import com.lightningkite.lightningserver.typed.AuthAccessor
import com.lightningkite.lightningserver.typed.auth
import kotlinx.serialization.KSerializer
import kotlin.time.Duration
import kotlin.time.Duration.Companion.minutes


// A cache key for caching the users role in an access token
object RoleCacheKey : RequestAuth.CacheKey<User, UUID, UserRole>() {
    override val name: String
        get() = "role"
    override val serializer: KSerializer<UserRole>
        get() = UserRole.serializer()
    override val validFor: Duration
        get() = 5.minutes

    override suspend fun calculate(auth: RequestAuth<User>): UserRole = auth.get().role
}

suspend fun RequestAuth<User>.role() = this.get(RoleCacheKey)
suspend fun AuthAccessor<User>.role() = this.auth.get(RoleCacheKey)
'''
      .trim();
}

awsHandlerFile(String packageId) {
  return '''package $packageId

import com.lightningkite.lightningserver.aws.AwsAdapter
import com.lightningkite.lightningserver.aws.prepareModelsServerAws
import com.lightningkite.lightningserver.db.DynamoDbCache

class AwsHandler : AwsAdapter() {
    init {
        Server
        DynamoDbCache
        prepareModelsServerAws()
        preventLambdaTimeoutReuse = true
        loadSettings()
    }
}'''
      .trim();
}

String emailsFile(String packageId) {
  return '''
package $packageId

import com.lightningkite.lightningserver.settings.generalSettings
import kotlinx.html.*


interface EmailContentBuilder {
    fun header(text: String)
    fun paragraph(text: String)
    fun buttonLink(text: String, href: String)
    fun code(text: String)
}

fun HTML.emailBase(centralContent: EmailContentBuilder.()->Unit) {
    dir = Dir.ltr
    lang = "en"
    head {
        meta {
            content = "text/html; charset=UTF-8"
            attributes["http-equiv"] = "Content-Type"
        }
    }
    body {
        style = "background-color:#ffffff"
        table {
            attributes["align"] = "center"
            attributes["width"] = "100%"
            attributes["border"] = "0"
            attributes["cellpadding"] = "0"
            attributes["cellspacing"] = "0"
            role = "presentation"
            style = mapOf(
                "max-width" to "37.5em",
                "background-color" to "#ffffff",
                "border" to "1px solid #eee",
                "border-radius" to "5px",
                "box-shadow" to "0 5px 10px rgba(20,50,70,.2)",
                "margin" to "0 auto",
                "background-position-x" to "center",
                "background-position-y" to "top",
                "background-repeat" to "repeat-y",
                "background-size" to "contain",
            ).entries.joinToString(";") { "\${it.key}:\${it.value}" }
            tbody {
                tr {
                    style = "width:100%"
                    td {
                        style = "padding:32px;"
                        centralContent(object: EmailContentBuilder {
                            override fun header(text: String) = with(this@td) {
                                h2 {
                                    style = "font-family: sans-serif"
                                    +text
                                }
                            }

                            override fun paragraph(text: String) = with(this@td) {
                                p {
                                    style = "font-family: sans-serif"
                                    +text
                                }
                            }

                            override fun buttonLink(text: String, href: String) {
                                table {
                                    attributes["align"] = "center"
                                    attributes["width"] = "100%"
                                    attributes["border"] = "0"
                                    attributes["cellpadding"] = "0"
                                    attributes["cellspacing"] = "0"
                                    role = "presentation"
                                    style = "border-radius:4px;margin:16px auto 14px;vertical-align:middle;width:280px"
                                    tbody {
                                        tr {
                                            td {
                                                style = mapOf(
                                                    "background-color" to "#002b3f",
                                                    "padding" to "16px",
                                                    "border-radius" to "8px",
                                                ).entries.joinToString(";") { "\${it.key}:\${it.value}" }
                                                a {
                                                    this.href = href
                                                    style = "text-decoration: none;color: #FFFFFF;font-family: sans-serif;font-size:22px;line-height:40px;margin:auto auto;display:inline-block;font-weight:900;text-align:center;width:100%"
                                                    +text
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            override fun code(text: String) = with(this@td) {
                                table {
                                    attributes["align"] = "center"
                                    attributes["width"] = "100%"
                                    attributes["border"] = "0"
                                    attributes["cellpadding"] = "0"
                                    attributes["cellspacing"] = "0"
                                    role = "presentation"
                                    style = "border-radius:4px;margin:16px auto 14px;vertical-align:middle;width:280px"
                                    tbody {
                                        tr {
                                            td {
                                                p {
                                                    style = "font-family: sans-serif;font-size:32px;line-height:40px;margin:0 auto;display:inline-block;font-weight:900;letter-spacing:6px;padding-bottom:30px;padding-top:20px;width:100%;text-align:center"
                                                    +text
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                        })

                    }
                }
            }
        }

    }
}
'''
      .trim();
}

String mainFile(String packageId) {
  return '''package $packageId

import com.lightningkite.kotlinercli.cli
import com.lightningkite.lightningserver.aws.terraform.createTerraform
import com.lightningkite.lightningserver.ktor.runServer
import com.lightningkite.lightningserver.pubsub.LocalPubSub
import com.lightningkite.lightningserver.settings.Settings
import com.lightningkite.lightningserver.settings.loadSettings
import com.lightningkite.lightningserver.typed.Documentable
import com.lightningkite.lightningserver.typed.kotlinSdkLocal
import java.io.File

private lateinit var settingsFile: File

fun setup(settings: File = File("settings.json")) {
    settingsFile = settings
    println("Using settings \${settingsFile.absolutePath}")
    Server
}

private fun setup2() {
    if (!Settings.sealed)
        loadSettings(settingsFile)
}

fun serve() {
    setup2()
    runServer(LocalPubSub, Server.cache())
}

fun terraform() {
    println("Generating Terraform")
    createTerraform("$packageId.AwsHandler", "{{project_name}}", File("server/terraform"))
    println("Finished Generating Terraform")
}

fun sdk() {
    Documentable.kotlinSdkLocal("$packageId.sdk", File("apps/src/commonMain/kotlin/com/lightningkite/template/sdk"))
}

fun main(vararg args: String) = cli(
    args,
    ::setup,
    listOf(
        ::serve,
        ::terraform,
        ::sdk
    )
)'''
      .trim();
}

String serverFile(String packageId) {
  return '''package $packageId

import com.lightningkite.lightningserver.auth.Authentication
import com.lightningkite.lightningserver.auth.authRequired
import com.lightningkite.lightningserver.cache.CacheSettings
import com.lightningkite.lightningserver.core.ServerPath
import com.lightningkite.lightningserver.core.ServerPathGroup
import com.lightningkite.lightningserver.db.DatabaseSettings
import com.lightningkite.lightningserver.email.EmailSettings
import com.lightningkite.lightningserver.http.HttpResponse
import com.lightningkite.lightningserver.http.handler
import com.lightningkite.lightningserver.meta.metaEndpoints
import com.lightningkite.lightningserver.settings.setting
import com.lightningkite.prepareModelsServerCore

object Server: ServerPathGroup(ServerPath.root) {

    val cache = setting("cache", CacheSettings())
    val database = setting("database", DatabaseSettings())
    val email = setting("email", EmailSettings())

    init{
        RoleCacheKey

        prepareModelsShared()
        prepareModelsServerCore()
        com.lightningkite.prepareModelsShared()

        Authentication.isDeveloper = authRequired<User> {
            it.role() >= UserRole.Developer
        }
        Authentication.isSuperUser = authRequired<User> {
            it.role() >= UserRole.Root
        }
        Authentication.isAdmin = authRequired<User> {
            it.role() >= UserRole.Admin
        }
    }

    val root = get.handler {
        HttpResponse.redirectToGet(meta.admin.path.toString() + "models/auction")
    }

    val users = UserEndpoints(path("users"))
    val auth = AuthenticationEndpoints(path("auth"))


    val meta = path("meta").metaEndpoints()
}'''
      .trim();
}

String userEndpointsFile(String packageId) {
  return '''package $packageId

import com.lightningkite.*
import com.lightningkite.lightningdb.*
import com.lightningkite.lightningserver.auth.authOptions
import com.lightningkite.lightningserver.auth.id
import com.lightningkite.lightningserver.core.*
import com.lightningkite.lightningserver.db.ModelRestEndpoints
import com.lightningkite.lightningserver.db.ModelSerializationInfo
import com.lightningkite.lightningserver.db.modelInfo
import com.lightningkite.lightningserver.db.modelInfoWithDefault
import com.lightningkite.lightningserver.tasks.startupOnce
import com.lightningkite.lightningserver.typed.auth


class UserEndpoints(path: ServerPath) : ServerPathGroup(path) {

    val info = Server.database.modelInfo(
        serialization = ModelSerializationInfo<User, UUID>(),
        authOptions = authOptions<User>(),
        permissions = {
            val allowedRoles = UserRole.entries.filter { it <= auth.role() }
            val admin: Condition<User> =
                if (this.auth.role() >= UserRole.Admin) condition { it.role inside allowedRoles } else Condition.Never
            val self = condition<User> { it._id eq auth.id }
            ModelPermissions(
                create = admin,
                read = admin or self,
                update = admin or self,
                updateRestrictions = updateRestrictions {
                    it.role.requires(admin) { it.inside(allowedRoles) }
                },
                delete = admin or self,
            )
        }
    )

    val rest = ModelRestEndpoints(path, info)
//    val socketUpdates = ModelRestUpdatesWebsocket(path, Server.database, info)

    init {
        startupOnce("initAdminUser", Server.database) {
            println("Adding user")
            val email = "joseph+root@lightningkite.com".toEmailAddress()
            info.collection().deleteMany(condition { it.email.eq(email) })
            info.collection().insertOne(
                User(
                    _id = UUID(0L, 10L),
                    email = email,
                    name = "Joseph Root",
                    role = UserRole.Root
                )
            )
        }
    }
}'''
      .trim();
}
