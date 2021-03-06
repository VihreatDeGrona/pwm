<%@ page import="password.pwm.util.StringUtil" %>
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

<!DOCTYPE html>

<%@ page language="java" session="true" isThreadSafe="true"
         contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="pwm" prefix="pwm" %>
<%
    final PwmRequest pwmRequest = JspUtility.getPwmRequest(pageContext);
%>
<% JspUtility.setFlag(pageContext, PwmRequest.Flag.HIDE_HEADER_WARNINGS); %>
<html dir="<pwm:LocaleOrientation/>">
<%@ include file="fragment/header.jsp" %>
<body class="nihilo">
<div id="wrapper">
    <jsp:include page="fragment/header-body.jsp">
        <jsp:param name="pwm.PageName" value="<%=JspUtility.getAttribute(pageContext,PwmConstants.REQUEST_ATTR.PageTitle)%>"/>
    </jsp:include>
    <div id="centerbody">
        <%@ include file="/WEB-INF/jsp/fragment/message.jsp" %>
        <style nonce="<pwm:value name="cspNonce"/>">
            .buttoncell {
                border: 0;
                width:50%;
            }
            .buttonrow {
                height: 45px;
                margin-top: 20px;
                margin-bottom: 20px;
            }
            .menubutton {
                cursor: pointer;
                display: block;
                margin-left: auto;
                margin-right: auto;

            }
        </style>
        <table style="width:550px">
            <col class="key" style="width:150px">
            <col class="key" style="width:400px">
            <tr>
                <td>
                    Configuration Status
                </td>
                <td>
                    <pwm:if test="configurationOpen">Open</pwm:if>
                    <pwm:if test="configurationOpen" negate="true">Closed</pwm:if>
                </td>
            </tr>
            <tr>
                <td>
                    Last Modified
                </td>
                <td>
                    <% String lastModified = (String)JspUtility.getAttribute(pageContext, PwmConstants.REQUEST_ATTR.ConfigLastModified); %>
                    <% if (lastModified == null) { %>
                    <pwm:display key="Value_NotApplicable"/>
                    <% } else { %>
                    <span class="timestamp"><%=lastModified%></span>
                    <% } %>
                </td>
            </tr>
            <tr>
                <td>
                    Password Protected
                </td>
                <td>
                    <%=JspUtility.getAttribute(pageContext, PwmConstants.REQUEST_ATTR.ConfigHasPassword)%>
                </td>
            </tr>
            <tr>
                <td>
                    Application Data Path
                </td>
                <td>
                    <div style="max-width:398px; overflow-x: auto; white-space: nowrap">
                        <%=StringUtil.escapeHtml((String) JspUtility.getAttribute(pageContext, PwmConstants.REQUEST_ATTR.ApplicationPath))%>
                    </div>
                </td>
            </tr>
            <tr>
                <td>
                    Configuration File
                </td>
                <td>
                    <div style="max-width:398px; overflow-x: auto; white-space: nowrap">
                        <%=StringUtil.escapeHtml((String) JspUtility.getAttribute(pageContext, PwmConstants.REQUEST_ATTR.ConfigFilename))%>
                    </div>
                </td>
            </tr>
        </table>
        <br/>
        <div id="healthBody" style="margin-top:5px; margin-left: 20px; margin-right: 20px; padding:0; max-height: 300px; overflow-y: auto">
            <div class="WaitDialogBlank"></div>
        </div>
        <br/>
        <table class="noborder">
            <tr class="buttonrow">
                <td class="buttoncell">
                    <a class="menubutton" id="MenuItem_ConfigEditor">
                        <pwm:if test="showIcons"><span class="btn-icon fa fa-edit"></span></pwm:if>
                        <pwm:display key="MenuItem_ConfigEditor" bundle="Admin"/>
                    </a>
                    <pwm:script>
                        <script type="application/javascript">
                            PWM_GLOBAL['startupFunctions'].push(function(){
                                PWM_MAIN.addEventHandler('MenuItem_ConfigEditor','click',function(){PWM_CONFIG.startConfigurationEditor()});
                                makeTooltip('MenuItem_ConfigEditor',PWM_CONFIG.showString('MenuDisplay_ConfigEditor'));
                            });
                        </script>
                    </pwm:script>
                </td>
                <td class="buttoncell">
                    <a class="menubutton" id="MenuItem_ViewLog">
                        <pwm:if test="showIcons"><span class="btn-icon fa fa-list-alt"></span></pwm:if>
                        <pwm:display key="MenuItem_ViewLog" bundle="Config"/>
                    </a>
                    <pwm:script>
                        <script type="application/javascript">
                            PWM_GLOBAL['startupFunctions'].push(function(){
                                PWM_MAIN.addEventHandler('MenuItem_ViewLog','click',function(){PWM_CONFIG.openLogViewer(null)});
                                makeTooltip('MenuItem_ViewLog',PWM_CONFIG.showString('MenuDisplay_ViewLog'));
                            });
                        </script>
                    </pwm:script>
                </td>
            </tr>
            <tr class="buttonrow">
                <td class="buttoncell">
                    <a class="menubutton" id="MenuItem_DownloadBundle">
                        <pwm:if test="showIcons"><span class="btn-icon fa fa-suitcase"></span></pwm:if>
                        <pwm:display key="MenuItem_DownloadBundle" bundle="Config"/>
                    </a>
                    <pwm:script>
                        <script type="application/javascript">
                            PWM_GLOBAL['startupFunctions'].push(function(){
                                PWM_MAIN.addEventHandler('MenuItem_DownloadBundle','click',function(){PWM_CONFIG.downloadSupportBundle()});
                                makeTooltip('MenuItem_DownloadBundle',PWM_CONFIG.showString('MenuDisplay_DownloadBundle'));
                            });
                        </script>
                    </pwm:script>
                </td>
                <td class="buttoncell">
                    <a class="menubutton" id="MenuItem_DownloadConfig">
                        <pwm:if test="showIcons"><span class="btn-icon fa fa-download"></span></pwm:if>
                        <pwm:display key="MenuItem_DownloadConfig" bundle="Config"/>
                    </a>
                    <pwm:script>
                        <script type="application/javascript">
                            PWM_GLOBAL['startupFunctions'].push(function(){
                                PWM_MAIN.addEventHandler('MenuItem_DownloadConfig','click',function(){PWM_CONFIG.downloadConfig()});
                                makeTooltip('MenuItem_DownloadConfig',PWM_CONFIG.showString('MenuDisplay_DownloadConfig'));
                            });
                        </script>
                    </pwm:script>
                </td>
            </tr>
            <tr class="buttonrow">
                <td class="buttoncell">
                    <pwm:if test="configurationOpen">
                        <a class="menubutton" id="MenuItem_LockConfig">
                            <pwm:if test="showIcons"><span class="btn-icon fa fa-lock"></span></pwm:if>
                            <pwm:display key="MenuItem_LockConfig" bundle="Config"/>
                        </a>
                        <pwm:script>
                            <script type="application/javascript">
                                PWM_GLOBAL['startupFunctions'].push(function(){
                                    makeTooltip('MenuItem_LockConfig',PWM_CONFIG.showString('MenuDisplay_LockConfig',{value1:'<%=StringUtil.escapeJS((String)JspUtility.getAttribute(pageContext, PwmConstants.REQUEST_ATTR.ConfigFilename))%>'}));
                                    PWM_MAIN.addEventHandler('MenuItem_LockConfig','click',function(){
                                        PWM_CONFIG.lockConfiguration();
                                    });
                                });
                            </script>
                        </pwm:script>
                    </pwm:if>
                    <pwm:if test="configurationOpen" negate="true">
                        <a class="menubutton" id="MenuItem_UnlockConfig">
                            <pwm:if test="showIcons"><span class="btn-icon fa fa-unlock"></span></pwm:if>
                            <pwm:display key="MenuItem_UnlockConfig" bundle="Config"/>
                        </a>
                        <pwm:script>
                            <script type="application/javascript">
                                PWM_GLOBAL['startupFunctions'].push(function(){
                                    PWM_MAIN.addEventHandler('MenuItem_UnlockConfig','click',function(){
                                        PWM_MAIN.showDialog({
                                            title:'Alert',
                                            width:500,
                                            text:PWM_CONFIG.showString('MenuDisplay_UnlockConfig',{
                                                value1:'<%=StringUtil.escapeJS((String)JspUtility.getAttribute(pageContext,PwmConstants.REQUEST_ATTR.ConfigFilename))%>'
                                            })
                                        });
                                    });
                                });
                            </script>
                        </pwm:script>
                    </pwm:if>
                </td>
                <td class="buttoncell">
                    <a class="menubutton" id="MenuItem_UploadConfig">
                        <pwm:if test="showIcons"><span class="btn-icon fa fa-upload"></span></pwm:if>
                        <pwm:display key="MenuItem_UploadConfig" bundle="Config"/>
                    </a>
                    <pwm:script>
                        <script type="application/javascript">
                            PWM_GLOBAL['startupFunctions'].push(function(){
                                makeTooltip('MenuItem_UploadConfig',PWM_CONFIG.showString('MenuDisplay_UploadConfig'));
                                PWM_MAIN.addEventHandler('MenuItem_UploadConfig',"click",function(){
                                    <pwm:if test="configurationOpen">
                                    PWM_MAIN.showConfirmDialog({text:PWM_CONFIG.showString('MenuDisplay_UploadConfig'),okAction:function(){PWM_CONFIG.uploadConfigDialog()}})
                                    </pwm:if>
                                    <pwm:if test="configurationOpen" negate="true">
                                    configClosedWarning();
                                    </pwm:if>
                                });
                            });
                        </script>
                    </pwm:script>
                </td>
            </tr>
            <tr class="buttonrow">
                <td class="buttoncell">
                    <a class="menubutton"id="MenuItem_MainMenu">
                        <pwm:if test="showIcons"><span class="btn-icon fa fa-arrow-circle-left"></span></pwm:if>
                        <pwm:display key="MenuItem_MainMenu" bundle="Config"/>
                    </a>
                    <pwm:script>
                        <script type="application/javascript">
                            PWM_GLOBAL['startupFunctions'].push(function(){
                                PWM_MAIN.addEventHandler('MenuItem_MainMenu','click',function(){PWM_MAIN.goto('/')});
                                makeTooltip('MenuItem_MainMenu',PWM_CONFIG.showString('MenuDisplay_MainMenu'));
                            });
                        </script>
                    </pwm:script>
                </td>
                <td class="buttoncell">
                    <a class="menubutton" id="MenuItem_ExportLocalDB">
                        <pwm:if test="showIcons"><span class="btn-icon fa fa-download"></span></pwm:if>
                        <pwm:display key="MenuItem_ExportLocalDB" bundle="Config"/>
                    </a>
                    <pwm:script>
                        <script type="application/javascript">
                            PWM_GLOBAL['startupFunctions'].push(function(){
                                PWM_MAIN.addEventHandler('MenuItem_ExportLocalDB','click',function(){PWM_CONFIG.downloadLocalDB()});
                                makeTooltip('MenuItem_ExportLocalDB',PWM_CONFIG.showString('MenuDisplay_ExportLocalDB'));
                            });
                        </script>
                    </pwm:script>
                </td>
            </tr>
            <tr class="buttonrow">
                <td class="buttoncell">
                    <a class="menubutton" id="MenuItem_Administration">
                        <pwm:if test="showIcons"><span class="btn-icon fa fa-dashboard"></span></pwm:if>
                        <pwm:display key="Title_Admin"/>
                    </a>
                    <pwm:script>
                        <script type="application/javascript">
                            PWM_GLOBAL['startupFunctions'].push(function(){
                                PWM_MAIN.addEventHandler('MenuItem_Administration','click',function(){PWM_MAIN.goto('/private/admin/')});
                                makeTooltip('MenuItem_Administration',PWM_MAIN.showString('Long_Title_Admin'));
                            });
                        </script>
                    </pwm:script>
                </td>
                <td class="buttoncell">
                    <a class="menubutton" id="MenuItem_UploadLocalDB">
                        <pwm:if test="showIcons"><span class="btn-icon fa fa-upload"></span></pwm:if>
                        Import (Upload) LocalDB Archive File
                    </a>
                    <pwm:script>
                        <script type="application/javascript">
                            PWM_GLOBAL['startupFunctions'].push(function(){
                                makeTooltip('MenuItem_UploadConfig',PWM_CONFIG.showString('MenuDisplay_UploadConfig'));
                                PWM_MAIN.addEventHandler('MenuItem_UploadLocalDB',"click",function(){
                                    <pwm:if test="configurationOpen">
                                    PWM_CONFIG.uploadLocalDB();
                                    </pwm:if>
                                    <pwm:if test="configurationOpen" negate="true">
                                    configClosedWarning();
                                    </pwm:if>
                                });
                            });
                        </script>
                    </pwm:script>
                </td>
            </tr>
            <tr class="buttonrow">
                <td class="buttoncell">
                    <a class="menubutton" id="MenuItem_ConfigurationSummary" href="#">
                        <pwm:if test="showIcons"><span class="btn-icon fa fa-files-o"></span></pwm:if>
                        Configuration Summary
                    </a>
                    <pwm:script>
                        <script type="application/javascript">
                            PWM_GLOBAL['startupFunctions'].push(function(){
                                PWM_MAIN.addEventHandler('MenuItem_ConfigurationSummary','click',function(){
                                    window.open('ConfigManager?processAction=summary','_blank', 'width=650,toolbar=0,location=0,menubar=0');
                                });
                            });
                        </script>
                    </pwm:script>

                </td>
            </tr>
        </table>
    </div>
</div>
<div class="push"></div>
<pwm:script>
    <script type="text/javascript">
        PWM_GLOBAL['startupFunctions'].push(function(){
            require(["dojo/parser","dijit/TitlePane","dojo/domReady!","dojox/form/Uploader"],function(dojoParser){
                dojoParser.parse();
            });
            PWM_VAR['config_localDBLogLevel'] = '<%=pwmRequest.getConfig().getEventLogLocalDBLevel()%>'

            require(["dojo/domReady!"],function(){
                PWM_ADMIN.showAppHealth('healthBody', {showRefresh: true, showTimestamp: true});
            });
        });

        function makeTooltip(id,text) {
            PWM_MAIN.showTooltip({
                id: id,
                showDelay: 800,
                position: ['below','above'],
                text: text,
                width: 300
            });
        }

        function configClosedWarning() {
            PWM_MAIN.showDialog({
                title:PWM_MAIN.showString('Title_Error'),
                text:"This operation is not available when the configuration is closed."
            });
        }

    </script>
</pwm:script>
<pwm:script-ref url="/public/resources/js/configmanager.js"/>
<pwm:script-ref url="/public/resources/js/admin.js"/>
<div><%@ include file="fragment/footer.jsp" %></div>
</body>
</html>
