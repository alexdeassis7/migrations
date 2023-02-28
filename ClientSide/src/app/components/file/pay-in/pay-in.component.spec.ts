import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { PayInComponent } from './pay-in.component';

describe('PayInComponent', () => {
  let component: PayInComponent;
  let fixture: ComponentFixture<PayInComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ PayInComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(PayInComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
