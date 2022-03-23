package com.dubberss.koo.flutter_meta_share

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.ContentResolver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.util.Log
import android.webkit.MimeTypeMap
import androidx.annotation.NonNull
import androidx.core.content.FileProvider
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.*
import java.util.*


const val INSTAGRAM_PACKAGE_NAME = "com.instagram.android"
const val FACEBOOK_PACKAGE_NAME = "com.facebook.katana"


/** FlutterPromotionPlugin */
class FlutterMetaSharePlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var activity: Activity

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_meta_share")
        context = flutterPluginBinding.applicationContext
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromActivity() {
//        TODO("Not yet implemented")
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
//        TODO("Not yet implemented")
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
//        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
//        TODO("Not yet implemented")
    }


    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when {
            call.method.equals("is_instagram_installed") -> {
                result.success(
                    isPackageInstalled(
                        packageName = INSTAGRAM_PACKAGE_NAME,
                        context = context
                    )
                )
            }
            call.method.equals("is_facebook_installed") -> {
                result.success(
                    isPackageInstalled(
                        packageName = FACEBOOK_PACKAGE_NAME,
                        context = context
                    )
                )
            }
            call.method.equals("share_instagram") -> {
                val filePath = call.argument<String?>("filePath")
                shareInstagram(result = result, filePath = filePath)
            }
            call.method.equals("share_facebook") -> {
                val filePath = call.argument<String?>("filePath")
                shareFacebook(result = result, filePath = filePath)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun isPackageInstalled(packageName: String, context: Context): Boolean {
        return try {
            val packageManager = context.packageManager
            packageManager.getPackageInfo(packageName, PackageManager.GET_ACTIVITIES)
            Log.d("isPackageInstalled","isPackageInstalled : ${packageName}")
            true
        } catch (e: PackageManager.NameNotFoundException) {
            Log.d("NameNotFoundException","name = ${e}")
            false
        }
    }

    private fun getExternalShareFolder(): File {
        return File(context.externalCacheDir, "share")
    }

    private fun copyToExternalShareFolder(file: File): File {
        val folder: File = getExternalShareFolder()
        if (!folder.exists()) {
            folder.mkdirs()
        }
        val newFile = File(folder, file.name)

        copy(file, newFile)
        return newFile
    }

    @kotlin.jvm.Throws(IOException::class)
    fun copy(src: File?, dst: File?) {
        val `in`: InputStream = FileInputStream(src)
        try {
            val out: OutputStream = FileOutputStream(dst)
            try {
                // Transfer bytes from in to out
                val buf = ByteArray(1024)
                var len: Int
                while (`in`.read(buf).also { len = it } > 0) {
                    out.write(buf, 0, len)
                }
            } finally {
                out.close()
            }
        } finally {
            `in`.close()
        }
    }

    private fun fileIsOnExternal(file: File): Boolean {
        return try {
            val filePath = file.canonicalPath
            val externalDir = context.getExternalFilesDir(null)
            externalDir != null && filePath.startsWith(externalDir.canonicalPath)
        } catch (e: IOException) {
            false
        }
    }


    private fun getMimeType(uri: Uri): String? {
        val mimeType: String? = if (ContentResolver.SCHEME_CONTENT == uri.scheme) {
            val cr: ContentResolver = context.contentResolver
            cr.getType(uri)
        } else {
            val fileExtension = MimeTypeMap.getFileExtensionFromUrl(
                uri
                    .toString()
            )
            MimeTypeMap.getSingleton().getMimeTypeFromExtension(
                fileExtension.toLowerCase(Locale.ROOT)
            )
        }
        return mimeType
    }


    private fun shareInstagram(filePath: String?, @NonNull result: Result) {
        if (!isPackageInstalled(INSTAGRAM_PACKAGE_NAME, context)) {
            result.success(false)
            return
        }

        var _file: File? = File(filePath!!)


        if (!fileIsOnExternal(_file!!)) {
            _file = copyToExternalShareFolder(_file)
        }

        val asset = FileProvider.getUriForFile(
            context, context.packageName + ".flutter.shares_provider", _file
        )

        Log.d("MIME TYPE","TYPE : ${getMimeType(asset)}")
        val mimeType = getMimeType(asset)

        val feedIntent = Intent(Intent.ACTION_SEND)
        feedIntent.type = mimeType
        feedIntent.putExtra(Intent.EXTRA_STREAM, asset)
        feedIntent.setPackage(INSTAGRAM_PACKAGE_NAME)
        feedIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)


        val storyIntent = Intent("com.instagram.share.ADD_TO_STORY")
        storyIntent.type = mimeType
        storyIntent.setDataAndType(asset, mimeType)
        storyIntent.setPackage(INSTAGRAM_PACKAGE_NAME)

        feedIntent.putExtra(Intent.EXTRA_INITIAL_INTENTS, storyIntent)
        try {
            context.startActivity(feedIntent)
            result.success(true)
        } catch (e: ActivityNotFoundException) {
            result.success(false)
        }
    }

    private fun shareFacebook(filePath: String?, @NonNull result: Result) {
        if (!isPackageInstalled(FACEBOOK_PACKAGE_NAME, context)) {
            result.success(false)
            return
        }

        var _file: File? = File(filePath!!)

        if (!fileIsOnExternal(_file!!)) {
            _file = copyToExternalShareFolder(_file)
        }

        val asset = FileProvider.getUriForFile(
            context, context.packageName + ".flutter.shares_provider", _file
        )


        Log.d("MIME TYPE","TYPE : ${getMimeType(asset)}")
        val mimeType = getMimeType(asset)


        val feedIntent = Intent(Intent.ACTION_SEND)
        feedIntent.type = mimeType
        feedIntent.putExtra(Intent.EXTRA_STREAM, asset)
        feedIntent.setPackage(FACEBOOK_PACKAGE_NAME)
        feedIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)

        val storyIntent = Intent("com.facebook.stories.ADD_TO_STORY")
        storyIntent.type = mimeType
        storyIntent.setDataAndType(asset, mimeType)
        storyIntent.setPackage(FACEBOOK_PACKAGE_NAME)

        feedIntent.putExtra(Intent.EXTRA_INITIAL_INTENTS, storyIntent)

        try {
            context.startActivity(feedIntent)
            result.success(true)
        } catch (e: ActivityNotFoundException) {
            result.success(false)
        }
    }




}
