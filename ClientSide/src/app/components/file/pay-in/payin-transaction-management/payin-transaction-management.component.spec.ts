import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { PayinTransactionManagementComponent } from './payin-transaction-management.component';

describe('PayinTransactionManagementComponent', () => {
  let component: PayinTransactionManagementComponent;
  let fixture: ComponentFixture<PayinTransactionManagementComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ PayinTransactionManagementComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(PayinTransactionManagementComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
