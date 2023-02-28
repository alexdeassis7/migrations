import { Injectable } from '@angular/core';
import { CanActivate, Router, ActivatedRouteSnapshot, RouterStateSnapshot, UrlTree } from '@angular/router';
import { Observable } from 'rxjs';
import { LpSecurityDataService } from 'src/app/services/security/lp-security-data.service';
@Injectable({
  providedIn: 'root'
})
export class ValidatePermissionGuard implements CanActivate {
  constructor(private router: Router, private securityService: LpSecurityDataService) {

  }
  canActivate() {
  
    if (this.securityService.userPermission == 'ADMIN') {
      return true;
    }

    this.router.navigate(['/Home/ClientDashboard']);
    return false;

  }

}
