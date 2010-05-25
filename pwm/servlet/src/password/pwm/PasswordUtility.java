/*
 * Password Management Servlets (PWM)
 * http://code.google.com/p/pwm/
 *
 * Copyright (c) 2006-2009 Novell, Inc.
 * Copyright (c) 2009-2010 The PWM Project
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

package password.pwm;

import com.novell.ldapchai.ChaiFactory;
import com.novell.ldapchai.ChaiUser;
import com.novell.ldapchai.cr.ChallengeSet;
import com.novell.ldapchai.cr.CrFactory;
import com.novell.ldapchai.cr.ResponseSet;
import com.novell.ldapchai.exception.ChaiException;
import com.novell.ldapchai.exception.ChaiOperationException;
import com.novell.ldapchai.exception.ChaiPasswordPolicyException;
import com.novell.ldapchai.exception.ChaiUnavailableException;
import com.novell.ldapchai.impl.edir.entry.EdirEntries;
import com.novell.ldapchai.provider.ChaiProvider;
import com.novell.ldapchai.util.ChaiUtility;
import password.pwm.bean.EmailItemBean;
import password.pwm.bean.SessionStateBean;
import password.pwm.bean.UserInfoBean;
import password.pwm.config.Configuration;
import password.pwm.error.PwmError;
import password.pwm.config.PwmSetting;
import password.pwm.error.ErrorInformation;
import password.pwm.error.PwmException;
import password.pwm.error.ValidationException;
import password.pwm.util.PwmLogger;
import password.pwm.util.TimeDuration;
import password.pwm.util.stats.Statistic;

import java.util.*;

/**
 * @author Jason D. Rivard
 */
public class PasswordUtility {

    private static final PwmLogger LOGGER = PwmLogger.getLogger(PasswordUtility.class);

    private PasswordUtility() {
    }

    public static ChallengeSet readUserChallengeSet(
            final PwmSession pwmSession,
            final ChaiUser theUser,
            final PwmPasswordPolicy policy,
            final Locale locale
    )
    {
        final long methodStartTime = System.currentTimeMillis();

        ChallengeSet returnSet = null;

        if (pwmSession.getConfig().readSettingAsBoolean(PwmSetting.EDIRECTORY_READ_CHALLENGE_SET)) {
            try {
                if (pwmSession.getContextManager().getProxyChaiProvider().getDirectoryVendor() == ChaiProvider.DIRECTORY_VENDOR.NOVELL_EDIRECTORY) {
                    if (policy != null && policy.getChaiPasswordPolicy() != null) {
                        returnSet = CrFactory.readAssignedChallengeSet(theUser.getChaiProvider(), policy.getChaiPasswordPolicy(), locale);
                    }

                    if (returnSet == null) {
                        returnSet = CrFactory.readAssignedChallengeSet(theUser, locale);
                    }

                    if (returnSet == null) {
                        LOGGER.debug(pwmSession, "no nmas c/r policy found for user " + theUser.getEntryDN());
                    } else {
                        LOGGER.debug(pwmSession, "using nmas c/r policy for user " + theUser.getEntryDN() + ": " + returnSet.toString());
                    }
                }
            } catch (ChaiException e) {
                LOGGER.error(pwmSession, "error reading nmas c/r policy for user " + theUser.getEntryDN() + ": " + e.getMessage());
            }
        }

        // use PWM policies if PWM is configured and either its all that is configured OR the NMAS policy read was not successfull
        if (returnSet == null) {
            returnSet = pwmSession.getContextManager().getConfig().getGlobalChallengeSet(pwmSession.getSessionStateBean().getLocale());
            if (returnSet != null) {
                LOGGER.debug(pwmSession, "using pwm c/r policy for user " + theUser.getEntryDN() + ": " + returnSet.toString());
            }
        }

        if (returnSet == null) {
            LOGGER.warn(pwmSession, "no available c/r policy for user" + theUser.getEntryDN() + ": ");
        }

        LOGGER.trace(pwmSession, "readUserChallengeSet completed in " + TimeDuration.fromCurrent(methodStartTime).asCompactString());

        return returnSet;
    }

    public static ResponseSet readUserResponseSet(final PwmSession pwmSession, final ChaiUser theUser)
            throws ChaiUnavailableException
    {
        ResponseSet userResponseSet = null;

        try {
            userResponseSet = theUser.readResponseSet();
        } catch (ChaiOperationException e) {
            LOGGER.debug(pwmSession, "ldap error reading response set: " + e.getMessage());
        }

        return userResponseSet;
    }

    /**
     * This is the entry point under which all password changes are managed.
     * The following is the general procedure when this method is invoked.
     * <ul>
     * <li> password is checked against PWM password requirement </li>
     * <li> ldap password set is attempted<br/>
     * <br/>if successful:
     * <ul>
     * <li> uiBean is updated with old and new passwords </li>
     * <li> uiBean's password expire flag is set to false </li>
     * <li> any configured external methods are invoked </li>
     * <li> user email notification is sent </li>
     * <li> return true </li>
     * </ul>
     * <br/>if unsuccessful
     * <ul>
     * <li> ssBean is updated with appropriate error </li>
     * <li> return false </li>
     * </ul>
     * </li>
     * </ul>
     *
     * @param newPassword the new password that is being set.
     * @param pwmSession  beanmanager for config and user info lookup
     * @return true if the set was successful
     * @throws com.novell.ldapchai.exception.ChaiUnavailableException if the ldap directory is not unavailable
     * @throws password.pwm.error.PwmException             if user is not authenticated
     */
    public static boolean setUserPassword(  //@todo this really needs to be chopped up into multiple methods
                                            final PwmSession pwmSession,
                                            final String newPassword
    )
            throws ChaiUnavailableException, PwmException
    {
        final UserInfoBean uiBean = pwmSession.getUserInfoBean();
        final SessionStateBean ssBean = pwmSession.getSessionStateBean();

        if (!Permission.checkPermission(Permission.CHANGE_PASSWORD, pwmSession)) {
            ssBean.setSessionError(PwmError.ERROR_UNAUTHORIZED.toInfo());
            LOGGER.debug(pwmSession, "attempt to setUserPassword, but user does not have password change permission");
            return false;
        }

        // double check to make sure password meets PWM rule requirements.  This should
        // have been done before setUserPassord() is invoked, so it should be redundent
        // but we do it just in case.
        try {
            Validator.testPasswordAgainstPolicy(newPassword, pwmSession, false);
        } catch (ValidationException e) {
            ssBean.setSessionError(new ErrorInformation(e.getError().getError()));
            LOGGER.debug(pwmSession, "attempt to setUserPassword, but password does not pass PWM validator");
            return false;
        }

        // retreive the user's old password from the userInfoBean in the session
        final String oldPassword = pwmSession.getUserInfoBean().getUserCurrentPassword();

        // Check to make sure we actually have an old password
        if (oldPassword == null || oldPassword.length() < 1) {
            ssBean.setSessionError(PwmError.ERROR_WRONGPASSWORD.toInfo());
            LOGGER.warn(pwmSession, pwmSession.getUserInfoBean().getUserDN() + "can't set password for user, old passwod is null");
            return false;
        }

        final ChaiProvider provider = pwmSession.getSessionManager().getChaiProvider();
        final ChaiUser theUser = ChaiFactory.createChaiUser(pwmSession.getUserInfoBean().getUserDN(), provider);

        try {
            theUser.changePassword(oldPassword,newPassword); // this method handles AD, edir or nmas password changes.
        } catch (ChaiOperationException e) {
            final PwmError returnMsg = PwmError.forChaiPasswordError(e.getErrorCode()) == null ? PwmError.ERROR_UNKNOWN : PwmError.forChaiPasswordError(e.getErrorCode());
            final ErrorInformation error = new ErrorInformation(returnMsg,e.getMessage());
            ssBean.setSessionError(error);
            LOGGER.warn(pwmSession, "error setting password for user '" + uiBean.getUserDN() + "'' " + error.toDebugStr() + ", " + e.getMessage());
            return false;
        } catch (ChaiPasswordPolicyException e) {
            final ErrorInformation error = new ErrorInformation(PwmError.forResourceKey(e.getPasswordError().getErrorKey()));
            ssBean.setSessionError(error);
            LOGGER.warn(pwmSession, "error setting password for user '" + uiBean.getUserDN() + "'' " + error.toDebugStr());
            return false;
        }

        // at this point the password has been changed, so log it.
        LOGGER.info(pwmSession, "user '" + uiBean.getUserDN() + "' successfully changed password");

        // clear out the password change bean
        pwmSession.clearChangePasswordBean();

        // update the uibean with the user's new password
        uiBean.setUserCurrentPassword(newPassword);

        //close any outstanding ldap connections (since they cache the old password)
        pwmSession.getSessionManager().closeConnections();

        // clear the "requires new password flag"
        uiBean.setRequiresNewPassword(false);

        // update the uibean's "password expired flag".
        uiBean.setPasswordState(UserStatusHelper.readPasswordStatus(pwmSession, pwmSession.getSessionManager().getActor(), uiBean.getPasswordPolicy()));

        //update the current last password update field in ldap
        final ChaiUser proxiedUser = ChaiFactory.createChaiUser(theUser.getEntryDN(), pwmSession.getContextManager().getProxyChaiProvider());

        final long delayStartTime = System.currentTimeMillis();
        final boolean successfullyWrotePwdUpdateAttr = Helper.updateLastUpdateAttribute(pwmSession, proxiedUser);

        if (pwmSession.getConfig().readStringArraySetting(PwmSetting.LDAP_SERVER_URLS).size() <= 1) {
            LOGGER.trace(pwmSession, "skipping replication checking, only one ldap server url is configured");
        } else {
            final long maxWaitTime = pwmSession.getConfig().readSettingAsInt(PwmSetting.PASSWORD_SYNC_MAX_WAIT_TIME) * 1000;

            if (successfullyWrotePwdUpdateAttr && maxWaitTime > 0) {
                LOGGER.trace(pwmSession, "beginning password replication checking");
                // if the last password update worked, test that it is replicated accross all ldap servers.
                boolean isReplicated = false;
                Helper.pause(PwmConstants.PASSWORD_UPDATE_INITIAL_DELAY);
                try {
                    long timeSpentTrying = 0;
                    while (!isReplicated && timeSpentTrying < (maxWaitTime)) {
                        timeSpentTrying = System.currentTimeMillis() - delayStartTime;
                        isReplicated = ChaiUtility.testAttributeReplication(proxiedUser, pwmSession.getConfig().readSettingAsString(PwmSetting.PASSWORD_LAST_UPDATE_ATTRIBUTE), null);
                        Helper.pause(PwmConstants.PASSWORD_UPDATE_CYCLE_DELAY);
                    }
                } catch (ChaiOperationException e) {
                    //oh well, give up.
                    LOGGER.trace(pwmSession, "error during password sync check: " + e.getMessage());
                }
                final long totalTime = System.currentTimeMillis() - delayStartTime;
                pwmSession.getContextManager().getStatisticsManager().updateAverageValue(Statistic.AVG_PASSWORD_SYNC_TIME,totalTime);
            }
        }

        // be sure minimum wait time has passed
        final long minWaitTime = pwmSession.getConfig().readSettingAsInt(PwmSetting.PASSWORD_SYNC_MIN_WAIT_TIME) * 1000L;
        if((System.currentTimeMillis() - delayStartTime) < minWaitTime)  {
            LOGGER.trace(pwmSession, "waiting for minimum replication time of " + minWaitTime + "ms....");
            while ((System.currentTimeMillis() - delayStartTime) < minWaitTime)  {
                Helper.pause(500);
            }
        }

        // send user an email confirmation
        sendChangePasswordEmailNotice(pwmSession);

        // update the status bean
        pwmSession.getContextManager().getStatisticsManager().incrementValue(Statistic.PASSWORD_CHANGES);

        // add the old password to the global history list (if the old password is known)
        if (!pwmSession.getUserInfoBean().isAuthFromUnknownPw()) {
            pwmSession.getContextManager().getSharedHistoryManager().addWord(pwmSession, oldPassword);
        }

        // call out to external methods.
        Helper.invokeExternalPasswordMethods(pwmSession, oldPassword, newPassword);

        return true;
    }

    static Map<String, ReplicationStatus> checkIfPasswordIsReplicated(final ChaiUser user, final PwmSession pwmSession)
            throws ChaiUnavailableException
    {
        final Map<String, ReplicationStatus> repStatusMap = new HashMap<String, ReplicationStatus>();

        {
            final ReplicationStatus repStatus = checkDirectoryReplicationStatus(user, pwmSession);
            repStatusMap.put("ReplicationSync", repStatus);
        }

        if (ChaiProvider.DIRECTORY_VENDOR.NOVELL_EDIRECTORY == user.getChaiProvider().getDirectoryVendor()) {

        }

        return repStatusMap;
    }

    public static Map<String, ReplicationStatus> checkNovellIDMReplicationStatus(final ChaiUser chaiUser)
            throws ChaiUnavailableException, ChaiOperationException
    {
        final Map<String,ReplicationStatus> repStatuses = new HashMap<String,ReplicationStatus>();

        final Set<String> values = chaiUser.readMultiStringAttribute("DirXML-PasswordSyncStatus");
        if (values != null) {
            for (final String value : values) {
                if (value != null && value.length() >= 62 ) {
                    final String guid = value.substring(0,32);
                    final String timestamp = value.substring(32,46);
                    final String status = value.substring(46,62);
                    final String descr = value.substring(61, value.length());

                    final Date dateValue = EdirEntries.convertZuluToDate(timestamp + "Z");

                    System.out.println("guid=" + guid + ", timestamp=" + dateValue.toString() + ", status=" + status + ", descr=" + descr);
                }
            }
        }

        return repStatuses;
    }

    private static ReplicationStatus checkDirectoryReplicationStatus(final ChaiUser user, final PwmSession pwmSession)
            throws ChaiUnavailableException
    {
        boolean isReplicated = false;
        try {
            isReplicated = ChaiUtility.testAttributeReplication(user, pwmSession.getConfig().readSettingAsString(PwmSetting.PASSWORD_LAST_UPDATE_ATTRIBUTE), null);
            Helper.pause(PwmConstants.PASSWORD_UPDATE_CYCLE_DELAY);
        } catch (ChaiOperationException e) {
            //oh well, give up.
            LOGGER.trace(pwmSession, "error during password sync check: " + e.getMessage());
        }
        return isReplicated ? ReplicationStatus.COMPLETE : ReplicationStatus.IN_PROGRESS;
    }

    /**
     * Judge a password's strength
     *
     * @param password password to check
     * @return 0-100, 0 being a very week password, 100 being a strong password.
     */
    public static int judgePassword(final String password)
    {
        if (password == null || password.length() < 1) {
            return 0;
        }

        int score = 0;
        final Validator.PasswordCharCounter charCounter = new Validator.PasswordCharCounter(password);

        // -- Additions --
        // amount of unique chars
        if (charCounter.getUniqueChars() > 7) {
            score = score + 10;
        }
        score = score + ((charCounter.getUniqueChars()) * 3);

        // Numbers
        if (charCounter.getNumericChars() > 0) {
            score = score + 8;
            score = score + (charCounter.getNumericChars()) * 4;
        }

        // specials
        if (charCounter.getSpecialChars() > 0) {
            score = score + 14;
            score = score + (charCounter.getSpecialChars()) * 5;
        }

        // mixed case
        if ((charCounter.getAlphaChars() != charCounter.getUpperChars()) && (charCounter.getAlphaChars() != charCounter.getLowerChars())) {
            score = score + 10;
        }

        // -- Deductions --

        // sequential numbers
        if (charCounter.getSequentialNumericChars() > 2) {
            score = score - (charCounter.getSequentialNumericChars() - 1) * 4;
        }

        // sequential chars
        if (charCounter.getSequentialRepeatedChars() > 1) {
            score = score - (charCounter.getSequentialRepeatedChars()) * 5;
        }

        return score > 100 ? 100 : score < 0 ? 0 : score;
    }

    enum ReplicationStatus {
        IN_PROGRESS,
        COMPLETE
    }


    public static void sendChangePasswordEmailNotice(final PwmSession pwmSession)
    {
        final Configuration config = pwmSession.getConfig();
        final Locale locale = pwmSession.getSessionStateBean().getLocale();

        final String fromAddress = config.readLocalizedStringSetting(PwmSetting.EMAIL_CHANGEPASSWORD_FROM,locale);
        final String subject = config.readLocalizedStringSetting(PwmSetting.EMAIL_CHANGEPASSWORD_SUBJECT,locale);
        final String plainBody = config.readLocalizedStringSetting(PwmSetting.EMAIL_CHANGEPASSWORD_BODY,locale);
        final String htmlBody = config.readLocalizedStringSetting(PwmSetting.EMAIL_CHANGEPASSWORD_BODY_HMTL,locale);

        final String toAddress = pwmSession.getUserInfoBean().getUserEmailAddress();
        if (toAddress == null || toAddress.length() < 1) {
            LOGGER.debug(pwmSession, "unable to send change password email for '" + pwmSession.getUserInfoBean().getUserDN() + "' no ' user email address available");
            return;
        }

        pwmSession.getContextManager().sendEmailUsingQueue(new EmailItemBean(toAddress, fromAddress, subject, plainBody, htmlBody));
    }


}
