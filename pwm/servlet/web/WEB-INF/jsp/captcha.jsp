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
<html dir="<pwm:LocaleOrientation/>">
<%@ include file="fragment/header.jsp" %>
<body class="nihilo">
<%-- begin reCaptcha section (http://code.google.com/apis/recaptcha/docs/display.html) --%>
<pwm:script-ref url="<%=(String)JspUtility.getAttribute(pageContext,PwmConstants.REQUEST_ATTR.CaptchaClientUrl)%>"/>
<pwm:script>
    <script type="text/javascript">
        PWM_GLOBAL['startupFunctions'].push(function(){
            Recaptcha.create("<%=StringUtil.escapeJS((String)JspUtility.getAttribute(pageContext,PwmConstants.REQUEST_ATTR.CaptchaPublicKey))%>",
                    "recaptcha_widget",
                    {
                        theme: "custom",
                        lang: '<%=JspUtility.getPwmRequest(pageContext).getLocale()%>',
                        callback: Recaptcha.focus_response_field
                    }
            );
        });
    </script>
</pwm:script>
<div id="wrapper">
    <jsp:include page="fragment/header-body.jsp">
        <jsp:param name="pwm.PageName" value="Title_Captcha"/>
    </jsp:include>
    <div id="centerbody">
        <p><pwm:display key="Display_Captcha"/></p>
        <%@ include file="fragment/message.jsp" %>
        <br/>
        <form action="<pwm:url url='Captcha'/>" method="post" enctype="application/x-www-form-urlencoded" name="verifyCaptcha" class="pwm-form">
            <div class="recaptcha_WaitDialogBlank">
                <div id="recaptcha_widget" style="display:none" class="recaptcha_widget">
                    <div id="recaptcha_image"></div>
                    <div class="recaptcha_input">
                        <label class="recaptcha_only_if_image" for="recaptcha_response_field"><pwm:display key="Display_CaptchaInputWords"/></label>
                        <label class="recaptcha_only_if_audio" for="recaptcha_response_field"><pwm:display key="Display_CaptchaInputNumbers"/></label>
                        <input type="text" id="recaptcha_response_field" name="recaptcha_response_field">
                    </div>
                    <ul class="recaptcha_options">
                        <li>
                            <a href="javascript:Recaptcha.reload()">
                                <span class="fa fa-refresh" title="<pwm:display key="Display_CaptchaRefresh"/>"></span>
                            </a>
                        </li>
                        <li class="recaptcha_only_if_image">
                            <a href="javascript:Recaptcha.switch_type('audio')">
                                <span class="fa fa-volume-up" title="<pwm:display key="Display_CaptchaGetAudio"/>"></span>
                            </a>
                        </li>
                        <li class="recaptcha_only_if_audio">
                            <a href="javascript:Recaptcha.switch_type('image')">
                                <span class="fa fa-picture" title="<pwm:display key="Display_CaptchaGetImage"/>"></span>
                            </a>
                        </li>
                        <li>
                            <a href="javascript:Recaptcha.showhelp()">
                                <span class="fa fa-question-sign" title="<pwm:display key="Display_CaptchaHelp"/>"></span>
                            </a>
                        </li>
                    </ul>
                </div>
            </div>
            <noscript>
                <iframe nonce="<pwm:value name="cspNonce"/>" src="<%=JspUtility.getAttribute(pageContext,PwmConstants.REQUEST_ATTR.CaptchaIframeUrl)%>"
                        height="300" width="500" frameborder="0"></iframe>
                <br>
                <textarea name="recaptcha_challenge_field" rows="3" cols="40">
                </textarea>
                <input type="hidden" name="recaptcha_response_field"
                       value="manual_challenge">
            </noscript>
            <div class="buttonbar">
                <input type="hidden" name="processAction" value="doVerify"/>
                <button type="submit" name="verify" class="btn" id="verify_button">
                    <pwm:if test="showIcons"><span class="btn-icon fa fa-check"></span></pwm:if>
                    <pwm:display key="Button_Verify"/>
                </button>
                <%@ include file="/WEB-INF/jsp/fragment/button-reset.jsp" %>
                <input type="hidden" name="pwmFormID" value="<pwm:FormID/>"/>
                <%@ include file="/WEB-INF/jsp/fragment/button-cancel.jsp" %>
            </div>
        </form>
    </div>
    <div class="push"></div>
</div>
<pwm:script>
    <script type="text/javascript">
        PWM_GLOBAL['startupFunctions'].push(function(){
            try {
                document.forms.verifyCaptcha.recaptcha_response_field.focus()
            } catch (e) {
                /* noop */
            }
        });
    </script>
</pwm:script>
<%@ include file="fragment/footer.jsp" %>
</body>
</html>
