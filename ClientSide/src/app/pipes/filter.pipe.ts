import { Pipe, PipeTransform } from '@angular/core';

@Pipe({ name: 'filter' })
export class FilterPipe implements PipeTransform {

    transform(value: any, args?: any): any {
        // let pepe: String = "prueba"
        // pepe.includes
        return value = value.filter(it => it.transaction_id.toString().includes(args) 
                                    || (it.bank_cbu != null && it.bank_cbu.toString().includes(args) )
                                    || (it.currency != null && it.currency.toString().toUpperCase().includes(args.toUpperCase()) )
                                    || (it.beneficiary_name != null &&  it.beneficiary_name.toString().toUpperCase().includes(args.toUpperCase()) )
                                    
        );    
    }
}