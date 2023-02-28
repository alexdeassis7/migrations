import { Injectable } from '@angular/core';
import { Router, CanActivate } from '@angular/router';
import { LpSecurityDataService } from 'src/app/services/security/lp-security-data.service';
@Injectable()
export class AuthorizatedGuard implements CanActivate {
  constructor(private router: Router, private securityService: LpSecurityDataService) { }
  canActivate() {
 
    if (this.securityService.isAuthenticated()) {

      return true;
    }

    this.router.navigate(['/Login']);
    return false;
  }
}
