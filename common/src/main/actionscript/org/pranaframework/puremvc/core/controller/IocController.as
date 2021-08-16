package org.pranaframework.puremvc.core.controller {
  import flash.utils.Dictionary;

  import org.pranaframework.ioc.ObjectContainer;
  import org.pranaframework.ioc.ObjectDefinitionNotFoundError;
  import org.pranaframework.puremvc.interfaces.IIocCommand;
  import org.pranaframework.puremvc.interfaces.IIocController;
  import org.pranaframework.puremvc.interfaces.IocConstants;
  import org.puremvc.core.view.View;
  import org.puremvc.interfaces.ICommand;
  import org.puremvc.interfaces.INotification;
  import org.puremvc.interfaces.IView;
  import org.puremvc.patterns.observer.Observer;

  /**
   * Description wannabe.
   *
   * <p>
   * <b>Author:</b> Damir Murat<br/>
   * <b>Version:</b> $Revision: 271 $, $Date: 2008-01-22 16:05:18 +0100 (di, 22 jan 2008) $, $Author: dmurat1 $<br/>
   * <b>Since:</b> 0.0.3
   * </p>
   */
  public class IocController implements IIocController {
    protected static const SINGLETON_MSG:String = "Controller Singleton already constructed!";
    protected static var m_instance:IIocController;

    protected var m_view:IView;
    protected var m_commandMap:Array;
    protected var m_iocCommandMap:Array;
    protected var m_iocContainer:ObjectContainer;
    private var m_commandNamesMap:Dictionary;

    public static function getInstance(p_iocContainer:ObjectContainer):IIocController {
      if (m_instance == null) {
        m_instance = new IocController(p_iocContainer);
      }

      return m_instance;
    }

    public function IocController(p_iocContainer:ObjectContainer) {
      super();

      if (m_instance != null) {
        throw Error(SINGLETON_MSG);
      }
      m_instance = this;
      m_commandMap = new Array();
      m_iocContainer = p_iocContainer;
      m_iocCommandMap = new Array();

      try {
        m_commandNamesMap = m_iocContainer.getObject(IocConstants.COMMAND_NAMES_MAP);
      }
      catch (error:ObjectDefinitionNotFoundError) {
        m_commandNamesMap = new Dictionary();
      }

      initializeController();
    }

    protected function initializeController():void {
      m_view = View.getInstance();
    }

    public function executeCommand(p_note:INotification):void {
      var commandClassRef:Class = m_commandMap[p_note.getName()];

      if (commandClassRef != null) {
        var commandInstance:ICommand = new commandClassRef();
        commandInstance.execute(p_note);
        return;
      }

      var commandConfigName:String = m_iocCommandMap[p_note.getName()];
      if (commandConfigName != null) {
        var iocCommandInstance:IIocCommand = m_iocContainer.getObject(commandConfigName) as IIocCommand;
        iocCommandInstance.execute(p_note);
        return;
      }
    }

    public function registerCommand(p_notificationName:String, p_commandClassRef:Class):void {
      if (m_commandMap[p_notificationName] == null) {
        m_view.registerObserver(p_notificationName, new Observer(executeCommand, this));
      }

      m_commandMap[p_notificationName] = p_commandClassRef;
    }

    public function registerCommandByConfigName(p_notificationName:String, p_commandName:String):void {
      var configName:String = m_commandNamesMap[p_commandName];
      if (configName == null) {
        configName = p_commandName;
      }

      if (m_iocCommandMap[configName] == null) {
        m_view.registerObserver(p_notificationName, new Observer(executeCommand, this));
      }

      m_iocCommandMap[p_notificationName] = configName;
    }

    public function removeCommand(p_notificationName:String):void {
      if (m_commandMap[p_notificationName] != null) {
        m_commandMap[p_notificationName] == null
        return;
      }

      if (m_iocCommandMap[p_notificationName] != null) {
        m_iocContainer.clearObjectFromInternalCache(m_iocCommandMap[p_notificationName]);
        m_iocCommandMap[p_notificationName] = null;
        return;
      }
    }
  }
}
