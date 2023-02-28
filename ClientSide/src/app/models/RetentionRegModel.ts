export class RetentionReg {
 
    idReg:string
    reg:string
    description:string
    idDescription: string
    constructor(_user: any) {
        this.idReg = _user.idReg || null;
        this.reg = _user.reg || null;
        this.description = _user.description || null;        
        this.idDescription = _user.reg + ' - ' + _user.description

    }

}