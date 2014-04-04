cordova.define('cordova/plugin_list', function(require, exports, module) {
module.exports = [
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
    "com.tlantic.plugins.socket": "0.3.0"
}
// BOTTOM OF METADATA
});