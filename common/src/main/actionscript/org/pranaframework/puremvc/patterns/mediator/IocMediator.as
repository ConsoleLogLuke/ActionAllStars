package org.pranaframework.puremvc.patterns.mediator {
  import org.pranaframework.puremvc.interfaces.IIocFacade;
  import org.pranaframework.puremvc.interfaces.IIocMediator;
  import org.pranaframework.puremvc.patterns.INamedObject;
  import org.pranaframework.puremvc.patterns.facade.IocFacade;
  import org.puremvc.interfaces.IFacade;
  import org.puremvc.interfaces.INotification;
  import org.puremvc.interfaces.INotifier;
  import org.puremvc.patterns.observer.Notification;

  /**
   * Description wannabe.
   *
   * <p>
   * <b>Author:</b> Damir Murat<br/>
   * <b>Version:</b> $Revision: 272 $, $Date: 2008-01-22 16:06:47 +0100 (di, 22 jan 2008) $, $Author: dmurat1 $<br/>
   * <b>Since:</b> 0.0.1
   * </p>
   */
  public class IocMediator implements IIocMediator, INotifier, INamedObject {
    public static const NAME:String = "Mediator";

    private var m_iocFacade:IIocFacade = IocFacade.getInstance();
    private var m_viewComponent:Object;
    private var m_mediatorName:String;

    public function IocMediator(p_viewComponent:Object = null, p_mediatorName:String = null) {
      m_viewComponent = p_viewComponent;
      m_mediatorName = (p_mediatorName != null) ? p_mediatorName : NAME;
    }

    protected function get facade():IFacade {
      return m_iocFacade;
    }

    protected function get iocFacade():IIocFacade {
      return m_iocFacade;
    }

    public function sendNotification(p_noteName:String, p_body:Object = null, p_type:String = null):void {
      m_iocFacade.notifyObservers(new Notification(p_noteName, p_body, p_type));
    }

    public function set objectName(p_objectName:String):void {
      m_mediatorName = p_objectName;
    }

    public function get objectName():String {
      return m_mediatorName;
    }

    public function getMediatorName():String {
      return m_mediatorName;
    }

    public function getViewComponent():Object {
      return m_viewComponent;
    }

    protected function get viewComponent():Object {
      return m_viewComponent;
    }

    protected function set viewComponent(p_viewComponent:Object):void {
      m_viewComponent = p_viewComponent;
    }

    public function listNotificationInterests():Array {
      return [];
    }

    public function handleNotification(p_note:INotification):void {
    }
  }
}
