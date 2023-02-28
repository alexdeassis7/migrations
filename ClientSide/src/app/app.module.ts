import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { ReactiveFormsModule } from '@angular/forms';
import { FormsModule } from '@angular/forms';
import { HttpClientModule, HTTP_INTERCEPTORS } from '@angular/common/http';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { DatePipe } from '@angular/common'
import { ToastrModule } from 'ngx-toastr';

//Rutas
import { ROUTES } from './app.routes';

//Servicios
import { LpConsultDataService } from './services/lp-consult-data.service';
import { LpSecurityDataService } from './services/security/lp-security-data.service';
import { ClientDataShared } from './components/services/lp-client-data.service';
import { ModalServiceLp } from './components/services/lp-modal.service';
import { AuthorizatedGuard } from './services/security/authentication.guard'
import { LpMasterDataService } from './services/lp-master-data.service'
import { LpDashboardService } from 'src/app/services/lp-dashboard.service'
import { LpPayoutService } from 'src/app/services/lp-payout.service'
import { LpPayinService } from 'src/app/services/lp-payin.service'
import { LpReportService } from 'src/app/services/lp-report.service'
import { LpExportService } from 'src/app/services/lp-export.service'
import { LpWalletService } from 'src/app/services/lp-wallet.service'
import { LpTransactionService } from 'src/app/services/lp-transaction.service'
import { LpAfipService } from 'src/app/services/lp-afip.service'
import { RefreshTokenInterceptor } from './services/security/authentication-interceptor'

//Pipes
import { FilterPipe } from 'src/app/pipes/filter.pipe';
import { ToFixedPipe } from 'src/app/pipes/toFixed.pipe';

//Componentes
import { AppComponent } from './app.component';
import { NabvarComponent } from './components/shared/nabvar/nabvar.component';
import { SideNabvarComponent } from './components/shared/side-nabvar/side-nabvar.component';
import { BreadcrumbComponent } from './components/shared/breadcrumb/breadcrumb.component';
import { FooterComponent } from './components/shared/footer/footer.component';
import { LoginComponent } from './components/security/login/login.component';
import { DashboardComponent } from './components/dashboard/dashboard.component';
import { ClientDashboardComponent } from './components/clientDashboard/clientDashboard.component';
import { RouterModule } from '@angular/router';
import { RegistrerComponent } from './components/security/registrer/registrer.component';
import { BodyComponent } from './components/body/body.component';
import { HomeComponent } from './components/home/home.component';
import { SpinnerWaitComponent } from './components/shared/spinner/spinner.component';
import { ModalSuccessComponent } from './components/shared/modals/modal-success/modal-success.component';
import { ModalErrorComponent } from './components/shared/modals/modal-error/modal-error.component';
import { ModalConfirmComponent } from './components/shared/modals/modal-confirm/modal-confirm.component';
import { CreateCheckOutComponent } from './components/checkOut/create-check-out/create-check-out.component';

//Componentes ngx-bootstrap
import { ModalModule } from 'ngx-bootstrap/modal';
import { BsDatepickerModule } from 'ngx-bootstrap/datepicker';
import { PopoverModule } from 'ngx-bootstrap/popover';
import { NgSelectModule } from '@ng-select/ng-select';
import { PayOutComponent } from './components/file/pay-out/pay-out.component';
import { PayInComponent } from './components/file/pay-in/pay-in.component';
import { MomentModule } from 'ngx-moment';
import { CollapseModule } from 'ngx-bootstrap/collapse';
import { ButtonsModule } from 'ngx-bootstrap/buttons';
import { InfiniteScrollModule } from 'ngx-infinite-scroll';
import { TooltipModule } from 'ngx-bootstrap/tooltip';

import { UserManagerComponent } from './components/management/user-manager/user-manager.component';
import { AltaUserComponent } from './components/management/user-manager/alta-user/alta-user.component';
import { AllDatabaseReportComponent } from './components/reportes/all-database-report/all-database-report.component';
import { MerchantReportComponent } from './components/reportes/merchant-report/merchant-report.component';
import { AccountReportComponent } from './components/reportes/account-report/account-report.component';
import { ProviderManagerComponent } from './components/management/provider-manager/provider-manager.component';
import { CreateTransactionComponent } from './components/tools/create-transaction/create-transaction.component';
import { RetentionsComponent } from './components/tools/retentions/retentions.component';
import { CertificatesComponent } from './components/tools/retentions/certificates.component';
import { PayinCashComponent } from './components/file/pay-in/payin-cash/payin-cash.component';
import { PayinSolBancariasComponent } from './components/file/pay-in/payin-sol-bancarias/payin-sol-bancarias.component';
import { PayoutGestionMerchantComponent } from './components/file/pay-out/payout-gestion-merchant/payout-gestion-merchant.component';
import { PayoutSolBancariasComponent } from './components/file/pay-out/payout-sol-bancarias/payout-sol-bancarias.component';
import { DetailsClientsTransactionReportComponent } from './components/reportes/details-clients-transaction-report/details-clients-transaction-report.component';
import { CargaSaldoComponent } from './components/shared/carga-saldo/carga-saldo.component'
import { EditValuesComponent } from './components/shared/edit-values/edit-values.component'
import { PagosCobrosComponent } from './components/shared/pagos-cobros/pagos-cobros.component'
import { HistoricalFxComponent } from './components/reportes/historical-fx/historical-fx.component';
import { OperationRetentionReportComponent } from './components/reportes/operation-retention-report/operation-retention-report.component';

import { CloseCycleMerchantComponent } from './components/dashboard/close-cycle-merchant/close-cycle-merchant.component';
import { CloseCycleProviderComponent } from './components/dashboard/close-cycle-provider/close-cycle-provider.component';
import { ReconciliationReportComponent } from './components/reportes/reconciliation-report/reconciliation-report.component';
import { CreditCardsComponent } from './components/credit-cards/credit-cards.component';
import { ChooseCountryComponent } from './components/security/choose-country/choose-country.component';
import { WhitelistManagerComponent } from './components/tools/retentions/whitelist-manager/whitelist-manager.component';
import { WhitelistAMComponent } from './components/tools/retentions/whitelist-am/whitelist-am.component';
import { WhitelistDetailComponent } from './components/tools/retentions/whitelist-detail/whitelist-detail.component';
import { ModalUploadedComponent } from './components/shared/modals/modal-uploaded/modal-uploaded.component';
import { ModalSessionExpiredComponent } from './components/shared/modals/modal-session-expired/modal-session-expired.component';
import { AuthorizatedGuardLogin } from './services/security/authentication-login.guard';
import { RejectedTransactionsComponent } from './components/reportes/rejected-transactions/rejected-transactions.component';
import { MerchantAccountBalanceReportComponent } from './components/reportes/merchant-account-balance-report/merchant-account-balance-report.component';
import { MerchantProyectedAccountBalanceReportComponent } from './components/reportes/merchant-proyected-account-balance-report/merchant-account-balance-report.component';

//Librerias
import { BnNgIdleService } from 'bn-ng-idle';
import { WithholdingRefundComponent } from './components/tools/retentions/withholding-refund/withholding-refund.component';
import { PayoutTransactionManagementComponent } from './components/file/pay-out/payout-transaction-management/payout-transaction-management.component';
import { PayinTransactionManagementComponent } from './components/file/pay-in/payin-transaction-management/payin-transaction-management.component';
import { PayoutTransactionManualCancelComponent } from './components/file/pay-out/payout-cancel-transaction/payout-cancel-transaction.component';
import { PayoutTransactionManualOnHoldComponent } from './components/file/pay-out/payout-onhold-transaction/payout-onhold-transaction.component';
import { PayoutInprogressToRecievedComponent } from './components/file/pay-out/payout-inprogress-to-recieved/payout-inprogress-to-recieved.component';
import { ActivityReportComponent } from './components/reportes/activity-report/activity-report.component';
import { PayoutReturnedComponent } from './components/file/pay-out/payout-returned/payout-returned.component';
import { CreateSignatureKeyComponent } from './components/tools/create-signature-key/create-signature-key.component';
import { CreateKeyComponent } from './components/tools/create-signature-key/create-key/create-key.component';
import { TransactionDataComponent } from './components/tools/transaction-data/transaction-data.component';
import { ClientDataComponent } from './components/tools/client-data/client-data.component';
import { AddAccountComponent } from './components/management/list-account/add-account/add-account.component';
import { ListAccountComponent } from './components/management/list-account/list-account.component';
import { EditAccountComponent } from './components/management/list-account/edit-account/edit-account.component';

@NgModule({
  declarations: [
    AppComponent,
    NabvarComponent,
    SideNabvarComponent,
    BreadcrumbComponent,
    FooterComponent,
    LoginComponent,
    DashboardComponent,
    ClientDashboardComponent,
    RegistrerComponent,
    BodyComponent,
    HomeComponent,
    PayOutComponent,
    PayInComponent,
    SpinnerWaitComponent,
    ModalSuccessComponent,
    ModalErrorComponent,
    ModalConfirmComponent,
    CargaSaldoComponent,
    EditValuesComponent,
    PagosCobrosComponent,
    CreateCheckOutComponent,
    FilterPipe, ToFixedPipe,
    UserManagerComponent,
    AltaUserComponent,
    AllDatabaseReportComponent,
    MerchantReportComponent,
    MerchantAccountBalanceReportComponent,
    MerchantProyectedAccountBalanceReportComponent,
    ActivityReportComponent,
    AccountReportComponent,
    ProviderManagerComponent,
    CreateTransactionComponent,
    RetentionsComponent,
    CertificatesComponent,
    PayinCashComponent,
    PayinSolBancariasComponent,
    PayoutGestionMerchantComponent,
    PayoutSolBancariasComponent,
    DetailsClientsTransactionReportComponent,
    HistoricalFxComponent,
    OperationRetentionReportComponent,    
    CloseCycleMerchantComponent,
    CloseCycleProviderComponent,
    ReconciliationReportComponent,
    CreditCardsComponent,
    ChooseCountryComponent,
    WhitelistManagerComponent,
    WhitelistAMComponent,
    WhitelistDetailComponent,
    ModalUploadedComponent,
    ModalSessionExpiredComponent,
    RejectedTransactionsComponent,
    WithholdingRefundComponent,
    PayoutTransactionManagementComponent,
    PayinTransactionManagementComponent,
    PayoutTransactionManualCancelComponent,
    PayoutTransactionManualOnHoldComponent,
    PayoutInprogressToRecievedComponent,
    PayoutReturnedComponent,
    CreateSignatureKeyComponent,
    CreateKeyComponent,
    TransactionDataComponent,    
    ClientDataComponent,
    AddAccountComponent,
    ListAccountComponent,
    EditAccountComponent
  ],

  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    HttpClientModule,
    ReactiveFormsModule,
    FormsModule,
    NgSelectModule,
    MomentModule,
    InfiniteScrollModule,
    // ROUTES
    RouterModule.forRoot(ROUTES),
    ModalModule.forRoot(),
    BsDatepickerModule.forRoot(),
    PopoverModule.forRoot(),
    CollapseModule.forRoot(),
    ButtonsModule.forRoot(),
    TooltipModule.forRoot(),
    ToastrModule.forRoot()
  ],
  providers: [
    LpConsultDataService, 
    LpSecurityDataService, 
    ClientDataShared, 
    ModalServiceLp, 
    AuthorizatedGuard, 
    LpMasterDataService,
    LpDashboardService, 
    LpPayoutService, 
    LpPayinService, 
    LpReportService, 
    LpExportService, 
    LpWalletService, 
    LpTransactionService, 
    LpAfipService,
    AuthorizatedGuardLogin, 
    BnNgIdleService,
    DatePipe,
    { provide: HTTP_INTERCEPTORS, useClass: RefreshTokenInterceptor, multi: true },
  ],
  bootstrap: [AppComponent],
  entryComponents: [SpinnerWaitComponent, ModalSuccessComponent, ModalErrorComponent, ModalConfirmComponent,ModalUploadedComponent, CreateCheckOutComponent, AltaUserComponent,ChooseCountryComponent,WhitelistAMComponent,WhitelistDetailComponent,ModalSessionExpiredComponent,CreateKeyComponent,EditAccountComponent]
})
export class AppModule { }
