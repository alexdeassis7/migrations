import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { WhitelistAMComponent } from './whitelist-am.component';

describe('WhitelistAMComponent', () => {
  let component: WhitelistAMComponent;
  let fixture: ComponentFixture<WhitelistAMComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ WhitelistAMComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(WhitelistAMComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
