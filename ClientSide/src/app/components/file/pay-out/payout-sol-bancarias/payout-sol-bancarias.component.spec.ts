import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { PayoutSolBancariasComponent } from './payout-sol-bancarias.component';

describe('PayoutSolBancariasComponent', () => {
  let component: PayoutSolBancariasComponent;
  let fixture: ComponentFixture<PayoutSolBancariasComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ PayoutSolBancariasComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(PayoutSolBancariasComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
