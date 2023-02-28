import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { HistoricalFxComponent } from './historical-fx.component';

describe('HistoricalFxComponent', () => {
  let component: HistoricalFxComponent;
  let fixture: ComponentFixture<HistoricalFxComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ HistoricalFxComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(HistoricalFxComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
