using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Web;

namespace DiamondWebInventory.Models
{
    public static class CommonMethod
    {
        public static void MailSend(string strMailTo, string strMailSubject, string strMailBody, bool blnAllowMultipleBCC, bool blnSMTPGMAIL, bool blnUserMail = false)
        {

            string strEmailDisplayName = ConfigurationManager.AppSettings.Get("PrimaryDomain");
            MailMessage MyMailMessage = new MailMessage();
            MyMailMessage.From = new MailAddress(ConfigurationManager.AppSettings.Get("FromEmail"), ConfigurationManager.AppSettings.Get("CompanyName"));
            MyMailMessage.To.Add(strMailTo);

            if (blnUserMail == false)
            {
                string strBCCEmail = ConfigurationManager.AppSettings.Get("bccEmail");
                string strMultipleBCCEmail = ConfigurationManager.AppSettings.Get("MultipleBCCEmail");
                string[] strBCCEmails = strMultipleBCCEmail.Split(',');
                if (strBCCEmails != null && strBCCEmails.Length > 0)
                {
                    strBCCEmail = strBCCEmails[0].Trim();
                }
                if (blnAllowMultipleBCC == true)
                {
                    if (!string.IsNullOrEmpty(strMultipleBCCEmail))
                    {
                        strBCCEmails = strMultipleBCCEmail.Split(',');
                        if (strBCCEmails != null && strBCCEmails.Length > 0)
                        {
                            foreach (string strItem in strBCCEmails)
                            {
                                MyMailMessage.Bcc.Add(strItem.Trim());
                            }
                        }
                    }
                    else
                    {
                        if (!string.IsNullOrEmpty(strBCCEmail))
                        {
                            MyMailMessage.Bcc.Add(strBCCEmail);
                        }
                    }
                }
                else
                {
                    if (!string.IsNullOrEmpty(strBCCEmail))
                    {
                        MyMailMessage.Bcc.Add(strBCCEmail);
                    }
                }
            }
            MyMailMessage.Subject = strMailSubject;
            MyMailMessage.IsBodyHtml = true;
            MyMailMessage.Body = strMailBody;
            SmtpClient SMTPServer = new SmtpClient(ConfigurationManager.AppSettings.Get("smtpServer"));
            SMTPServer.UseDefaultCredentials = false;
            string smtpPort = ConfigurationManager.AppSettings.Get("smtpPort");
            SMTPServer.Port = Convert.ToInt32(smtpPort);
            SMTPServer.EnableSsl = true;
            SMTPServer.Credentials = new NetworkCredential(ConfigurationManager.AppSettings.Get("smtpAuthEmail"), ConfigurationManager.AppSettings.Get("smtpAuthPassword"));
            SMTPServer.Send(MyMailMessage);
        }

    }
}