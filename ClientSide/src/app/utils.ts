export default class Utils {
  static findTransactionTypeCode(list: any[], id: number) {
    const select = list.find(e => e.idTransactionType === id)
    return select ? select.TT_Code : null
  }

  static validateAmount(amount: string, maxIntegers: number, maxDecimals: number) {
    if (amount.trim() == '')
      return true;

    const regexp = new RegExp(`^[+ -]?[0-9]{1,${maxIntegers}}([.][0-9]{1,${maxDecimals}})?$`)
    return (amount !== '' && regexp.test(amount) && parseFloat(amount) > 0)
  }

  static getFlagClass(code: string) {
    let nameClass = ''
    switch (code) {

      case 'ARG':
        nameClass = 'flagARG'
        break;
      case 'ECU':
          nameClass = 'flagECU'  
        break;
      case 'COL':
        nameClass = 'flagCOL'
        break;
      case 'BRA':
        nameClass = 'flagBRA'
        break;
      case 'URY':
        nameClass = 'flagURY'
        break
      case 'MEX':
        nameClass = 'flagMEX'
        break
      case 'CHL':
        nameClass = 'flagCHL'
      break
      case 'PER':
        nameClass = 'flagPER'
      break
      case 'PRY':
        nameClass = 'flagPRY'
      break
      case 'BOL':
        nameClass = 'flagBOL'
      break
      case 'PAN':
        nameClass = 'flagPAN'
      break
      case 'CRI':
        nameClass = 'flagCRI'
      break
      case 'SLV':
        nameClass = 'flagSLV'
      break
      case 'GLO':
        nameClass = 'flagWWW'
        break  
      default:
        break;

    }

    return nameClass;

  }
  // // Para Errores de Payout

  static mergeError(listErrors: any) {

    let messages = ""

    if (listErrors.length > 0) {

      listErrors.forEach(error => {
        messages += error.Messages
      });
    }
    return messages;

  }

  
  // static mergeError(listErrors: any) {

  //   let messages = ""

  //   if (listErrors.length > 0) {

  //     listErrors.forEach(error => {
  //       messages = messages +  "  **Key:  " + error.Key + "  Messages:  "
  //       error.Messages.forEach(msg => {
  //         messages = messages + "  " + msg;
  //       });
  //     });
  //   }
  //   return messages;

  // }

  static mergeErrorPopover(listErrors: any) {

    let messagesError = []
    let messages: string = ""
    if (listErrors.length > 0) {

      listErrors.forEach(error => {
       
        messages = "  <strong>** </strong>Key:  " + error.Key + " *Messages:  "
        error.Messages.forEach(msg => {
          messages = messages + "  " + msg;
        });
        messagesError.push(messages);
      });
     
    }
    return messagesError;

  }

  static validateNumber(value: any) {
    if (value != "" || value != null) {
      var regexNumber = /^\d*\.?\d*$/;
      return regexNumber.test(value);
    }
    else {
      return true;
    }
  }
}