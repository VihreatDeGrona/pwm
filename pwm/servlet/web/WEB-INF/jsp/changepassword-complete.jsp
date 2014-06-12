<%--
  ~ Password Management Servlets (PWM)
  ~ http://code.google.com/p/pwm/
  ~
  ~ Copyright (c) 2006-2009 Novell, Inc.
  ~ Copyright (c) 2009-2014 The PWM Project
  ~
  ~ This program is free software; you can redistribute it and/or modify
  ~ it under the terms of the GNU General Public License as published by
  ~ the Free Software Foundation; either version 2 of the License, or
  ~ (at your option) any later version.
  ~
  ~ This program is distributed in the hope that it will be useful,
  ~ but WITHOUT ANY WARRANTY; without even the implied warranty of
  ~ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  ~ GNU General Public License for more details.
  ~
  ~ You should have received a copy of the GNU General Public License
  ~ along with this program; if not, write to the Free Software
  ~ Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  --%>

<!DOCTYPE html>
<%@ page language="java" session="true" isThreadSafe="true" contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="pwm" prefix="pwm" %>
<html dir="<pwm:LocaleOrientation/>">
<%@ include file="fragment/header.jsp" %>
<body class="nihilo">
<div id="wrapper">
    <jsp:include page="fragment/header-body.jsp">
        <jsp:param name="pwm.PageName" value="Title_ChangePassword"/>
    </jsp:include>
    <div id="centerbody">
        <%@ include file="fragment/message.jsp" %>
        <% final MacroMachine macroMachine = new MacroMachine(pwmApplicationHeader, pwmSessionHeader.getUserInfoBean(), pwmSessionHeader.getSessionManager().getUserDataReader(pwmApplicationHeader)); %>
        <% final String messageText = ContextManager.getPwmApplication(session).getConfig().readSettingAsLocalizedString(PwmSetting.PASSWORD_COMPLETE_MESSAGE, PwmSession.getPwmSession(session).getSessionStateBean().getLocale()); %>
        <% final String expandedText = macroMachine.expandMacros(messageText); %>
        <br/>
        <div id="agreementText" class="agreementText"><%= expandedText %></div>
        <div id="buttonbar">
            <form action="<pwm:url url='/public/CommandServlet' addContext="true"/>" method="post"
                  enctype="application/x-www-form-urlencoded" onsubmit="PWM_MAIN.handleFormSubmit(this);return false">
                    <input type="hidden" name="processAction" value="continue"/>
                    <button type="submit" name="button" class="btn" id="submitBtn">
                        <pwm:if test="showIcons"><span class="btn-icon fa fa-forward"></span></pwm:if>
                        <pwm:Display key="Button_Continue"/>
                    </button>
                <input type="hidden" name="pwmFormID" id="pwmFormID" value="<pwm:FormID/>"/>
            </form>
            <br/>
        </div>
    </div>
    <div class="push"></div>
</div>
<%@ include file="fragment/footer.jsp" %>
</body>
</html>
