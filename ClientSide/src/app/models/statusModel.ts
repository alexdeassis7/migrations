export class Status {

    idStatus: number;
    Code: string;
    Name:string;
    NameCode:string;

    constructor(_status: any) {
        
        this.idStatus = _status.idStatus || null;        
        this.Code = _status.Code || null;
        this.Name = _status.Name || null;
        this.NameCode= _status.Name + ' - ' + _status.Code  || null;


    }

}
