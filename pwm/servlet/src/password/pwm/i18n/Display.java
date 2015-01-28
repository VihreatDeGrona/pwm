/*
 * Password Management Servlets (PWM)
 * http://code.google.com/p/pwm/
 *
 * Copyright (c) 2006-2009 Novell, Inc.
 * Copyright (c) 2009-2015 The PWM Project
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

package password.pwm.i18n;

import password.pwm.config.Configuration;

import java.util.Locale;

/**
 * Empty class to facilitate easy resource bundle loading of "Display" resource bundle.
 */
public enum Display implements PwmDisplayBundle {

    Button_Activate,
    Button_Agree,
    Button_Cancel,
    Button_ChangePassword,
    Button_ChangeResponses,
    Button_CheckCode,
    Button_ClearOtpReEnroll,
    Button_HelpdeskClearOtpSecret,
    Button_ClearResponses,
    Button_CloseWindow,
    Button_Confirm,
    Button_ConfirmResponses,
    Button_Continue,
    Button_Create,
    Button_Email,
    Button_GoBack,
    Button_Hide,
    Button_Hide_Responses,
    Button_Home,
    Button_Login,
    Button_Logout,
    Button_More,
    Button_RecoverPassword,
    Button_Reset,
    Button_Search,
    Button_SetResponses,
    Button_Show,
    Button_Show_Responses,
    Button_Skip,
    Button_SMS,
    Button_Unlock,
    Button_UnlockPassword,
    Button_Update,
    Button_Verify,
    Button_OK,
    Display_ActivateUser,
    Display_AutoGeneratedPassword,
    Display_CapsLockIsOn,
    Display_Captcha,
    Display_CaptchaInputWords,
    Display_CaptchaInputNumbers,
    Display_CaptchaGetAudio,
    Display_CaptchaGetImage,
    Display_CaptchaHelp,
    Display_CaptchaRefresh,
    Display_ChangePassword,
    Display_ChangePasswordForm,
    Display_CheckingData,
    Display_CheckingPassword,
    Display_CheckingResponses,
    Display_CommunicationError,
    Display_ConfirmResponses,
    Display_Day,
    Display_Days,
    Display_ErrorBody,
    Display_ExpirationDate,
    Display_FooterInfoText,
    Display_ForgottenPassword,
    Display_ForgottenUsername,
    Display_GuestRegistration,
    Display_GuestUpdate,
    Display_Helpdesk,
    Display_Hour,
    Display_Hours,
    Display_IdleTimeout,
    Display_IdleWarningMessage,
    Display_IdleWarningTitle,
    Display_JavascriptRequired,
    Display_LeaveDirtyPasswordPage,
    Display_Login,
    Display_LoginPasswordOnly,
    Display_Logout,
    Display_Minute,
    Display_Minutes,
    Display_NewUser,
    Display_PasswordExpired,
    Display_PasswordGeneration,
    Display_PasswordNoExpire,
    Display_PasswordPrompt,
    Display_PasswordStrengthHigh,
    Display_PasswordStrengthLow,
    Display_PasswordStrengthMedium,
    Display_PasswordReplicationStatus,
    Display_PasswordWarn,
    Display_PeopleSearch,
    Display_PleaseWait,
    Display_PleaseWaitNewUser,
    Display_PleaseWaitPassword,
    Display_Random,
    Display_RecoverVerificationChoice,
    Display_RecoverTokenSendChoices,
    Display_RecoverTokenSendChoiceEmail,
    Display_RecoverTokenSendChoiceSMS,
    Display_RecoverChoiceReset,
    Display_RecoverChoiceUnlock,
    Display_RecoverEnterCode,
    Display_RecoverEnterCodeSMS,
    Display_RecoverPassword,
    Display_RecoverPasswordChoices,
    Display_RecoverRandomResponses,
    Display_RecoverRequiredResponses,
    Display_RecoverOTP,
    Display_RecoverOTPIdentified,
    Display_ResponsesPrompt,
    Display_SelectionIndicator,
    Display_SearchCompleted,
    Display_SearchResultsExceeded,
    Display_SetRandomPasswordPrompt,
    Display_SearchResultsNone,
    Display_Second,
    Display_Seconds,
    Display_SetupHelpdeskResponses,
    Display_SetupRandomResponses,
    Display_SetupRequiredResponses,
    Display_SetupResponses,
    Display_SetupOtpSecret,
    Display_SetupOtp_Android_Title,
    Display_SetupOtp_Android_Steps,
    Display_SetupOtp_iPhone_Title,
    Display_SetupOtp_iPhone_Steps,
    Display_SetupOtp_Other_Title,
    Display_SetupOtp_Other_Steps,
    Display_WarnExistingOtpSecretTime,
    Display_WarnExistingOtpSecret,
    Display_WarnExistingResponseTime,
    Display_WarnExistingResponse,
    Display_PleaseVerifyOtp,
    Display_OtpRecoveryInfo,
    Display_OtpClearWarning,
    Display_ResponsesClearWarning,
    Display_Shortcuts,
    Display_ShowPasswordGuide,
    Display_StrengthMeter,
    Display_UpdateProfile,
    Display_UpdateProfileConfirm,
    Display_UserEventHistory,
    Display_TypingWait,
    Field_AccountEnabled,
    Field_AccountExpired,
    Field_AccountExpirationTime,
    Field_Code,
    Field_OneTimePassword,
    Field_Confirm_Prefix,
    Field_ConfirmPassword,
    Field_CurrentPassword,
    Field_Display,
    Field_ForwardURL,
    Field_LastLoginTime,
    Field_LastLoginTimeDelta,
    Field_LdapProfile,
    Field_Location,
    Field_LogoutURL,
    Field_NetworkAddress,
    Field_NetworkHost,
    Field_NewPassword,
    Field_Option_Select,
    Field_Password,
    Field_PasswordExpirationTime,
    Field_PasswordExpired,
    Field_PasswordLocked,
    Field_PasswordPreExpired,
    Field_PasswordSetTime,
    Field_PasswordSetTimeDelta,
    Field_PasswordViolatesPolicy,
    Field_PasswordWithinWarningPeriod,
    Field_Policy,
    Field_Profile,
    Field_ResponsesNeeded,
    Field_ResponsesStored,
    Field_ResponsesTimestamp,
    Field_User_Supplied_Question,
    Field_UserDN,
    Field_UserGUID,
    Field_Username,
    Field_UserEmail,
    Field_UserSMS,
    Field_OTP_Identifier,
    Field_OTP_Secret,
    Field_OTP_Type,
    Field_OTP_RecoveryCodes,
    Field_OTP_Stored,
    Field_OTP_Timestamp,
    Field_VerificationMethodPreviousAuth,
    Field_VerificationMethodToken,
    Field_VerificationMethodOTP,
    Field_VerificationMethodChallengeResponses,
    Field_VerificationMethodAttributes,
    Field_VerificationMethodRemoteResponses,
    Field_VerificationMethod,
    Long_Title_ActivateUser,
    Long_Title_Admin,
    Long_Title_ChangePassword,
    Long_Title_ForgottenPassword,
    Long_Title_ForgottenUsername,
    Long_Title_GuestRegistration,
    Long_Title_GuestUpdate,
    Long_Title_Helpdesk,
    Long_Title_Logout,
    Long_Title_Main_Menu,
    Long_Title_NewUser,
    Long_Title_PeopleSearch,
    Long_Title_SetupResponses,
    Long_Title_SetupOtpSecret,
    Long_Title_Shortcuts,
    Long_Title_UpdateProfile,
    Long_Title_UserEventHistory,
    Long_Title_UserInformation,
    Title_AnsweredQuestions,
    Title_ActivateUser,
    Title_Admin,
    Title_Application,
    Title_Captcha,
    Title_ChangePassword,
    Title_ConfirmResponses,
    Title_Error,
    Title_ForgottenPassword,
    Title_ForgottenUsername,
    Title_GuestRegistration,
    Title_GuestUpdate,
    Title_Helpdesk,
    Title_LocaleSelect,
    Title_Login,
    Title_Logout,
    Title_MainPage,
    Title_NewUser,
    Title_PasswordGuide,
    Title_PasswordPolicy,
    Title_PasswordStrength,
    Title_PasswordWarning,
    Title_PeopleSearch,
    Title_PleaseWait,
    Title_RandomPasswords,
    Title_RecoverPassword,
    Title_RecoverRandomResponses,
    Title_RecoverRequiredResponses,
    Title_SecurityResponses,
    Title_SetupRandomResponses,
    Title_SetupRequiredResponses,
    Title_SetupResponses,
    Title_SetupOtpSecret,
    Title_Shortcuts,
    Title_Status,
    Title_Success,
    Title_TitleBar,
    Title_UpdateProfile,
    Title_UpdateProfileConfirm,
    Title_UserEventHistory,
    Title_UserInformation,
    Tooltip_PasswordStrength,
    Confirm_DeleteUser,
    Value_False,
    Value_True,
    Value_NotApplicable,
    Value_Default,
    
    ;

    public static String getLocalizedMessage(final Locale locale, final Display key, final Configuration config) {
        return LocaleHelper.getLocalizedMessage(locale, key.toString(), config, Display.class);
    }

    @Override
    public String getKey() {
        return this.toString();

    }


}

