import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { AllDatabaseReportComponent } from './all-database-report.component';

describe('AllDatabaseReportComponent', () => {
  let component: AllDatabaseReportComponent;
  let fixture: ComponentFixture<AllDatabaseReportComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ AllDatabaseReportComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(AllDatabaseReportComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
