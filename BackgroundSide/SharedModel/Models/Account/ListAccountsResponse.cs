using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using SharedModel.Models.Shared;
using SharedModel.Models.User;


namespace SharedModel.Models.Account
{
    public class ListAccountsResponse
    {
        public int idEntityAccount { get; set; }
        public int idEntityUser { get; set; }
        public string Identification { get; set; }
        public Boolean IsAdmin { get; set; }
        public string FirstName { get; set; }
        public string MailAccount { get; set; }
        public string ApiKey { get; set; }
        public List<CountryModelResponse> Paises { get; set; }
        public List<SharedModel.Models.User.User> ApiUsers { get; set; }
        public List<SharedModel.Models.User.User> ExternalUsers { get; set; }
    }
}
