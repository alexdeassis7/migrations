import { Routes } from "@angular/router";
import { DashboardComponent } from "./components/dashboard/dashboard.component";
import { ClientDashboardComponent } from './components/clientDashboard/clientDashboard.component';
import { LoginComponent } from "./components/security/login/login.component";
import { RegistrerComponent } from './components/security/registrer/registrer.component';
import { HomeComponent } from './components/home/home.component';
import { AuthorizatedGuard } from './services/security/authentication.guard'
import { ValidatePermissionGuard } from './services/security/validate-permission.guard';
import { PayInComponent } from "./components/file/pay-in/pay-in.component";
import { PayOutComponent } from "./components/file/pay-out/pay-out.component";
import { CreateCheckOutComponent } from "./components/checkOut/create-check-out/create-check-out.component";


import { UserManagerComponent } from './components/management/user-manager/user-manager.component';
import { AllDatabaseReportComponent } from './components/reportes/all-database-report/all-database-report.component';
import { MerchantReportComponent } from './components/reportes/merchant-report/merchant-report.component';
import { AccountReportComponent } from './components/reportes/account-report/account-report.component';
import { CreateTransactionComponent } from './components/tools/create-transaction/create-transaction.component';
import { RetentionsComponent } from './components/tools/retentions/retentions.component';
import { CertificatesComponent } from './components/tools/retentions/certificates.component';
import { PayinCashComponent } from "./components/file/pay-in/payin-cash/payin-cash.component";
import { PayinSolBancariasComponent } from "./components/file/pay-in/payin-sol-bancarias/payin-sol-bancarias.component";
import { PayoutGestionMerchantComponent } from "./components/file/pay-out/payout-gestion-merchant/payout-gestion-merchant.component";
import { PayoutSolBancariasComponent } from "./components/file/pay-out/payout-sol-bancarias/payout-sol-bancarias.component";

import { DetailsClientsTransactionReportComponent } from "./components/reportes/details-clients-transaction-report/details-clients-transaction-report.component";
import { HistoricalFxComponent} from "./components/reportes/historical-fx/historical-fx.component"
import { OperationRetentionReportComponent } from './components/reportes/operation-retention-report/operation-retention-report.component';
import { ReconciliationReportComponent } from './components/reportes/reconciliation-report/reconciliation-report.component';
import { CreditCardsComponent } from './components/credit-cards/credit-cards.component';
import { AuthorizatedGuardLogin } from "./services/security/authentication-login.guard";
import { RejectedTransactionsComponent } from "./components/reportes/rejected-transactions/rejected-transactions.component";
import { PayoutTransactionManagementComponent } from "./components/file/pay-out/payout-transaction-management/payout-transaction-management.component";
import { PayinTransactionManagementComponent } from "./components/file/pay-in/payin-transaction-management/payin-transaction-management.component";
import { PayoutTransactionManualCancelComponent } from "./components/file/pay-out/payout-cancel-transaction/payout-cancel-transaction.component";
import { PayoutTransactionManualOnHoldComponent } from "./components/file/pay-out/payout-onhold-transaction/payout-onhold-transaction.component";
import { MerchantAccountBalanceReportComponent } from "./components/reportes/merchant-account-balance-report/merchant-account-balance-report.component";
import { MerchantProyectedAccountBalanceReportComponent } from "./components/reportes/merchant-proyected-account-balance-report/merchant-account-balance-report.component";
import { PayoutInprogressToRecievedComponent } from "./components/file/pay-out/payout-inprogress-to-recieved/payout-inprogress-to-recieved.component";
import { ActivityReportComponent } from "./components/reportes/activity-report/activity-report.component";
import { PayoutReturnedComponent } from './components/file/pay-out/payout-returned/payout-returned.component';
import { CreateSignatureKeyComponent } from './components/tools/create-signature-key/create-signature-key.component';
import { TransactionDataComponent } from "./components/tools/transaction-data/transaction-data.component";
import { ClientDataComponent } from "./components/tools/client-data/client-data.component";
import { AddAccountComponent } from "./components/management/list-account/add-account/add-account.component";
import { ListAccountComponent } from "./components/management/list-account/list-account.component";


export const ROUTES: Routes = [


    { path: 'Login', component: LoginComponent, canActivate:[AuthorizatedGuardLogin] },

    {
        path: 'Home', component: HomeComponent, canActivate: [AuthorizatedGuard],
        children: [
            { path: '', pathMatch: 'full', redirectTo: 'Dashboard' },
            { path: 'Dashboard', component: DashboardComponent, canActivate: [ValidatePermissionGuard] },
            { path: 'ClientDashboard', component: ClientDashboardComponent },
            { path: 'Reports/AllDBReport', component: AllDatabaseReportComponent},
            { path: 'Reports/MerchantAccountBalance', component: MerchantAccountBalanceReportComponent},
            { path: 'Reports/MerchantProyectedAccountBalance', component: MerchantProyectedAccountBalanceReportComponent},
            { path: 'Reports/MerchantReport', component: MerchantReportComponent, canActivate: [ValidatePermissionGuard]  },
            { path: 'Reports/DetailClientTransaction', component: DetailsClientsTransactionReportComponent },
            { path: 'Reports/HistoricalFx', component: HistoricalFxComponent ,canActivate: [ValidatePermissionGuard]  },
            { path: 'Reports/OperationRetention', component: OperationRetentionReportComponent }, 
            { path: 'Reports/PayoneerReport', component: ReconciliationReportComponent,canActivate: [ValidatePermissionGuard]  },                  
            { path: 'Reports/RejectedTransactions',component:RejectedTransactionsComponent },
            { path: 'Reports/AccountReport',component:AccountReportComponent },
            { path: 'Reports/ActivityReport', component: ActivityReportComponent },
            { path: 'PayIn', component: PayInComponent ,canActivate: [ValidatePermissionGuard] },
            { path: 'PayOut', component: PayOutComponent ,canActivate: [ValidatePermissionGuard] },
            { path: 'PayIn/Cash', component: PayinCashComponent,canActivate: [ValidatePermissionGuard]  },
            { path: 'PayIn/SolBancarias', component: PayinSolBancariasComponent ,canActivate: [ValidatePermissionGuard] },
            { path: 'PayIn/TxsManagement', component: PayinTransactionManagementComponent, canActivate: [ValidatePermissionGuard] },
            { path: 'PayOut/Gestion', component: PayoutGestionMerchantComponent  },
            { path: 'PayOut/SolBancarias', component: PayoutSolBancariasComponent, canActivate: [ValidatePermissionGuard] },
            { path: 'PayOut/TxsManagement', component: PayoutTransactionManagementComponent, canActivate: [ValidatePermissionGuard] },
            { path: 'PayOut/ManualCancel', component: PayoutTransactionManualCancelComponent, canActivate: [ValidatePermissionGuard] },
            { path: 'PayOut/ManualOnHold', component: PayoutTransactionManualOnHoldComponent, canActivate: [ValidatePermissionGuard] },
            { path: 'PayOut/ManualRecieved', component: PayoutInprogressToRecievedComponent, canActivate: [ValidatePermissionGuard] },
            { path: 'PayOut/Returned', component: PayoutReturnedComponent, canActivate: [ValidatePermissionGuard] },
            { path: 'Tools/CreateCheckOut', component: CreateCheckOutComponent, canActivate: [ValidatePermissionGuard] },
            { path: 'UserManager', component: UserManagerComponent, canActivate: [ValidatePermissionGuard]  },
            { path: 'Dashboard/:user', component: DashboardComponent,canActivate: [ValidatePermissionGuard]  },
            { path: 'Tools/create-transaction', component: CreateTransactionComponent,canActivate: [ValidatePermissionGuard]  },
            { path: 'Tools/Withholdings', component: RetentionsComponent,canActivate: [ValidatePermissionGuard]  },
            { path: 'Tools/Certificates', component: CertificatesComponent },
            { path: 'Tools/creditCards', component: CreditCardsComponent,canActivate: [ValidatePermissionGuard] },
            { path: 'Tools/Signature', component: CreateSignatureKeyComponent,canActivate: [ValidatePermissionGuard] },
            { path: 'Tools/TransactionData', component: TransactionDataComponent,canActivate: [ValidatePermissionGuard] },
            { path: 'Tools/ClientData', component: ClientDataComponent,canActivate: [ValidatePermissionGuard] },
            { path: 'AddAccount', component: AddAccountComponent, canActivate: [ValidatePermissionGuard]  },
            { path: 'ListAccount', component: ListAccountComponent, canActivate: [ValidatePermissionGuard]  },
        ]
    },

    { path: 'Registrer', component: RegistrerComponent },

    // Vista que se muestra por defecto o cuando ingresa una url desconocida

    { path: '', pathMatch: 'full', redirectTo: 'Login' },
    { path: '**', pathMatch: 'full', redirectTo: 'Login' },
    { path: 'client', pathMatch: 'full', redirectTo: 'Login' },

];
