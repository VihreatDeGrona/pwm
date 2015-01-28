<%@ page import="password.pwm.PwmApplication" %>
<%@ page import="password.pwm.bean.SessionStateBean" %>
<%@ page import="password.pwm.config.FormConfiguration" %>
<%@ page import="password.pwm.config.PwmSetting" %>
<%@ page import="password.pwm.error.PwmError" %>
<%@ page import="password.pwm.http.ContextManager" %>
<%@ page import="password.pwm.http.JspUtility" %>
<%@ page import="password.pwm.http.PwmSession" %>
<%@ page import="password.pwm.i18n.Display" %>
<%@ page import="password.pwm.util.StringUtil" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>

<%--
  ~ Password Management Servlets (PWM)
  ~ http://code.google.com/p/pwm/
  ~
  ~ Copyright (c) 2006-2009 Novell, Inc.
  ~ Copyright (c) 2009-2015 The PWM Project
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

<%@ taglib uri="pwm" prefix="pwm" %>
<% // read parameters from calling jsp;
    final PwmSetting formSetting = (PwmSetting)request.getAttribute("form");
    final boolean forceReadOnly = "true".equalsIgnoreCase((String)request.getAttribute("form-readonly"));
    final boolean showPasswordFields = "true".equalsIgnoreCase((String)request.getAttribute("form_showPasswordFields"));
    final Map<FormConfiguration,String> formDataMap = (Map<FormConfiguration,String>)request.getAttribute("formData");
%>
<%
    boolean focusSet = false;
    final PwmSession pwmSession = PwmSession.getPwmSession(session);
    final PwmApplication pwmApplication = ContextManager.getPwmApplication(request);
    final SessionStateBean ssBean = pwmSession.getSessionStateBean();
    final List<FormConfiguration> formConfigurationList = pwmApplication.getConfig().readSettingAsForm(formSetting);
    for (FormConfiguration loopConfiguration : formConfigurationList) {
        String currentValue = formDataMap != null ? formDataMap.get(loopConfiguration) : "";
        currentValue = currentValue == null ? "" : currentValue;
        currentValue = StringUtil.escapeHtml(currentValue);

%>
<% if (loopConfiguration.getType().equals(FormConfiguration.Type.hidden)) { %>
<input style="text-align: left;" id="<%=loopConfiguration.getName()%>" type="hidden" class="inputfield"
       name="<%=loopConfiguration.getName()%>" value="<%= currentValue %>"/>
<% } else if (loopConfiguration.getType().equals(FormConfiguration.Type.checkbox)) { %>
<br/>
<label class="checkboxWrapper">
    <input id="<%=loopConfiguration.getName()%>" name="<%=loopConfiguration.getName()%>" type="checkbox" <% if (!focusSet) { %> autofocus<% }; focusSet = true; %>/>
    <%=loopConfiguration.getLabel(ssBean.getLocale())%>
</label>
<% } else { %>
<h2>
    <label for="<%=loopConfiguration.getName()%>"><%= loopConfiguration.getLabel(ssBean.getLocale()) %>
        <%if(loopConfiguration.isRequired()){%>
        <span style="font-style: italic; font-size: smaller" id="label_required_<%=loopConfiguration.getName()%>">*&nbsp;</span>
        <pwm:script>
        <script type="text/javascript">
            PWM_GLOBAL['startupFunctions'].push(function(){
                PWM_MAIN.showTooltip({
                    id: "label_required_<%=loopConfiguration.getName()%>",
                    text: '<%=PwmError.ERROR_FIELD_REQUIRED.getLocalizedMessage(ssBean.getLocale(),pwmApplication.getConfig(),new String[]{loopConfiguration.getLabel(ssBean.getLocale())})%>',
                    position: ['above']
                });
            });
        </script>
        </pwm:script>
        <%}%>
    </label>
</h2>
<% if (loopConfiguration.getDescription(ssBean.getLocale()) != null && loopConfiguration.getDescription(ssBean.getLocale()).length() > 0) { %>
<p><%=loopConfiguration.getDescription(ssBean.getLocale())%></p>
<% } %>
<% boolean readonly = loopConfiguration.isReadonly() || forceReadOnly; %>
<% if (readonly) { %>
<span id="<%=loopConfiguration.getName()%>">
        <span class="fa fa-chevron-circle-right"></span>
    <%= currentValue %>
</span>
<% } else if (loopConfiguration.getType() == FormConfiguration.Type.select) { %>
<select id="<%=loopConfiguration.getName()%>" name="<%=loopConfiguration.getName()%>" style="width:20%;margin-left: 5px"<% if (!focusSet) { %> autofocus<% }; focusSet = true; %>>
    <% for (final String optionName : loopConfiguration.getSelectOptions().keySet()) {%>
    <option value="<%=optionName%>" <%if(optionName.equals(currentValue)){%>selected="selected"<%}%>>
        <%=loopConfiguration.getSelectOptions().get(optionName)%>
    </option>
    <% } %>
</select>
<% } else { %>
<input style="text-align: left;" id="<%=loopConfiguration.getName()%>" type="<%=loopConfiguration.getType()%>" class="inputfield"
       name="<%=loopConfiguration.getName()%>" value="<%= currentValue %>"
        <%if(loopConfiguration.getPlaceholder()!=null){%> placeholder="<%=loopConfiguration.getPlaceholder()%>"<%}%>
        <%if(loopConfiguration.isRequired()){%> required="required"<%}%>
        <%if(loopConfiguration.isConfirmationRequired()) { %> onkeypress="PWM_MAIN.getObject('<%=loopConfiguration.getName()%>_confirm').value=''"<% } %>
       maxlength="<%=loopConfiguration.getMaximumLength()%>"<% if (!focusSet) { %> autofocus<% }; focusSet = true; %>/>
<% if (loopConfiguration.isConfirmationRequired() && !forceReadOnly && !loopConfiguration.isReadonly() && loopConfiguration.getType() != FormConfiguration.Type.hidden && loopConfiguration.getType() != FormConfiguration.Type.select) { %>
<h2>
    <label for="<%=loopConfiguration.getName()%>_confirm"><pwm:display key="Field_Confirm_Prefix"/>&nbsp;<%=loopConfiguration.getLabel(ssBean.getLocale()) %><%if(loopConfiguration.isRequired()){%>*<%}%></label>
</h2>
<input style="" id="<%=loopConfiguration.getName()%>_confirm" type="<%=loopConfiguration.getType()%>" class="inputfield"
       name="<%=loopConfiguration.getName()%>_confirm"
        <%if(loopConfiguration.getPlaceholder()!=null){%> placeholder="<%=loopConfiguration.getPlaceholder()%>"<%}%>
        <%if(loopConfiguration.isRequired()){%> required="required"<%}%>
        <%if(loopConfiguration.isReadonly()){%> readonly="readonly"<%}%>
       maxlength="<%=loopConfiguration.getMaximumLength()%>"/>
<% } %>
<% } %>
<% } %>
<% if (loopConfiguration.getJavascript() != null && loopConfiguration.getJavascript().length() > 0) { %>
<pwm:script>
<script type="text/javascript">
    try {
        <%=loopConfiguration.getJavascript()%>
    } catch (e) {
        console.log('error executing custom javascript for form field \'' + <%=loopConfiguration.getName()%> + '\', error: ' + e)
    }
</script>
</pwm:script>
<% } %>
<% } %>

<% if (showPasswordFields) { %>
<h2>
    <label for="password1"><pwm:display key="Field_NewPassword"/>
        <span style="font-style: italic;font-size:smaller" id="label_required_password">*&nbsp;</span>
        <pwm:script>
        <script type="text/javascript">
            PWM_GLOBAL['startupFunctions'].push(function(){
                PWM_MAIN.showTooltip({
                    id: "label_required_password",
                    text: '<%=PwmError.ERROR_FIELD_REQUIRED.getLocalizedMessage(ssBean.getLocale(),pwmApplication.getConfig(),new String[]{JspUtility.getMessage(pageContext,Display.Field_NewPassword)})%>',
                    position: ['above']
                });
            });
        </script>
        </pwm:script>
    </label>
</h2>
<div id="PasswordRequirements">
    <ul>
        <pwm:DisplayPasswordRequirements separator="</li>" prepend="<li>" form="newuser"/>
    </ul>
</div>
<table style="border:0; margin: 0; padding: 0">
    <tr style="border:0; margin: 0; padding: 0">
        <td style="border:0; margin: 0; padding: 0; width:60%">
            <input type="<pwm:value name="passwordFieldType"/>" name="password1" id="password1" class="changepasswordfield passwordfield" onkeypress="PWM_MAIN.getObject('password2').value=''" style="margin-left:5px"/>
        </td>
        <td style="border:0;">
            <% if (ContextManager.getPwmApplication(session).getConfig() != null && ContextManager.getPwmApplication(session).getConfig().readSettingAsBoolean(PwmSetting.PASSWORD_SHOW_STRENGTH_METER)) { %>
            <div id="strengthBox" style="visibility:hidden;">
                <div id="strengthLabel">
                    <pwm:display key="Display_StrengthMeter"/>
                </div>
                <div class="progress-container">
                    <div id="strengthBar" style="width: 0">&nbsp;</div>
                </div>
            </div>
            <pwm:script>
            <script type="text/javascript">
                PWM_GLOBAL['startupFunctions'].push(function(){
                    PWM_MAIN.showTooltip({
                        id: ["strengthBox"],
                        text: PWM_MAIN.showString('Tooltip_PasswordStrength'),
                        width: 350
                    });
                });
            </script>
            </pwm:script>
            <% } %>
        </td>
        <td style="border:0; width:10%">&nbsp;</td>
    </tr>
    <tr style="border:0; margin: 0; padding: 0">
        <td style="border:0; margin: 0; padding: 0">
            <input type="<pwm:value name="passwordFieldType"/>" name="password2" id="password2" class="changepasswordfield passwordfield" style="margin-left:5px"/>
        </td>
        <td style="border:0">
            <%-- confirmation mark [not shown initially, enabled by javascript; see also changepassword.js:markConfirmationMark() --%>
            <div style="padding-top:10px;">
                <img style="visibility:hidden;" id="confirmCheckMark" alt="checkMark" height="15" width="15"
                     src="<pwm:context/><pwm:url url='/public/resources/greenCheck.png'/>">
                <img style="visibility:hidden;" id="confirmCrossMark" alt="crossMark" height="15" width="15"
                     src="<pwm:context/><pwm:url url='/public/resources/redX.png'/>">
            </div>
        </td>
        <td style="border:0; width:10%">&nbsp;</td>
    </tr>
</table>
<% } %>
