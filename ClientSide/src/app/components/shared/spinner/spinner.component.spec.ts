import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { SpinnerWaitComponent } from './spinner.component';

describe('SpinnerComponent', () => {
  let component: SpinnerWaitComponent;
  let fixture: ComponentFixture<SpinnerWaitComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ SpinnerWaitComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(SpinnerWaitComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
