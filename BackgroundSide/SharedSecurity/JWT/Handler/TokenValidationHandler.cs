using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
using System.Web;
using Microsoft.IdentityModel.Tokens;
using SharedBusiness.Log;

namespace SharedSecurity.JWT.Handler
{
    /// <summary>
    /// Token validator for Authorization Request using a DelegatingHandler
    /// </summary>
    public class TokenValidationHandler : DelegatingHandler
    {
        private static bool TryRetrieveToken(HttpRequestMessage request, out string token)
        {
            token = null;
            IEnumerable<string> authzHeaders;
            if (!request.Headers.TryGetValues("Authorization", out authzHeaders) || authzHeaders.Count() > 1)
            {
                return false;
            }
            var bearerToken = authzHeaders.ElementAt(0);
            token = bearerToken.StartsWith("Bearer ") ? bearerToken.Substring(7) : bearerToken;
            return true;
        }

        protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
        {
            HttpStatusCode statusCode;
            string token;
            string transactionIdLog = Guid.NewGuid().ToString();

            LogService.LogInfo("TokenValidationHandler - TransactionIdLog: " + transactionIdLog + " URL: "+request.RequestUri+" HEADER:" + request.Headers + " CONTENT: " + request.Content.ReadAsStringAsync().Result);

            // determine whether a jwt exists or not
            if (!TryRetrieveToken(request, out token))
            {
                statusCode = HttpStatusCode.Unauthorized;
                LogService.LogInfo("TokenValidationHandler - TransactionIdLog: " + transactionIdLog + " JWT NotExist");

                return base.SendAsync(request, cancellationToken);
            }

            try
            {
                string CustomerID = string.Empty;
                if (request.Headers.Contains("customer_id"))
                     CustomerID = ((string[])request.Headers.FirstOrDefault(x => x.Key == "customer_id").Value)[0];
                

                if (!string.IsNullOrEmpty(CustomerID) && CustomerID.Length > 0)
                {
                    SharedBusiness.Security.BlSecurity BL = new SharedBusiness.Security.BlSecurity();
                    SharedModel.Models.Database.Security.Authentication.Account Account = BL.GetAuthentication(CustomerID);

                    if (Account.ValidationResult.ValidationStatus == true)
                    {
                        var secretKey = Account.SecretKey;
                        var audienceToken = ConfigurationManager.AppSettings["JWT_AUDIENCE_TOKEN"];
                        var issuerToken = ConfigurationManager.AppSettings["JWT_ISSUER_TOKEN"];
                        var securityKey = new SymmetricSecurityKey(System.Text.Encoding.Default.GetBytes(secretKey));

                        SecurityToken securityToken;
                        var tokenHandler = new System.IdentityModel.Tokens.Jwt.JwtSecurityTokenHandler();
                        TokenValidationParameters validationParameters = new TokenValidationParameters()
                        {
                            ValidAudience = audienceToken,
                            ValidIssuer = issuerToken,
                            ValidateLifetime = true,
                            ValidateIssuerSigningKey = true,
                            LifetimeValidator = LifetimeValidator,
                            IssuerSigningKey = securityKey
                        };

                        // Extract and assign Current Principal and user
                        Thread.CurrentPrincipal = tokenHandler.ValidateToken(token, validationParameters, out securityToken);
                        HttpContext.Current.User = tokenHandler.ValidateToken(token, validationParameters, out securityToken);
                        LogService.LogInfo("TokenValidationHandler - TransactionIdLog:" + transactionIdLog + " Authorized");
                    }
                    else
                    {
                        LogService.LogInfo("TokenValidationHandler - TransactionIdLog:" + transactionIdLog + " Unauthorized");
                        statusCode = HttpStatusCode.Unauthorized;
                        return Task<HttpResponseMessage>.Factory.StartNew(() => new HttpResponseMessage(statusCode) { });
                    }
                }
                else
                {
                    LogService.LogInfo("TokenValidationHandler - TransactionIdLog:" + transactionIdLog + " Unauthorized");
                    statusCode = HttpStatusCode.Unauthorized;
                }
                
                return base.SendAsync(request, cancellationToken);
            }
            catch (SecurityTokenInvalidSignatureException) 
            {
                LogService.LogInfo("TokenValidationHandler - TransactionIdLog:" + transactionIdLog + " Forbidden");
                statusCode = HttpStatusCode.Forbidden;
            }
            catch (SecurityTokenValidationException)
            {
                LogService.LogInfo("TokenValidationHandler - TransactionIdLog:" + transactionIdLog + " Unauthorized_Lifetime");
                statusCode = HttpStatusCode.Unauthorized; /* ==> LifetimeValidator: Cuando retorna true, el token expiró. Por lo tanto se cierra la sesión automáticamente. */
            }
            catch (Exception)
            {
                LogService.LogInfo("TokenValidationHandler - TransactionIdLog:" + transactionIdLog + " Forbidden");
                statusCode = HttpStatusCode.InternalServerError;
            }

            return Task<HttpResponseMessage>.Factory.StartNew(() => new HttpResponseMessage(statusCode) { });
        }

        public bool LifetimeValidator(DateTime? notBefore, DateTime? expires, SecurityToken securityToken, TokenValidationParameters validationParameters)
        {
            if (expires != null)
            {
                if (DateTime.UtcNow < expires) return true; /* El token expiró. Por lo tanto se cierra la sesión automáticamente. */
            }
            return false;
        }
    }
}
