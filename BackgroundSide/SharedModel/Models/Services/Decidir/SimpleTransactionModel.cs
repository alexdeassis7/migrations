using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using static SharedModel.Models.General.ErrorModel;

namespace SharedModel.Models.Services.Decidir
{
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class SimpleTransactionModel
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
        [Required(ErrorMessage = "Parameter :: identification :: is required.")]
        [RegularExpression("^(\\b(20|23|24|27|30|33|34)(\\D)?[0-9]{8}(\\D)?[0-9])$", ErrorMessage = "Parameter :: identification :: invalid value.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string Identification { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public PayToken.Request cardData { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public PayToken.RequestWithTokenizedCard tokenizedCardData { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente


#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public PayExecution.Request paymentData { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        private Error errorrow = new General.ErrorModel.Error();
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public Error ErrorRow { get { return errorrow; } set { errorrow = value; } }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente


    }



#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class Customer
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string name { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public Identification identification { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string customer_id { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [Required(ErrorMessage = "Final client id is required.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string finalclient_id { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [EmailAddress(ErrorMessage = "Parameter :: email :: is not a valid e-mail.")]
        [Required(ErrorMessage = "Email is required.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string email { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [RegularExpression("^[a-zA-ZáéíóúÁÉÍÓÚ0-9\\s]{1,150}$", ErrorMessage = "Parameter :: address :: invalid format, only allow: letters, numbers and spaces, and length has between 1 and 150 characters.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string address { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [StringLength(8, ErrorMessage = "Customer birth_day has 8 characters.", MinimumLength = 8)]
        [RegularExpression("^[0-9]{8}$", ErrorMessage = "Parameter :: birth_day :: invalid format, only allow: numbers and length has 8 characters Format: DDMMAAAA .")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string birth_day { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [RegularExpression("^[a-zA-ZáéíóúÁÉÍÓÚ\\s]{1,60}$", ErrorMessage = "Parameter :: city :: invalid format, only allow: letters and spaces, and length has between 1 and 60 characters.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string city { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [RegularExpression("^[a-zA-ZáéíóúÁÉÍÓÚ\\s]{1,60}$", ErrorMessage = "Parameter :: country :: invalid format, only allow: letters and spaces, and length has between 1 and 60 characters.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string country { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente


    }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class PayToken
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class Request
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string token { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

            [Required(ErrorMessage = "Card number is required.")]
            [StringLength(18, ErrorMessage = "Card number has minimun 16 characters and 18 characters maximum.", MinimumLength = 16)]
            [RegularExpression("^[0-9]{16,18}$", ErrorMessage = "Parameter :: card_number :: invalid format, only allow: numbers and length has 18 characters.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string card_number { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

            [Required(ErrorMessage = "Card expiration month is required.")]
            [StringLength(2, ErrorMessage = "Card expiration month has 2 characters.", MinimumLength = 2)]
            [RegularExpression("^[0-9]{2}$", ErrorMessage = "Parameter :: card_expiration_month :: invalid format, only allow: numbers and length has 2 characters.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string card_expiration_month { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

            [Required(ErrorMessage = "Card expiration year is required.")]
            [StringLength(2, ErrorMessage = "Card expiration year has 2 characters.", MinimumLength = 2)]
            [RegularExpression("^[0-9]{2}$", ErrorMessage = "Parameter :: card_expiration_year :: invalid format, only allow: numbers and length has 2 characters.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string card_expiration_year { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string security_code { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

            [RegularExpression("^[a-zA-ZáéíóúÁÉÍÓÚ\\s]{1,60}$", ErrorMessage = "Parameter :: card_holder_name :: invalid format, only allow: letters and spaces, and length has between 1 and 60 characters.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string card_holder_name { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

            [StringLength(8, ErrorMessage = "Card holder birthday has 8 characters.", MinimumLength = 8)]
            [RegularExpression("^[0-9]{8}$", ErrorMessage = "Parameter :: card_holder_birthday :: invalid format, only allow: numbers and length has 8 characters Format: DDMMAAAA .")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string card_holder_birthday { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public Int32 card_holder_door_number { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public PayTokenIdentification card_holder_identification { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string device_unique_identifier { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente


#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public Customer customer { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

            private Error errorrow = new General.ErrorModel.Error();

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public Error ErrorRow { get { return errorrow; } set { errorrow = value; } }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class RequestWithTokenizedCard
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            [Required(ErrorMessage = "Tokenized card number is required.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string token_card { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

            [Required(ErrorMessage = "Security code is required.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string security_code { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

            private Error errorrow = new General.ErrorModel.Error();
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public Error ErrorRow { get { return errorrow; } set { errorrow = value; } }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class PayTokenIdentification
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            [Required(ErrorMessage = "Identification type is required.")]
            [MinLength(3, ErrorMessage = "Identification type has minimum 3 characters required")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string type { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

            [Required(ErrorMessage = "Identification number is required.")]
            [MinLength(7, ErrorMessage = "Identification number has minimum 7 characters required")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string number { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class Response
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string id { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string status { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public int card_number_length { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string date_created { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public int bin { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public int last_four_digits { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public int security_code_length { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public int expiration_month { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public int expiration_year { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string date_due { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public CardHolder cardholder { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        }

    }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class CardHolder
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string name { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public Identification identification { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class Identification
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
        [Required(ErrorMessage = "Type is required.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string type { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        [StringLength(10, ErrorMessage = "Number has minimum 1 character and 10 characters maximum.", MinimumLength = 7)]
        [RegularExpression("^[0-9]{10}$", ErrorMessage = "Parameter :: number :: invalid format, only allow: numbers and length has 10 characters maximum.")]
        [Required(ErrorMessage = "Number is required.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public int number { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class PayExecution
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class Request
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string id { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

            [Required(ErrorMessage = "Site Transaction ID is required.")]
            [StringLength(40, ErrorMessage = "Site Transaction ID has minimun 1 characters and 40 characters maximum.", MinimumLength = 1)]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string site_transaction_id { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public Customer customer { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

            //public string site_id { get; set; }
            //[Required(ErrorMessage = "Token is required.")]
            //[StringLength(36, ErrorMessage = "Token has minimun 1 characters and 36 characters maximum.", MinimumLength = 1)]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string token { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

            [Required(ErrorMessage = "Payment Method ID is required.")]
            [RegularExpression("^[0-9]{1}$", ErrorMessage = "Parameter :: payment_method_id :: invalid format, only allow: one number maximum.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public int payment_method_id { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

            [Required(ErrorMessage = "Bin is required.")]
            [StringLength(6, ErrorMessage = "Bin has 6 characters.", MinimumLength = 6)]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string bin { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

            [Required(ErrorMessage = "Amount is required.")]
            [Range(0.1, 9223372036854775807.0, ErrorMessage = "Amount has minimun value $ 0.01 (value = 001) and maximum value $ 9223372036854775807.0 (value = 922337203685477580700).")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public Int32 amount { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

            [Required(ErrorMessage = "Currency is required.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string currency { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

            [Required(ErrorMessage = "Installments is required.")]
            [RegularExpression("^[1-99]$", ErrorMessage = "Installments has value between 1 and 99.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public int installments { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

            [Required(ErrorMessage = "Payment Type is required.")]
            [RegularExpression("^[a-zA-Z0-9\\s]{1,10}$", ErrorMessage = "Parameter :: payment_type :: invalid format, only allow: letters, numbers, and spaces, and length has between 1 and 10 characters.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string payment_type { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

            [StringLength(25, ErrorMessage = "Establishment Name has minimun 1 characters and 25 characters maximum.", MinimumLength = 1)]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string establishment_name { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

            [Required(ErrorMessage = "Description is required.")]
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string description { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public List<object> sub_payments { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public AggregateData aggregate_data { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

            private Error errorrow = new General.ErrorModel.Error();
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public Error ErrorRow { get { return errorrow; } set { errorrow = value; } }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        }

        //public class Payments {
        //    public string site_id { get; set; }
        //    [Required(ErrorMessage = "Amount is required.")]
        //    [Range(0.1, 9223372036854775807.0, ErrorMessage = "Amount has minimun value $ 0.01 and maximum value $ 9223372036854775807.0.")]
        //    public double amount { get; set; }
        //    [Required(ErrorMessage = "Installments is required.")]
        //    //[RegularExpression("^[1-99]{2}$", ErrorMessage = "Installments has value between 1 and 99.")]
        //    public int installments { get; set; }
        //}
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class Response
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string Campo { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string token_card { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string id { get; set; } //payment_id 
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string site_transaction_id { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string payment_method_id { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string payment_method { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string name { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string email { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string amount { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string currency { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string status { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string ticket { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string bin { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string installments { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string fraud_detection { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string aggregate_data { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string establishment_name { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string spv { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string confirmed { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string pan { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string customer_token { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public StatusDetails status_details { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            private Error errorrow = new Error();
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public Error ErrorRow { get { return errorrow; } set { errorrow = value; } }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        }
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class StatusDetails
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string ticket { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string card_authorization_code { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string address_validation_code { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public StatusDetailsErrors error { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class StatusDetailsErrors
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public string type { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            public StatusDetailsErrorsReason reason { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        }

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public class StatusDetailsErrorsReason
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string id { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
                public string description { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
            }

        }


#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class AggregateData
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string indicator { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string identification_number { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string bill_to_pay { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string bill_to_refund { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string merchant_name { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string street { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string number { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string postal_code { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string category { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string channel { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string geographic_code { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string city { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string merchant_id { get; set;}
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string province { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string country { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string merchant_email { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public string merchant_phone { get; set; }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

        private Error errorrow = new Error();
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public Error ErrorRow { get { return errorrow; } set { errorrow = value; } }
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente

    }

}