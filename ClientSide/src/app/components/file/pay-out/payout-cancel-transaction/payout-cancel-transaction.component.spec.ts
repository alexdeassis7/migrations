import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { PayoutTransactionManualCancelComponent } from './payout-cancel-transaction.component';

describe('PayoutTransactionManualCancelComponent', () => {
  let component: PayoutTransactionManualCancelComponent;
  let fixture: ComponentFixture<PayoutTransactionManualCancelComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ PayoutTransactionManualCancelComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(PayoutTransactionManualCancelComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
