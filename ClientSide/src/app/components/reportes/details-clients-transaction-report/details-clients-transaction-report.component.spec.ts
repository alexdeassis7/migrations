import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { DetailsClientsTransactionReportComponent } from './details-clients-transaction-report.component';

describe('DetailsClientsTransactionReportComponent', () => {
  let component: DetailsClientsTransactionReportComponent;
  let fixture: ComponentFixture<DetailsClientsTransactionReportComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ DetailsClientsTransactionReportComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(DetailsClientsTransactionReportComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
