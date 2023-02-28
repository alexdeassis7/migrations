import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { CloseCycleProviderComponent } from './close-cycle-provider.component';

describe('CloseCycleProviderComponent', () => {
  let component: CloseCycleProviderComponent;
  let fixture: ComponentFixture<CloseCycleProviderComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ CloseCycleProviderComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(CloseCycleProviderComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
