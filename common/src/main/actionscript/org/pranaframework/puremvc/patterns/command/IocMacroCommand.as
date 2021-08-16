package org.pranaframework.puremvc.patterns.command {
  import org.pranaframework.puremvc.interfaces.IIocCommand;
  import org.pranaframework.puremvc.interfaces.IIocFacade;
  import org.pranaframework.puremvc.patterns.facade.IocFacade;
  import org.puremvc.interfaces.ICommand;
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
  public class IocMacroCommand implements IIocCommand, INotifier {
    private var m_iocFacade:IIocFacade = IocFacade.getInstance();
    private var m_subCommands:Array;

    public function IocMacroCommand() {
      super();

      m_subCommands = new Array();
      initializeMacroCommand();
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

    protected function initializeMacroCommand():void {
    }

    protected function addSubCommand(p_commandClassRef:Class):void {
      m_subCommands.push(p_commandClassRef);
    }

    public final function execute(p_note:INotification):void {
      while (m_subCommands.length > 0) {
        var commandClassRef:Class = m_subCommands.shift();
        var commandInstance:ICommand = new commandClassRef();
        commandInstance.execute(p_note);
      }
    }
  }
}
