import { TestBed, async, inject } from '@angular/core/testing';

import { ValidatePermissionGuard } from './validate-permission.guard';

describe('ValidatePermissionGuard', () => {
  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [ValidatePermissionGuard]
    });
  });

  it('should ...', inject([ValidatePermissionGuard], (guard: ValidatePermissionGuard) => {
    expect(guard).toBeTruthy();
  }));
});
