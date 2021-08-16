package org.pranaframework.puremvc.interfaces {
  import org.pranaframework.ioc.ObjectContainer;
  import org.puremvc.interfaces.IFacade;

  /**
   * Description wannabe.
   *
   * <p>
   * <b>Author:</b> Damir Murat<br/>
   * <b>Version:</b> $Revision: 272 $, $Date: 2008-01-22 16:06:47 +0100 (di, 22 jan 2008) $, $Author: dmurat1 $<br/>
   * <b>Since:</b> 0.0.1
   * </p>
   */
  public interface IIocFacade extends IFacade {
    function get container():ObjectContainer;
    function registerProxyByConfigName(p_proxyName:String):void;
    function retrieveProxyByConfigName(p_proxyName:String):IIocProxy;
    function removeProxyByConfigName(p_proxyName:String):void;
    function registerMediatorByConfigName(p_mediatorName:String, p_viewComponent:Object = null):void;
    function retrieveMediatorByConfigName(p_mediatorName:String):IIocMediator;
    function removeMediatorByConfigName(p_mediatorName:String):void;
    function registerCommandByConfigName(p_noteName:String, p_configName:String):void;
  }
}
