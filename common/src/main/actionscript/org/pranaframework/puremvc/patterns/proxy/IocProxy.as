package org.pranaframework.puremvc.patterns.proxy {
  import org.pranaframework.puremvc.interfaces.IIocFacade;
  import org.pranaframework.puremvc.interfaces.IIocProxy;
  import org.pranaframework.puremvc.patterns.INamedObject;
  import org.pranaframework.puremvc.patterns.facade.IocFacade;
  import org.puremvc.interfaces.IFacade;
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
  public class IocProxy implements IIocProxy, INotifier, INamedObject {
    public static var NAME:String = "Proxy";

    private var m_iocFacade:IIocFacade = IocFacade.getInstance();
    private var m_proxyName:String;
    private var m_data:Object;

    public function IocProxy(p_proxyName:String = null, p_data:Object = null) {
      m_proxyName = (p_proxyName != null) ? p_proxyName : NAME;
      if (p_data != null) {
        setData(p_data);
      }
    }

    protected function get facade():IFacade {
      return m_iocFacade;
    }

    protected function get iocFacade():IIocFacade {
      return m_iocFacade;
    }

    public function set objectName(p_name:String):void {
      m_proxyName = p_name;
    }

    public function get objectName():String {
      return m_proxyName;
    }

    public function sendNotification(p_noteName:String, p_body:Object = null, p_type:String = null):void {
      m_iocFacade.notifyObservers(new Notification(p_noteName, p_body, p_type));
    }

    public function getProxyName():String {
      return m_proxyName;
    }

    public function setData(p_data:Object):void {
      m_data = p_data;
    }

    public function getData():Object {
      return m_data;
    }

    protected function get data():Object {
      return m_data;
    }

    protected function set data(p_data:Object):void {
      m_data = p_data;
    }
  }
}
