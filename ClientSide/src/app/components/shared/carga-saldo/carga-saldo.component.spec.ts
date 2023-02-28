import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { CargaSaldoComponent } from './carga-saldo.component';

describe('CargaSaldoComponent', () => {
  let component: CargaSaldoComponent;
  let fixture: ComponentFixture<CargaSaldoComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ CargaSaldoComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(CargaSaldoComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
