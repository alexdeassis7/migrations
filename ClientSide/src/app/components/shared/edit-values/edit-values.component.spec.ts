import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { EditValuesComponent } from './edit-values.component';

describe('EditValuesComponent', () => {
  let component: EditValuesComponent;
  let fixture: ComponentFixture<EditValuesComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ EditValuesComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(EditValuesComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
