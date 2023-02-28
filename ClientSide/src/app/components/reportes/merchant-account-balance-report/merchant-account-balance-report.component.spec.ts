import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { MerchantAccountBalanceReportComponent } from './merchant-account-balance-report.component';

describe('MerchantAccountBalanceReportComponent', () => {
  let component: MerchantAccountBalanceReportComponent;
  let fixture: ComponentFixture<MerchantAccountBalanceReportComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ MerchantAccountBalanceReportComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(MerchantAccountBalanceReportComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
