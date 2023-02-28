using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SharedBusiness.Exceptions
{
    public class ExceptionLimitPayout:Exception
    {
        public ExceptionLimitPayout (string message):base (message)
        {

        }
    }
}
