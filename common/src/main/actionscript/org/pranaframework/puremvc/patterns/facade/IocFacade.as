package org.pranaframework.puremvc.patterns.facade {
  import flash.events.EventDispatcher;
  import flash.utils.Dictionary;

  import mx.logging.ILogger;
  import mx.logging.Log;

  import org.pranaframework.ioc.ObjectContainer;
  import org.pranaframework.ioc.ObjectDefinitionNotFoundError;
  import org.pranaframework.ioc.loader.ObjectDefinitionsLoaderEvent;
  import org.pranaframework.ioc.loader.XmlObjectDefinitionsLoader;
  import org.pranaframework.puremvc.core.controller.IocController;
  import org.pranaframework.puremvc.interfaces.IIocController;
  import org.pranaframework.puremvc.interfaces.IIocFacade;
  import org.pranaframework.puremvc.interfaces.IIocMediator;
  import org.pranaframework.puremvc.interfaces.IIocProxy;
  import org.pranaframework.puremvc.interfaces.IocConstants;
  import org.pranaframework.puremvc.patterns.INamedObject;
  import org.puremvc.core.model.Model;
  import org.puremvc.core.view.View;
  import org.puremvc.interfaces.IMediator;
  import org.puremvc.interfaces.IModel;
  import org.puremvc.interfaces.INotification;
  import org.puremvc.interfaces.IProxy;
  import org.puremvc.interfaces.IView;

  /**
   * Description wannabe.
   *
   * <p>
   * <b>Author:</b> Damir Murat<br/>
   * <b>Version:</b> $Revision: 272 $, $Date: 2008-01-22 16:06:47 +0100 (di, 22 jan 2008) $, $Author: dmurat1 $<br/>
   * <b>Since:</b> 0.0.1
   * </p>
   */
  public class IocFacade extends EventDispatcher implements IIocFacade {
    // Message Constants
    private static const LOGGER:ILogger = Log.getLogger("net.croz.puremvcprana.patterns.facade.IocFacade");
    private static const PROXY_NAME_PROPERTY:String = "proxyName";

    // The Singleton Facade instance.
    private static var m_instance:IIocFacade;

    // Private references to Model, View and Controller
    private var m_controller:IIocController;
    private var m_model:IModel;
    private var m_view:IView;
    private var m_proxyNamesMap:Dictionary;
    private var m_mediatorNamesMap:Dictionary;

    private var m_objectsLoader:XmlObjectDefinitionsLoader;

    public function IocFacade(p_configUrl:String) {
      if (m_instance != null) {
        throw Error("Facade Singleton already constructed!");
      }

      m_instance = this;
      m_proxyNamesMap = new Dictionary();
      m_mediatorNamesMap = new Dictionary();
      initializeIocContainer(p_configUrl);
    }

    public static function getInstance(p_configuration:String = null):IIocFacade {
      if (m_instance == null) {
        if (p_configuration == null) {
          throw new Error("Parameter p_configUrl can't be null.");
        }
      }

      return m_instance;
    }

    protected static function get instance():IIocFacade {
      return m_instance;
    }

    protected static function set instance(p_instance:IIocFacade):void {
      m_instance = p_instance;
    }

    protected function initializeIocContainer(p_configUrl:String):void {
      if (p_configUrl == null) {
        throw new Error("Parameter p_configUrl can't be null.");
      }

      m_objectsLoader = new XmlObjectDefinitionsLoader();
      m_objectsLoader.addEventListener(
        ObjectDefinitionsLoaderEvent.COMPLETE, onObjectDefinitionsLoaderListenerComplete);
      m_objectsLoader.load(p_configUrl);
    }

    protected function onObjectDefinitionsLoaderListenerComplete(p_event:ObjectDefinitionsLoaderEvent):void {
      m_objectsLoader.removeEventListener(
          ObjectDefinitionsLoaderEvent.COMPLETE, onObjectDefinitionsLoaderListenerComplete);
      initializeFacade();
      try {
        m_proxyNamesMap = container.getObject(IocConstants.PROXY_NAMES_MAP);
        m_mediatorNamesMap = container.getObject(IocConstants.MEDIATOR_NAMES_MAP);
      }
      catch (error:ObjectDefinitionNotFoundError) {
        // do nothing
      }

      dispatchEvent(new ObjectDefinitionsLoaderEvent(ObjectDefinitionsLoaderEvent.COMPLETE));
    }

    public function get container():ObjectContainer {
      if (m_objectsLoader != null) {
        return m_objectsLoader.container;
      }
      else {
        LOGGER.warn("IoC Container is not initialized. Returning null.");
        return null;
      }
    }

    protected function initializeFacade():void {
      initializeModel();
      initializeController();
      initializeView();
    }

    protected function initializeModel():void {
      if (m_model != null) {
        return;
      }

      m_model = Model.getInstance();
    }

    protected function initializeController():void {
      if (m_controller != null) {
        return;
      }

      m_controller = IocController.getInstance(container);
    }

    protected function initializeView( ):void {
      if (m_view != null) {
        return;
      }

      m_view = View.getInstance();
    }

    public function notifyObservers(p_note:INotification):void {
      if (m_view != null) {
        m_view.notifyObservers(p_note);
      }
    }

    public function registerProxy(p_proxy:IProxy):void {
      m_model.registerProxy(p_proxy);
    }

    public function retrieveProxy(p_proxyName:String):IProxy {
      return m_model.retrieveProxy(p_proxyName);
    }

    public function removeProxy(p_proxyName:String):void {
      if (m_model != null) {
        m_model.removeProxy(p_proxyName);
      }
    }

    public function registerCommand(p_noteName:String, p_commandClassRef:Class):void {
      m_controller.registerCommand(p_noteName, p_commandClassRef);
    }

    public function removeCommand(p_noteName:String):void {
      m_controller.removeCommand(p_noteName);
    }

    public function registerMediator(p_mediator:IMediator):void {
      if (m_view != null) {
        m_view.registerMediator(p_mediator);
      }
    }

    public function retrieveMediator(p_mediatorName:String):IMediator {
      return m_view.retrieveMediator(p_mediatorName) as IMediator;
    }

    public function removeMediator(p_mediatorName:String):void {
      if (m_view != null) {
        m_view.removeMediator(p_mediatorName);
      }
    }

    public function registerProxyByConfigName(p_proxyName:String):void {
      var proxy:IIocProxy = null;
      var configName:String = m_proxyNamesMap[p_proxyName];

      // First try to find an object by mapped name
      if (configName != null) {
        // This will thorw an error if the object definition can't be found
        proxy = container.getObject(configName);
        (proxy as INamedObject).objectName = configName;
      }
      // If there is no value for mapped name available, try with supplied name.
      else {
        // This will thorw an error if the object definition can't be found
        proxy = container.getObject(p_proxyName);
        (proxy as INamedObject).objectName = p_proxyName;
      }

      m_model.registerProxy(proxy);
    }

    public function retrieveProxyByConfigName(p_proxyName:String):IIocProxy {
      var configName:String = m_proxyNamesMap[p_proxyName];
      var returnValue:IIocProxy = null;

      if (configName != null) {
        returnValue = m_model.retrieveProxy(configName) as IIocProxy;
      }
      // If there is no value for mapped name available, try with supplied name.
      else {
        // This will thorw an error if the object definition can't be found
        returnValue = container.getObject(p_proxyName);
      }

      return returnValue;
    }

    public function removeProxyByConfigName(p_proxyName:String):void {
      var configName:String = m_proxyNamesMap[p_proxyName];
      if (configName != null) {
        container.clearObjectFromInternalCache(configName);
      }
      // If there is no value for mapped name available, try with supplied name.
      else {
        container.clearObjectFromInternalCache(p_proxyName);
      }
    }

    public function registerMediatorByConfigName(p_mediatorName:String, p_viewComponent:Object = null):void {
      var mediator:IIocMediator = null;
      var configName:String = m_mediatorNamesMap[p_mediatorName];

      if (configName != null) {
        if (p_viewComponent != null) {
          mediator = container.getObject(configName, [p_viewComponent]);
        }
        else {
          mediator = container.getObject(configName);
        }

        (mediator as INamedObject).objectName = configName;
      }
      else {
        if (p_viewComponent != null) {
          mediator = container.getObject(p_mediatorName, [p_viewComponent]);
        }
        else {
          mediator = container.getObject(p_mediatorName);
        }

        (mediator as INamedObject).objectName = p_mediatorName;
      }

      m_view.registerMediator(mediator);
    }

    public function retrieveMediatorByConfigName(p_mediatorName:String):IIocMediator {
      var configName:String = m_mediatorNamesMap[p_mediatorName];
      var returnValue:IIocMediator = null;

      if (configName != null) {
        returnValue = m_view.retrieveMediator(configName) as IIocMediator;
      }
      // If there is no value for mapped name available, try with supplied name.
      else {
        // This will thorw an error if the object definition can't be found
        returnValue = container.getObject(p_mediatorName);
      }

      return returnValue;
    }

    public function removeMediatorByConfigName(p_mediatorName:String):void {
      var configName:String = m_mediatorNamesMap[p_mediatorName];
      if (configName != null) {
        container.clearObjectFromInternalCache(configName);
      }
      // If there is no value for mapped name available, try with supplied name.
      else {
        container.clearObjectFromInternalCache(p_mediatorName);
      }
    }

    public function registerCommandByConfigName(p_noteName:String, p_configName:String):void {
      m_controller.registerCommandByConfigName(p_noteName, p_configName);
    }

//    public function iocRegisterProxyByInterface(p_interface:Class, p_enforcePrototype:Boolean = true):void {
//      var classDescription:XML = describeType(p_interface);
//      if (classDescription.factory.extendsClass.length() > 0) {
//        throw new Error("Parameter 'p_interface' must reference interface, not class!");
//      }
//
//      var objectDefinitions:IMap = container.objectDefinitions;
//      var objectDefinitionsCursor:MapViewCursor = new MapViewCursor(objectDefinitions);
//      var found:Boolean = false;
//      var objectDefinition:ObjectDefinition;
//      var objectDefinitionClass:Class;
//      var foundObjectDefinition:ObjectDefinition;
//      do {
//        objectDefinition = objectDefinitionsCursor.current as ObjectDefinition;
//        objectDefinitionClass = getDefinitionByName(objectDefinition.className) as Class;
//        if (ClassUtils.isImplementationOf(objectDefinitionClass, p_interface)) {
//          found = true;
//          foundObjectDefinition = objectDefinition;
//        }
//      }
//      while (objectDefinitionsCursor.moveNext() && !found);
//
//      if (!found) {
//        throw new Error("None of object definitions does not implement interface '" + p_interface + "'.");
//      }
//
//      if (p_enforcePrototype) {
//        if (foundObjectDefinition.isSingleton) {
//          throw new Error("Object definition '" + foundObjectDefinition + "' must be prototype. Not singleton!");
//        }
//      }
//
//      for (var objectDefinitionKey:* in objectDefinitions) {
//        if (objectDefinitions[objectDefinitionKey] == foundObjectDefinition) {
//          m_model.registerProxy(container.getObject(objectDefinitionKey as String));
//          break;
//        }
//      }
//    }
  }
}
