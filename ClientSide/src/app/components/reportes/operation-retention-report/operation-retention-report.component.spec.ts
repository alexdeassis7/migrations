import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { OperationRetentionReportComponent } from './operation-retention-report.component';

describe('OperationRetentionReportComponent', () => {
  let component: OperationRetentionReportComponent;
  let fixture: ComponentFixture<OperationRetentionReportComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ OperationRetentionReportComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(OperationRetentionReportComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
