import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { ModalUploadedComponent } from './modal-uploaded.component';

describe('ModalUploadedComponent', () => {
  let component: ModalUploadedComponent;
  let fixture: ComponentFixture<ModalUploadedComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ ModalUploadedComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(ModalUploadedComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
