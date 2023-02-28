import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { CreateSignatureKeyComponent } from './create-signature-key.component';

describe('CreateSignatureKeyComponent', () => {
  let component: CreateSignatureKeyComponent;
  let fixture: ComponentFixture<CreateSignatureKeyComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ CreateSignatureKeyComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(CreateSignatureKeyComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
