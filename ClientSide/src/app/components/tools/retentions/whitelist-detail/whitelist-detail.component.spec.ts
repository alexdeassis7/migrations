import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { WhitelistDetailComponent } from './whitelist-detail.component';

describe('WhitelistDetailComponent', () => {
  let component: WhitelistDetailComponent;
  let fixture: ComponentFixture<WhitelistDetailComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ WhitelistDetailComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(WhitelistDetailComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
