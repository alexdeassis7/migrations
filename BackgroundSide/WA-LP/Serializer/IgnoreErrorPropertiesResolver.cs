using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Web;

namespace WA_LP.Serializer
{
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public class IgnoreErrorPropertiesResolver : DefaultContractResolver
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
        List<string> ignoreList = new List<string>(new string[]{
                "InputStream",
                "Filter",
                "Length",
                "Position",
                "ReadTimeout",
                "WriteTimeout",
                "LastActivityDate",
                "LastUpdatedDate",
                "Session"
            });
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        protected override JsonProperty CreateProperty(MemberInfo member, MemberSerialization memberSerialization)
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            JsonProperty property = base.CreateProperty(member, memberSerialization);

            if (ignoreList.Contains(property.PropertyName)) {
                property.Ignored = true;
            }
            return property;
        }
    }
}