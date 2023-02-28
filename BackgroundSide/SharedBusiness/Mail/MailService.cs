using System;
using System.Collections.Generic;
using System.Configuration;
using System.Globalization;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace SharedBusiness.Mail
{
    /// <summary>
    /// Email Service
    /// </summary>
    public static class MailService
    {
        /// <summary>
        /// Send an email to one or more recipients with attachments (if given -optional-) with a body and a subject.
        /// </summary>
        /// <param name="subject">Email subject text</param>
        /// <param name="mailBody">Body of the Email to be sent</param>
        /// <param name="emailRecipients">Collection of email address of the users to whom it will be sent</param>
        /// <param name="attachmentsFiles">Collection of one or more file names to be attached to the email (if null, it will not be attached -this parameter is optional-)</param>
        public static void SendMail(string subject,
            string mailBody,
            IEnumerable<string> emailRecipients,
            IEnumerable<string> attachmentsFiles = null)
        {
            var connectionString = ConfigurationManager.ConnectionStrings["connDbLocalPayment"].ConnectionString;

           // var isQaEnvironment = connectionString.IndexOf("LocalPaymentPROD", StringComparison.Ordinal) == -1;
            var enviroment= ConfigurationManager.AppSettings["Enviroment"].ToString();

            subject = enviroment + " - " + subject;

            //#if DEBUG
            // return;
            //#endif
            bool.TryParse(ConfigurationManager.AppSettings["EnvioEmails"], out bool emailSendingIsEnabled);

            if (!emailSendingIsEnabled)
                return;

            using (var mail = new MailMessage())
            {
                var userNameEmail = ConfigurationManager.AppSettings["UserNameEmail"];

                var credentialApiUserApiKey = ConfigurationManager.AppSettings["EmailCredentialUserApiKey"];
                var credentialApiPassApiKey = ConfigurationManager.AppSettings["EmailCredentialPassApiKey"];

                var emailPort = Convert.ToInt32(ConfigurationManager.AppSettings["EmailPort"]);
                var paginationQuantity = Convert.ToInt32(ConfigurationManager.AppSettings["CantPaginacionEmail"]);

                if (paginationQuantity == 0)
                {
                    paginationQuantity = 1;
                }

                var smtpServer = new SmtpClient(ConfigurationManager.AppSettings["SMTPServer"], emailPort);

                attachmentsFiles?.ToList().ForEach(x => mail.Attachments.Add(new Attachment(x)));

                var emailsToSend = emailRecipients.Distinct().Where(IsValidEmail).ToList();

                if (emailsToSend.Count <= 0) return;

                while (emailsToSend.Count > 0)
                {
                    var emailsTake = emailsToSend.Take(paginationQuantity).ToList();
                    smtpServer.UseDefaultCredentials = true;
                    smtpServer.Credentials = new NetworkCredential(credentialApiUserApiKey, credentialApiPassApiKey);
                    smtpServer.EnableSsl = true;
                    smtpServer.DeliveryMethod = SmtpDeliveryMethod.Network;

                    mail.From = new MailAddress(userNameEmail);

                    if (emailsTake.Count > 1)
                    {
                        mail.Bcc.Add(string.Join(",", emailsTake));
                    }
                    else
                    {
                        mail.To.Add(emailsTake.First());
                    }

                    mail.Subject = subject;
                    mail.IsBodyHtml = true;
                    mail.Body = mailBody;
                    smtpServer.Send(mail);

                    mail.Bcc.Clear();
                    mail.To.Clear();

                    emailsToSend.RemoveRange(0, paginationQuantity < emailsToSend.Count ? paginationQuantity : emailsToSend.Count);
                }
            }
        }

        /// <summary>
        /// Send an email to one or more recipients with attachments (if given -optional-) with a body and a subject.
        /// </summary>
        /// <param name="subject">Email subject text</param>
        /// <param name="emailBody">Body of the Email to be sent</param>
        /// <param name="emailRecipients">Collection of email address of the users to whom it will be sent</param>
        /// <param name="attachmentsFiles">Collection of one or more file names to be attached to the email (if null, it will not be attached -this parameter is optional-)</param>
        public static async Task SendMailAsync(
            string subject,
            string emailBody,
            IEnumerable<string> emailRecipients,
            IEnumerable<string> attachmentsFiles = null)
        {
            using (var mail = new MailMessage())
            {
                var userNameEmail = ConfigurationManager.AppSettings["UserNameEmail"];
                var credentialUser = ConfigurationManager.AppSettings["EmailCredentialUserApiKey"];
                var credentialPass = ConfigurationManager.AppSettings["EmailCredentialPassApiKey"];
                var emailPort = Convert.ToInt32(ConfigurationManager.AppSettings["EmailPort"]);
                var paginationQuantity = Convert.ToInt32(ConfigurationManager.AppSettings["CantPaginacionEmail"]);
                var smtpServer = new SmtpClient(ConfigurationManager.AppSettings["SMTPServer"], emailPort);

                var emailsToSend = emailRecipients.Distinct().Where(IsValidEmail).ToList();

                attachmentsFiles?.ToList().ForEach(x => mail.Attachments.Add(new Attachment(x)));

                if (emailsToSend.Any())
                {
                    while (emailsToSend.Any())
                    {
                        var emailsTake = emailsToSend.Take(paginationQuantity).ToList();
                        smtpServer.Credentials = new NetworkCredential(credentialUser, credentialPass);
                        smtpServer.EnableSsl = true;
                        mail.From = new MailAddress(userNameEmail);

                        if (emailsTake.Count > 1)
                        {
                            mail.Bcc.Add(string.Join(",", emailsTake));
                        }
                        else
                        {
                            mail.To.Add(emailsTake.First());
                        }

                        mail.Subject = subject;
                        mail.IsBodyHtml = true;
                        mail.Body = emailBody;

                        await smtpServer.SendMailAsync(mail);

                        mail.Bcc.Clear();
                        mail.To.Clear();

                        emailsToSend.RemoveRange(0, paginationQuantity < emailsToSend.Count ? paginationQuantity : emailsToSend.Count);
                    }
                }
            }
        }

        private static bool IsValidEmail(string emailAddress)
        {
            if (string.IsNullOrEmpty(emailAddress))
                return false;

            // Use IdnMapping class to convert Unicode domain names. 
            try
            {
                emailAddress = Regex.Replace(emailAddress, @"(@)(.+)$", DomainMapper,
                                      RegexOptions.None, TimeSpan.FromMilliseconds(200));

                return Regex.IsMatch(emailAddress,
                      @"^(?("")("".+?(?<!\\)""@)|(([0-9a-z]((\.(?!\.))|[-!#\$%&'\*\+/=\?\^`\{\}\|~\w])*)(?<=[0-9a-z])@))" +
                      @"(?(\[)(\[(\d{1,3}\.){3}\d{1,3}\])|(([0-9a-z][-\w]*[0-9a-z]*\.)+[a-z0-9][\-a-z0-9]{0,22}[a-z0-9]))$",
                      RegexOptions.IgnoreCase, TimeSpan.FromMilliseconds(250));
            }
            catch (RegexMatchTimeoutException)
            {
                return false;
            }
        }
        private static string DomainMapper(Match match)
        {
            // IdnMapping class with default property values.
            var idn = new IdnMapping();
            var domainName = match.Groups[2].Value;
            domainName = idn.GetAscii(domainName);

            return match.Groups[1].Value + domainName;
        }
    }
}
