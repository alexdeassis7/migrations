import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { PayinCashComponent } from './payin-cash.component';

describe('PayinCashComponent', () => {
  let component: PayinCashComponent;
  let fixture: ComponentFixture<PayinCashComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ PayinCashComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(PayinCashComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
