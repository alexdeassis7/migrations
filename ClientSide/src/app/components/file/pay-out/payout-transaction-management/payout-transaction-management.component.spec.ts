import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { PayoutTransactionManagementComponent } from './payout-transaction-management.component';

describe('PayoutTransactionManagementComponent', () => {
  let component: PayoutTransactionManagementComponent;
  let fixture: ComponentFixture<PayoutTransactionManagementComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ PayoutTransactionManagementComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(PayoutTransactionManagementComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
