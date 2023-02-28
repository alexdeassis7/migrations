using SharedModel.Models.CrossCountry;
using SharedModel.Models.Services.Bolivia.Validation;

namespace LocalPayment_Tests
{
    public class BoliviaRequestValidators
    {
        [Fact]
        public void BoliviaIdentificationValidator_HasValidElements_ReturnsValidElements()
        {
            // Arrange & Act
            var sut = new BoliviaIdentificationValidator();

            // Assert 
            Assert.NotNull(sut);

            Assert.NotEmpty(sut.Definitions);

            Assert.True(sut.Definitions.Count() > 0);
        }

        #region VALIDACION CEDULA DE IDENTIDAD

        [Theory(DisplayName = "Validando Cedula de Identidad con valores potencialmente VALIDOS, no devuelve errores")]
        [InlineData("6327046 SC")] // With Spaces with valid real values
        [InlineData("6327046SC")] // Without Spaces with valid real values
        [InlineData("1234567 SC")] // With Spaces  with fake value
        [InlineData("1234567SC")] // Without Spaces with fake value
        [InlineData("SC 1234567")] // With Spaces  with fake value INVERTED
        [InlineData("SC1234567")] // Without Spaces with fake value INVERTED
        public void BoliviaIdentificationValidator_Validating_CedulaIdentidad_HasNoErrors(string identification_id)
        {
            // Arrange
            BoliviaIdentificationValidator validator = new BoliviaIdentificationValidator();

            // Act
            var result = validator.IsValidIdentification((int)IdentificationType.CI, identification_id);

            var isValid = result.Item1;
            var errors = result.Item2;

            Assert.True(isValid);
            Assert.True(errors.Count() == 0);
        }

        [Theory(DisplayName = "Validando Cedula de Identidad con valores INVALIDOS (MAS DE 7 DIGITOS DE LARGO) pero con terminacion correcta, DEVUELVE errores")]
        [InlineData("0000000000 SC")] // With Space but with exceeeded range of number
        [InlineData("0000000000SC")] // Without Space but with exceeeded range of number without spaces
        [InlineData("SC 0000000000")] // With Space but with exceeeded range of number INVERTED
        [InlineData("SC0000000000")] // Without Space but with exceeeded range of number INVERTED
        [InlineData("SC")] // just two characters
        public void BoliviaIdentificationValidator_Validating_CedulaIdentidad_WithInvalidValues_HasErrors(string identification_id)
        {
            // Arrange
            BoliviaIdentificationValidator validator = new BoliviaIdentificationValidator();

            // Act
            var result = validator.IsValidIdentification((int)IdentificationType.CI, identification_id);

            var isValid = result.Item1;
            var errors = result.Item2;

            Assert.False(isValid);

            Assert.True(errors.Count() > 0);

        }

        [Theory()]
        [InlineData("")] // Empty
        [InlineData(null)] // null
        public void BoliviaIdentificationValidator_Validating_CedulaIdentidad_WithInvalidValues_Throws_ArgumentNullException(string identification_id)
        {
            // Arrange
            BoliviaIdentificationValidator validator = new BoliviaIdentificationValidator();

            // Act
            var exception = Assert.Throws<ArgumentException>(() => validator.IsValidIdentification((int)IdentificationType.CI, identification_id));

            Assert.IsType<ArgumentException>(exception);

        }

        [Theory(DisplayName = "Validando Ciudades que no son esperadas")]
        [InlineData("1234567 AA")] // With Valid Lenght of Numbers but with Invalid City Acronim
        [InlineData("1234567AA")] // With Valid Lenght of Numbers but with Invalid City Acronim (Without Space)
        [InlineData("AA 1234567")] // With Valid Lenght of Numbers but with Invalid City Acronim (With Space) INVERTED
        [InlineData("AA1234567")] // With Valid Lenght of Numbers but with Invalid City Acronim (Without Space) INVERTED
        public void BoliviaIdentificationValidator_Validating_CedulaIdentidad_WithInvalidCitiesTermination_HasError(string identification_id)
        {
            BoliviaIdentificationValidator sut = new BoliviaIdentificationValidator();

            // Act
            var result = sut.IsValidIdentification((int)IdentificationType.CI, identification_id);
            var isValid = result.Item1;
            var errors = result.Item2;

            // Assert
            Assert.False(isValid);
            Assert.True(errors.Count() > 0);
        }

        #endregion

        #region VALIDACION CEDULA DE EXTRANJEROS

        [Theory(DisplayName = "Validando Cedula de Identidad EXTRANJEROS con valores potencialmente VALIDOS, no devuelve errores")]
        [InlineData("E12345678")] // 1  Character, 7 digits
        public void BoliviaIdentificationValidator_Validating_CedulaExtranjeros_HasNoErrors(string identification_id)
        {
            // Arrange
            BoliviaIdentificationValidator validator = new BoliviaIdentificationValidator();

            // Act
            var result = validator.IsValidIdentification((int)IdentificationType.CE, identification_id);

            var isValid = result.Item1;
            var errors = result.Item2;

            Assert.True(isValid);
            Assert.True(errors.Count() == 0);
        }

        [Theory(DisplayName = "Validando Cedula de Identidad EXTRANJEROS con valores Invalidos, devuelve errores")]
        [InlineData("12345678")] // With Spaces
        public void BoliviaIdentificationValidator_Validating_CedulaExtranjeros_WithInvalidData_HasErrors(string identification_id)
        {
            // Arrange
            BoliviaIdentificationValidator validator = new BoliviaIdentificationValidator();

            // Act
            var result = validator.IsValidIdentification((int)IdentificationType.CE, identification_id);

            var isValid = result.Item1;
            var errors = result.Item2;

            Assert.False(isValid);
            Assert.True(errors.Count() > 0);
        }


        [Theory()]
        [InlineData("")] // Empty0
        [InlineData(null)] // null
        public void BoliviaIdentificationValidator_Validating_CedulaExtranjeros_WithInvalidValues_Throws_ArgumentNullException(string identification_id)
        {
            // Arrange
            BoliviaIdentificationValidator validator = new BoliviaIdentificationValidator();

            // Act
            var exception = Assert.Throws<ArgumentException>(() => validator.IsValidIdentification((int)IdentificationType.CE, identification_id));
            Assert.IsType<ArgumentException>(exception);
        }


        #endregion

        #region VALIDACION CEDULA DE PASAPORTE

        [Theory(DisplayName = "Validando PASAPORTE con valores potencialmente VALIDOS, no devuelve errores")]
        [InlineData("1234567")] // 7 digits
        [InlineData("AAG3456")] // 7 digits
        public void BoliviaIdentificationValidator_Validating_PASSPORT_HasNoErrors(string identification_id)
        {
            // Arrange
            BoliviaIdentificationValidator validator = new BoliviaIdentificationValidator();

            // Act
            var result = validator.IsValidIdentification((int)IdentificationType.PASS, identification_id);

            var isValid = result.Item1;
            var errors = result.Item2;

            Assert.True(isValid);
            Assert.True(errors.Count() == 0);
        }

        [Theory(DisplayName = "Validando Cedula de Identidad EXTRANJEROS con valores Invalidos, devuelve errores")]
        [InlineData("12345678")] // With Spaces
        public void BoliviaIdentificationValidator_Validating_PASSPORT_WithInvalidData_HasErrors(string identification_id)
        {
            // Arrange
            BoliviaIdentificationValidator validator = new BoliviaIdentificationValidator();

            // Act
            var result = validator.IsValidIdentification((int)IdentificationType.CE, identification_id);

            var isValid = result.Item1;
            var errors = result.Item2;

            Assert.False(isValid);
            Assert.True(errors.Count() > 0);
        }


        [Theory()]
        [InlineData("")] // Empty
        [InlineData(null)] // null
        public void BoliviaIdentificationValidator_Validating_PASSPORT_WithInvalidValues_Throws_ArgumentNullException(string identification_id)
        {
            // Arrange
            BoliviaIdentificationValidator validator = new BoliviaIdentificationValidator();

            // Act
            var exception = Assert.Throws<ArgumentException>(() => validator.IsValidIdentification((int)IdentificationType.CE, identification_id));
            Assert.IsType<ArgumentException>(exception);
        }


        #endregion

        #region VALIDACION NIT

        [Theory(DisplayName = "Validando NIT con valores potencialmente VALIDOS (9 MIN a 12 MAX), no devuelve errores")]
        [InlineData("123456789")] // 9  (Min digits)
        [InlineData("123456789112")] // 12  (Max)
        public void BoliviaIdentificationValidator_Validating_NIT_HasNoErrors(string identification_id)
        {
            // Arrange
            BoliviaIdentificationValidator validator = new BoliviaIdentificationValidator();

            // Act
            var result = validator.IsValidIdentification((int)IdentificationType.NIT, identification_id);

            var isValid = result.Item1;
            var errors = result.Item2;

            Assert.True(isValid);
            Assert.True(errors.Count() == 0);
        }

        [Theory(DisplayName = "Validando NIT con valores Invalidos (Valores Menores al Minimo Permitido, Valores Maximos al Permitido), devuelve errores")]
        [InlineData("12345")] // Less than 9 (Min Value)
        [InlineData("9999999999999999999999999999")]
        public void BoliviaIdentificationValidator_Validating_NIT_WithInvalidData_HasErrors(string identification_id)
        {
            //Arrange
            BoliviaIdentificationValidator validator = new BoliviaIdentificationValidator();

            //Act
            var result = validator.IsValidIdentification((int)IdentificationType.NIT, identification_id);

            var isValid = result.Item1;
            var errors = result.Item2;

            Assert.False(isValid);
            Assert.True(errors.Count() > 0);
        }

        #endregion
    }
}