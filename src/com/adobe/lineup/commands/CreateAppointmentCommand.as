/*
    Adobe Systems Incorporated(r) Source Code License Agreement
    Copyright(c) 2005 Adobe Systems Incorporated. All rights reserved.
    
    Please read this Source Code License Agreement carefully before using
    the source code.
    
    Adobe Systems Incorporated grants to you a perpetual, worldwide, non-exclusive, 
    no-charge, royalty-free, irrevocable copyright license, to reproduce,
    prepare derivative works of, publicly display, publicly perform, and
    distribute this source code and such derivative works in source or 
    object code form without any attribution requirements.  
    
    The name "Adobe Systems Incorporated" must not be used to endorse or promote products
    derived from the source code without prior written permission.
    
    You agree to indemnify, hold harmless and defend Adobe Systems Incorporated from and
    against any loss, damage, claims or lawsuits, including attorney's 
    fees that arise or result from your use or distribution of the source 
    code.
    
    THIS SOURCE CODE IS PROVIDED "AS IS" AND "WITH ALL FAULTS", WITHOUT 
    ANY TECHNICAL SUPPORT OR ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING,
    BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  ALSO, THERE IS NO WARRANTY OF 
    NON-INFRINGEMENT, TITLE OR QUIET ENJOYMENT.  IN NO EVENT SHALL ADOBE 
    OR ITS SUPPLIERS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
    EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
    PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
    OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
    WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
    OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOURCE CODE, EVEN IF
    ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
package com.adobe.lineup.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.exchange.Calendar;
	import com.adobe.exchange.RequestConfig;
	import com.adobe.exchange.events.ExchangeAppointmentEvent;
	import com.adobe.exchange.events.FBAAuthenticatedEvent;
	import com.adobe.exchange.events.FBAAuthenticationFailedEvent;
	import com.adobe.exchange.events.FBAChallengeEvent;
	import com.adobe.lineup.events.CreateAppointmentEvent;
	import com.adobe.lineup.events.ShowAlertEvent;
	import com.adobe.lineup.model.ModelLocator;
	
	import flash.events.IOErrorEvent;
	import flash.net.URLRequestDefaults;

	public class CreateAppointmentCommand implements ICommand
	{

		public function execute(e:CairngormEvent):void
		{
			var cae:CreateAppointmentEvent = CreateAppointmentEvent(e);
			var ml:ModelLocator = ModelLocator.getInstance();

			ml.busy = true;

			URLRequestDefaults.setLoginCredentialsForHost(ml.serverInfo.exchangeServer, ml.serverInfo.exchangeUsername, ml.serverInfo.exchangePassword);

			var rc:RequestConfig = new RequestConfig();
			rc.username = ml.serverInfo.exchangeUsername;
			rc.password = ml.serverInfo.exchangePassword;
			rc.domain = ml.serverInfo.exchangeDomain;
			rc.server = ml.serverInfo.exchangeServer;
			rc.secure = ml.serverInfo.useHttps;
			
			var cal:Calendar = new Calendar();
			cal.requestConfig = rc;
			cal.addEventListener(IOErrorEvent.IO_ERROR,
				function(e:IOErrorEvent):void
				{
					/* ml.online = false;
					if (gae.updateUI)
					{
						populateFromDatabase(gae.startDate, gae.endDate);
					} */
				});

			cal.addEventListener(FBAChallengeEvent.FBA_CHALLENGE_EVENT,
				function(fce:FBAChallengeEvent):void
				{
					cal.fba();
				});

			cal.addEventListener(FBAAuthenticatedEvent.FBA_AUTHENTICATED_EVENT,
				function(fae:FBAAuthenticatedEvent):void
				{
					cal.createAppointment(cae.appointment);
				});

			cal.addEventListener(FBAAuthenticationFailedEvent.FBA_AUTHENTICATION_FAILED_EVENT,
				function(fafe:FBAAuthenticationFailedEvent):void
				{
					var sae:ShowAlertEvent = new ShowAlertEvent();
					sae.title = "Authentication Failed";
					sae.message = "Unable to authenticate using forms-base authentication. Please check your Exchange information.";
					sae.dispatch();
					ModelLocator.getInstance().busy = false;
					ModelLocator.getInstance().online = false;
					ModelLocator.getInstance().serverConfigOpen = true;
				});

			cal.addEventListener(ExchangeAppointmentEvent.EXCHANGE_APPOINTMENT_CREATED,
				function onAppointmentCreated(exchangeEvent:ExchangeAppointmentEvent):void
				{
				/* 	ml.online = true;
					ml.lastSynchronized = new Date();
		
					var appointments:Array = exchangeEvent.appointments;					
					ml.db.deleteAppointments(gae.startDate, gae.endDate);
					if (appointments != null && appointments.length > 0)
					{
						ml.db.insertAppointments(appointments);
					}
					if (gae.updateUI)
					{
						populateFromDatabase(gae.startDate, gae.endDate);
					}
					else
					{
						ml.busy = false;
					} */
				});
			cal.createAppointment(cae.appointment);
			// For testing purposes only
			//this.populateFromDatabase(gae.startDate, gae.endDate);
		}
	}
}