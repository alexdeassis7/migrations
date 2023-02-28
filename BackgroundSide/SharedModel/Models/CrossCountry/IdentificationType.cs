namespace SharedModel.Models.CrossCountry
{
    /// <summary>
    /// Enumeracion para Los Tipos de Identificacion
    /// </summary>
    public enum IdentificationType
    {
        /// <summary>
        /// No Definido (No deberia ocurrir, es solo un guard clause)
        /// </summary>
        NotDefined = 0,
        /// <summary>
        /// Cedula Identidad
        /// </summary>
        CI,
        /// <summary>
        /// Cedula Identidad Extranjeros
        /// </summary>
        CE,
        /// <summary>
        /// Numero de Identificacion Tributaria
        /// </summary>
        NIT,
        /// <summary>
        /// Numero de Pasaporte
        /// </summary>
        PASS
    }
}
