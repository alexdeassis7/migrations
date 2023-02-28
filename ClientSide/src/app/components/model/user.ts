export class User {

    IdUser: number;
    Nombre: string;
    Apellido: string;
    Dni: string;
    Correo: string;
    Token: string;
    
    constructor(_user: any) {
        this.IdUser = _user.IdUser;
        this.Nombre = _user.Nombre;
        this.Apellido = _user.Apellido;
        this.Dni = _user.Dni;
        this.Correo = _user.Correo;
        this.Token = _user.Token;

    }

}
