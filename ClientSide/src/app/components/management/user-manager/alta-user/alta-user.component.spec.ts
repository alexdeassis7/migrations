import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { AltaUserComponent } from './alta-user.component';

describe('AltaUserComponent', () => {
  let component: AltaUserComponent;
  let fixture: ComponentFixture<AltaUserComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ AltaUserComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(AltaUserComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
