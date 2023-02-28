using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WA_LP.Infrastructure
{
#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    public static class ConcurrentService
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
    {
        private readonly static object lockRS = new object();

#pragma warning disable CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        public static void ExecuteSafe(Action toDo)
#pragma warning restore CS1591 // Falta el comentario XML para el tipo o miembro visible públicamente
        {
            lock (lockRS)
            {
                toDo();
            }
        }
    }
}