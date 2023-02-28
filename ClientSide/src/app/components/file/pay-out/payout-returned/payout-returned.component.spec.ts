import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { PayoutReturnedComponent } from './payout-returned.component';

describe('PayoutReturnedComponent', () => {
  let component: PayoutReturnedComponent;
  let fixture: ComponentFixture<PayoutReturnedComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ PayoutReturnedComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(PayoutReturnedComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
