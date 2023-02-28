using System.Collections.Generic;

namespace SharedModel.Models.View
{
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class CustomerAccountBalanceResponse
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public List<CustomerAccountBalanceItem> Items { get; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public CustomerAccountBalanceResponse()
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            Items = new List<CustomerAccountBalanceItem>();
        }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public void Add(CustomerAccountBalanceItem item) => Items.Add(item);
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    }
}