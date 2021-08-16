package org.pranaframework.puremvc.interfaces {
  import org.puremvc.interfaces.IController;

  /**
   * Description wannabe.
   *
   * <p>
   * <b>Author:</b> Damir Murat<br/>
   * <b>Version:</b> $Revision: 272 $, $Date: 2008-01-22 16:06:47 +0100 (di, 22 jan 2008) $, $Author: dmurat1 $<br/>
   * <b>Since:</b> 0.0.3
   * </p>
   */
  public interface IIocController extends IController {
    function registerCommandByConfigName(p_notificationName:String, p_configName:String):void;
  }
}
