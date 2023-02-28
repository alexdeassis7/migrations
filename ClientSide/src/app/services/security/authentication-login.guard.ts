import { Injectable } from '@angular/core';
import { Router, CanActivate } from '@angular/router';
import { LpSecurityDataService } from 'src/app/services/security/lp-security-data.service';
@Injectable()
export class AuthorizatedGuardLogin implements CanActivate {
  constructor(private router: Router, private securityService: LpSecurityDataService) { }
  canActivate() {
   
    if (this.securityService.isAuthenticated() && this.securityService.userPermission  == 'ADMIN') {
      this.router.navigate(['/Home/Dashboard'])
      return false
    
    }
    if (this.securityService.isAuthenticated() && this.securityService.userPermission  == 'COMMON') {
      this.router.navigate(['/Home/ClientDashboard'])
      return false
    
    }


    return true;
  }
}