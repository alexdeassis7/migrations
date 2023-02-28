import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { WhitelistManagerComponent } from './whitelist-manager.component';

describe('WhitelistManagerComponent', () => {
  let component: WhitelistManagerComponent;
  let fixture: ComponentFixture<WhitelistManagerComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ WhitelistManagerComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(WhitelistManagerComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
