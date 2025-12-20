package com.example.phonepe_flutter

import android.provider.ContactsContract
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "neupe.contacts").setMethodCallHandler { call, result ->
			if (call.method == "getContacts") {
				// Run the potentially heavy content-provider query off the UI thread.
				Thread {
					try {
						val resolver = applicationContext.contentResolver
						val uri = ContactsContract.CommonDataKinds.Phone.CONTENT_URI
						val projection = arrayOf(
							ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME,
							ContactsContract.CommonDataKinds.Phone.NUMBER
						)
						val cursor = resolver.query(uri, projection, null, null, null)
						val contacts = ArrayList<Map<String, String>>()
						cursor?.use {
							val nameIdx = it.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME)
							val numIdx = it.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER)
							while (it.moveToNext()) {
								val name = if (nameIdx >= 0) it.getString(nameIdx) ?: "" else ""
								val number = if (numIdx >= 0) it.getString(numIdx) ?: "" else ""
								contacts.add(mapOf("name" to name, "phone" to number))
							}
						}
						// Post result back on UI thread and log count
						runOnUiThread {
							result.success(contacts)
						}
					} catch (ex: Exception) {
						runOnUiThread {
							result.error("contacts_error", ex.message, null)
						}
					}
				}.start()
			} else {
				result.notImplemented()
			}
		}
	}
}
