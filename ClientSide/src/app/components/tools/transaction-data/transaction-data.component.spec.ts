import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { TransactionDataComponent } from './transaction-data.component';

describe('TransactionDataComponent', () => {
  let component: TransactionDataComponent;
  let fixture: ComponentFixture<TransactionDataComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ TransactionDataComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(TransactionDataComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
