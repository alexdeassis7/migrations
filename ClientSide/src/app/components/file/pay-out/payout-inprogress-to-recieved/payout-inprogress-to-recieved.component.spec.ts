import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { PayoutInprogressToRecievedComponent } from './payout-inprogress-to-recieved.component';

describe('PayoutInprogressToRecievedComponent', () => {
  let component: PayoutInprogressToRecievedComponent;
  let fixture: ComponentFixture<PayoutInprogressToRecievedComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ PayoutInprogressToRecievedComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(PayoutInprogressToRecievedComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
