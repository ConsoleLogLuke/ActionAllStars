/**
 * Copyright (c) 2007, the original author(s)
 * 
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 *     * Redistributions of source code must retain the above copyright notice,
 *       this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the Prana Framework nor the names of its contributors
 *       may be used to endorse or promote products derived from this software
 *       without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
 package org.pranaframework.cairngorm {
	
	import com.adobe.cairngorm.business.ServiceLocator;
	
	import mx.rpc.IResponder;
	import mx.rpc.remoting.RemoteObject;
	
	import org.pranaframework.utils.Assert;
	
	/**
	 * AbstractRemoteObjectDelegate acts as a base class for business delegates
	 * that use a RemoteObject service.
	 * 
	 * @author Christophe Herreman
	 */
	public class AbstractRemoteObjectDelegate {
		
		private var _responder:IResponder;
		private var _service:RemoteObject;
		
		/**
		 * Creates a new AbstractRemoteObjectDelegate object.
		 * 
		 * @param responder the responder that will handle the remote call
		 * @param serviceName the name of the service as defined in the service locator
		 */
		public function AbstractRemoteObjectDelegate(responder:IResponder, serviceName:String) {
			private::responder = responder;
			private::service = ServiceLocator.getInstance().getRemoteObject(serviceName);
			// note: this.reponder = responder; will not work because of a compiler bug
			// http://kb.adobe.com/selfservice/viewContent.do?externalId=4a146409&sliceId=1
		}
		
		/**
		 * Returns the current reponder for this delegate.
		 * @return IResponder
		 */
		protected function get responder():IResponder {
			return _responder;
		}
		
		private function set responder(value:IResponder):void {
			Assert.notNull(value, "Responder must not be null");
			_responder = value;
		}
		
		/**
		 * Returns the current service for this delegate.
		 * @return RemoteObject
		 */
		protected function get service():RemoteObject {
			return _service;
		}
		
		private function set service(value:RemoteObject):void {
			Assert.notNull(value, "Service must not be null");
			_service = value;
		}
		
	}
}