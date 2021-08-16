package com.electrotank.electroserver4.plugin {
    import com.electrotank.electroserver4.entities.*;
    import com.electrotank.electroserver4.plugin.*;
    import com.electrotank.electroserver4.esobject.*;
    /**
     * This class is used to represent a plugin that is to be created and associated with a room. See the CreateRoomRequest class for a thorough create room example that includes creating a plugin.
     */
    
    public class Plugin {

        private    var data:EsObject;
        private var extensionName:String;
        private var pluginName:String;
        private var pluginHandle:String;
        public function Plugin() {
            data = new EsObject();
        }
        /**
         * The name of the extension that holds the plugin to be created.
         * @param    The name of the extension.
         */
        public function setExtensionName(extensionName:String):void {

            this.extensionName = extensionName;
        }
        /**
         * Gets the extension name.
         * @return The extension name.
         */
        public function getExtensionName():String {
            return extensionName;
        }
        /**
         * The name to give the plugin that is being created. So it is like an instance name. setPluginHandle is where you specify the name by which the plugin is stored in the extension.
         * @param    The name of the plugin.
         */
        public function setPluginName(pluginName:String):void {

            this.pluginName = pluginName;
        }
        /**
         * The name of the plugin that is being created.
         * @return The name you are giving to a plugin that is being created.
         */
        public function getPluginName():String {
            return pluginName;
        }
        /**
         * The name the plugin goes by in the extension.
         * @param    The name the plugin goes by in the extension.
         */
        public function setPluginHandle(pluginHandle:String):void {

            this.pluginHandle = pluginHandle;
        }
        /**
         * Gets the plugin handle.
         * @return The plugin handle.
         */
        public function getPluginHandle():String {
            return pluginHandle;
        }
        /**
         * Gets an EsObject that will be passed into the plugin's init event.
         * @return
         */
        public function getData():EsObject {
            return data;
        }
    }
}
