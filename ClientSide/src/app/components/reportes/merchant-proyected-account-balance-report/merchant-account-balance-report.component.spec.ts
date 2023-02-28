import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { MerchantProyectedAccountBalanceReportComponent } from './merchant-proyected-account-balance-report.component';

describe('MerchantAccountBalanceReportComponent', () => {
  let component: MerchantProyectedAccountBalanceReportComponent;
  let fixture: ComponentFixture<MerchantProyectedAccountBalanceReportComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ MerchantProyectedAccountBalanceReportComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(MerchantProyectedAccountBalanceReportComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
