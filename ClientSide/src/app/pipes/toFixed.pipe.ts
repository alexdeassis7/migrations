import { Pipe, PipeTransform } from '@angular/core';

@Pipe({ name: 'fixedDecimal' })
export class ToFixedPipe implements PipeTransform {

    transform(value: any, args?: any, isDollar? :string, typeCurrency?:string, entero?:boolean): any {
        // typeCurrency = "";
        let valueFixed = "-";
        let isNegative : boolean = false

        if (value != null) {
            if (Math.sign(value) == -1) { isNegative = true; value = value * -1 }
            if (value.toString().includes('.')) {

                let auxSplit = value.toString().split('.')
                let inter = auxSplit[0];
                let decimals = auxSplit[1];

                inter = inter.toString().split('').reverse().join('').replace(/(?=\d*\.?)(\d{3})/g, '$1.');
                inter = inter.split('').reverse().join('').replace(/^[\.]/, '');
                if(isNegative == true ){ 
                    if(isDollar == 'YES'){
                        valueFixed = (typeCurrency != undefined ? (typeCurrency + '  -') : '  -'  ) +  inter + ',' + decimals.substr(0, 6)

                    }
                    else{
                        valueFixed = (typeCurrency != undefined ? (typeCurrency + '  -') : '  -' )  + inter + ',' + decimals.substr(0, 2)

                    }
                   
                  }
                  else{
                    if(isDollar == 'YES'){
                        valueFixed = (typeCurrency != undefined ? (typeCurrency + ' ') : ' ' ) + inter + ',' + decimals.substr(0, 6)

                    }
                    else{
                        valueFixed = (typeCurrency != undefined ? (typeCurrency + ' ') : ' ')  +  inter + ',' + decimals.substr(0, 2)

                    }
                    
                  }
           
                

            }
            else {
               if(entero){
                valueFixed = (typeCurrency != undefined ? (typeCurrency + '  ') : '  -'  )+ value.toString().substr(0,value.toString().length-2).toString().split('').reverse().join('').replace(/(?=\d*\.?)(\d{3})/g, '$1.').split('').reverse().join('').replace(/^[\.]/, '')+','+value.toString().substr(value.toString().length-2,2)
               }
               else{
                    if (parseFloat(value) == 0 || value == null) {
        
                        valueFixed = '-';
                    }
                    else {
    
                        let aux = value.toString().split('').reverse().join('').replace(/(?=\d*\.?)(\d{3})/g, '$1.').split('').reverse().join('').replace(/^[\.]/, '') + ',' + '00';
                        if(isNegative == true ){
                            valueFixed = ( typeCurrency != undefined ? (typeCurrency + ' -') : ' -' ) + aux   
                        }
                        else {
                            valueFixed = ( typeCurrency != undefined ? (typeCurrency + ' ') : ' ' ) + aux
                        }              
                    }
               }
            }
        }
        return valueFixed;
    }
}