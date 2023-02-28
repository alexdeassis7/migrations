import { Injectable } from "@angular/core";
import { HttpRequest, HttpHandler, HttpEvent, HttpInterceptor } from "@angular/common/http";
import { LpSecurityDataService } from "./lp-security-data.service";
import { Observable } from "rxjs/Observable";
import { BehaviorSubject } from "rxjs/BehaviorSubject";
import { JwtHelperService } from "@auth0/angular-jwt";
@Injectable()
export class RefreshTokenInterceptor implements HttpInterceptor {
    private refreshTokenInProgress = false;
    private isLogginOut = false;
    // Refresh Token Subject tracks the current token, or is null if no token is currently
    // available (e.g. refresh pending).
    private refreshTokenSubject: BehaviorSubject<any> = new BehaviorSubject<any>(
        null
    );
    constructor(public auth: LpSecurityDataService) {}

    intercept(request: HttpRequest<any>,next: HttpHandler): Observable<HttpEvent<any>> 
    {
        return next.handle(request).catch(error => {

            //Check error status 0
            if(error.status == 0){
                //Check if token has expired
                if(this.auth.checkTokenExpired()){
                    this.auth.clearSession();
                }
            }

            //  don't refresh token for some requests like login or refresh token itself
            if (request.url.includes("Tokens") || request.url.includes("login")|| request.url.includes("firstfactor") ) 
            {
                // check if the refresh failed if so logout
                if (request.url.includes("RefreshToken")) {
                    this.auth.clearSession();
                }

                return Observable.throw(error);
            }

            //Check if error is 403 forbbidden, if so logout
            if (error.status == 403)
            {
                if (!this.isLogginOut) 
                {
                    this.isLogginOut = true;
                    this.auth.clearSession()
                }
            }

            // Check if error is 401 unauthorized, if not show error
            if (error.status !== 401) 
            {
                return Observable.throw(error);
            }

            if(error.status == 401){
                //Check if token has expired
                if(this.auth.checkTokenExpired()){
                    this.auth.clearSession();
                }
            }

            if (this.refreshTokenInProgress) {
                // If refreshTokenInProgress is true, we will wait until refreshTokenSubject has a non-null value
                // – which means the new token is ready and we can retry the request again
                return this.refreshTokenSubject
                    .filter(result => result !== null)
                    .take(1)
                    .switchMap(() => next.handle(this.addAuthenticationToken(request)));
            } else {
                this.refreshTokenInProgress = true;

                // Set the refreshTokenSubject to null so that subsequent API calls will wait until the new token has been retrieved
                this.refreshTokenSubject.next(null);

                // Call auth.refreshToken(this is an Observable that will be returned)
                return this.auth
                    .refreshToken()
                    .switchMap((token: any) => {
                        //When the call to refreshToken completes we reset the refreshTokenInProgress to false
                        // for the next time the token needs to be refreshed
                        this.refreshTokenInProgress = false;
                        this.auth.updateToken( token.token_id)
                        this.refreshTokenSubject.next(token);

                        return next.handle(this.addAuthenticationToken(request));
                    })
                    .catch((err: any) => {
                        this.refreshTokenInProgress = false;

                        this.auth.clearSession();
                        return Observable.throw(error);
                    });
            }
        });
    }

    addAuthenticationToken(request) {
        // Get access token from Local Storage
        const accessToken = this.auth.getAccessToken();

        // If access token is null this means that user is not logged in
        // And we return the original request
        if (!accessToken) {
            return request;
        }

        // We clone the request, because the original request is immutable
        return request.clone({
            setHeaders: {
                Authorization: accessToken
            }
        });
    }
}