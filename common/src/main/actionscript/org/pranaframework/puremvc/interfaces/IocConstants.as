package org.pranaframework.puremvc.interfaces {

  /**
   * Description wannabe.
   *
   * <p>
   * <b>Author:</b> Damir Murat<br/>
   * <b>Version:</b> $Revision: 272 $, $Date: 2008-01-22 16:06:47 +0100 (di, 22 jan 2008) $, $Author: dmurat1 $<br/>
   * <b>Since:</b> 0.0.1
   * </p>
   */
  public class IocConstants {
    public static const PROXY_NAMES_MAP:String = "proxyNamesMap";
    public static const MEDIATOR_NAMES_MAP:String = "mediatorNamesMap";
    public static const COMMAND_NAMES_MAP:String = "commandNamesMap";

    public function IocConstants() {
      throw new Error("This class is only constants container. It can't be instantiated.");
    }
  }
}
