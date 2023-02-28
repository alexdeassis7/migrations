import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { PayinSolBancariasComponent } from './payin-sol-bancarias.component';

describe('PayinSolBancariasComponent', () => {
  let component: PayinSolBancariasComponent;
  let fixture: ComponentFixture<PayinSolBancariasComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ PayinSolBancariasComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(PayinSolBancariasComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
