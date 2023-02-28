import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { PayOutComponent } from './pay-out.component';

describe('PayOutComponent', () => {
  let component: PayOutComponent;
  let fixture: ComponentFixture<PayOutComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ PayOutComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(PayOutComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
