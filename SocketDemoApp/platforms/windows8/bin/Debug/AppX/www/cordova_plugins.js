cordova.define('cordova/plugin_list', function(require, exports, module) {
module.exports = [
    {
        "file": "plugins/org.apache.cordova.dialogs/www/notification.js",
        "id": "org.apache.cordova.dialogs.notification",
        "merges": [
            "navigator.notification"
        ]
    },
    {
        "file": "plugins/org.apache.cordova.dialogs/src/windows8/NotificationProxy.js",
        "id": "org.apache.cordova.dialogs.NotificationProxy",
        "merges": [
            ""
        ]
    },
    {
        "file": "plugins/com.tlantic.plugins.socket/www/socket.js",
        "id": "com.tlantic.plugins.socket.Socket",
        "clobbers": [
            "window.tlantic.plugins.socket"
        ]
    },
    {
        "file": "plugins/com.tlantic.plugins.socket/src/windows8/Connection.js",
        "id": "com.tlantic.plugins.socket.Connection",
        "merges": [
            ""
        ]
    },
    {
        "file": "plugins/com.tlantic.plugins.socket/src/windows8/SocketProxy.js",
        "id": "com.tlantic.plugins.socket.SocketProxy",
        "merges": [
            ""
        ]
    }
];
module.exports.metadata = 
// TOP OF METADATA
{
    "org.apache.cordova.dialogs": "0.2.6",
    "com.tlantic.plugins.socket": "0.3.0"
}
// BOTTOM OF METADATA
});