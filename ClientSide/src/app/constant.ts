interface ListTransactions {
  name: String,
  val: String
}

interface CreateTransaction {
  name: String,
  val: String
}

export class AppConstants {
  public static get ListTransactions(): Array<ListTransactions> { return [{ name: 'PayIn', val: '1' }, { name: 'PayOut', val: '2' }] }
  public static get ActionsType(): Array<CreateTransaction> { return [{ name: 'Accredit', val: '1' }, { name: 'Debit', val: '2' }] }
}
