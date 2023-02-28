using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SharedModelDTO.User
{
    public class UserIntoAccountRequest
    {
        public int idEntityAccount { get; set; }
        public int IdEntityUser { get; set; }
        public string Mail { get; set; }
        public string WebPassword { get; set; }
    }
}
