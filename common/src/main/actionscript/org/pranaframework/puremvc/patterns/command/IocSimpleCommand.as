package org.pranaframework.puremvc.patterns.command {
  import org.pranaframework.puremvc.interfaces.IIocCommand;
  import org.pranaframework.puremvc.interfaces.IIocFacade;
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
  public class IocSimpleCommand implements IIocCommand, INotifier {
    private var m_iocFacade:IIocFacade = IocFacade.getInstance();

    public function IocSimpleCommand() {
      super();
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

    public function execute(p_note:INotification):void {
    }
  }
}
