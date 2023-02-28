import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpResponse } from '@angular/common/http'
import { User } from 'src/app/models/userModel'
import { environment } from 'src/environments/environment'
import { LpSecurityDataService } from 'src/app/services/security/lp-security-data.service'

import { LpDashboardService } from 'src/app/services/lp-dashboard.service'
import { LpPayoutService } from 'src/app/services/lp-payout.service'
import { LpPayinService } from 'src/app/services/lp-payin.service'
import { LpReportService } from 'src/app/services/lp-report.service'
import { LpExportService } from 'src/app/services/lp-export.service'
import { LpWalletService } from 'src/app/services/lp-wallet.service'
import { LpTransactionService } from 'src/app/services/lp-transaction.service'
import { LpAfipService } from 'src/app/services/lp-afip.service'
import { LpFilterService } from './lp-filter.service';
import { LpRetentionsService } from './lp-retentions.service';
import { LpCreditCardsService } from './lp-creditCards.service';



interface Header {
  [key: string]: string
}

type ApiURLs = {
  [key: string]: string
}


@Injectable({
  providedIn: 'root'
})
export class LpMasterDataService {

  constructor(public Dashboard: LpDashboardService, public Payout: LpPayoutService, public Payin: LpPayinService, public Reports: LpReportService,public Filters: LpFilterService,
    public Export: LpExportService, public Wallet: LpWalletService, public Transactions: LpTransactionService, public Afip: LpAfipService, public Retentions:LpRetentionsService, public CreditCards: LpCreditCardsService) { }
}
