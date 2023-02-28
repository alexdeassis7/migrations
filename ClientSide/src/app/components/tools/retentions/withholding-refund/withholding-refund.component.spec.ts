import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { WithholdingRefundComponent } from './withholding-refund.component';

describe('WithholdingRefundComponent', () => {
  let component: WithholdingRefundComponent;
  let fixture: ComponentFixture<WithholdingRefundComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ WithholdingRefundComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(WithholdingRefundComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
