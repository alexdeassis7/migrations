import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { PayoutGestionMerchantComponent } from './payout-gestion-merchant.component';

describe('PayoutGestionMerchantComponent', () => {
  let component: PayoutGestionMerchantComponent;
  let fixture: ComponentFixture<PayoutGestionMerchantComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ PayoutGestionMerchantComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(PayoutGestionMerchantComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
