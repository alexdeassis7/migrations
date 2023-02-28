import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { PayoutTransactionManualOnHoldComponent } from './payout-onhold-transaction.component';

describe('PayoutTransactionManualOnHoldComponent', () => {
  let component: PayoutTransactionManualOnHoldComponent;
  let fixture: ComponentFixture<PayoutTransactionManualOnHoldComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ PayoutTransactionManualOnHoldComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(PayoutTransactionManualOnHoldComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
