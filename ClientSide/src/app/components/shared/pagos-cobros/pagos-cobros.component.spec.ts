import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { PagosCobrosComponent } from './pagos-cobros.component';

describe('PagosCobrosComponent', () => {
  let component: PagosCobrosComponent;
  let fixture: ComponentFixture<PagosCobrosComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ PagosCobrosComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(PagosCobrosComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
