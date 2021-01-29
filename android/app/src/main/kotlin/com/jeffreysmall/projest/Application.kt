private fun createChannel(){
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        // Create the NotificationChannel
        val name = getString(R.string.default_notification_channel_id)
        val channel = NotificationChannel(name, "default", NotificationManager.IMPORTANCE_HIGH)
        val notificationManager: NotificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.createNotificationChannel(channel)
    }
}

override fun onCreate() {
    super.onCreate()
    createChannel()
    .........
}