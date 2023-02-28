import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { CloseCycleMerchantComponent } from './close-cycle-merchant.component';

describe('CloseCycleMerchantComponent', () => {
  let component: CloseCycleMerchantComponent;
  let fixture: ComponentFixture<CloseCycleMerchantComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ CloseCycleMerchantComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(CloseCycleMerchantComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
