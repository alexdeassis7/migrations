import { Injectable } from "@angular/core";
import { BehaviorSubject, Observable, Subject } from 'rxjs/Rx';


class viewSideBar {
    indexView: number;
    subViewName: String = "";
    subSubViewName: String="";

    constructor(view:any){

        this.indexView = view.indexView || "";
        this.subViewName = view.subViewName || ""
        this.subSubViewName = view.subSubViewName || ""

    }
  }

@Injectable()

export class ClientDataShared {

    items: any = [];
    currentView: viewSideBar;
    private itemsSubject = new BehaviorSubject([]);
    private currentViewSubject = new BehaviorSubject<any>(0);
    private currentViewSubject2 = new Subject <any>();
    // Breadcrumb
    getItemsBreadCrumb(): Observable<any[]> {
        return this.itemsSubject.asObservable();
    }

    inicializeBreadCrumb() {
        this.items = ['Home']
        this.itemsSubject.next(this.items);
        
    }
    refreshItemsBreadCrumb(newItems: any) {
        this.items = newItems;
        this.itemsSubject.next(this.items);
    }
    //Vista Actual
    setCurrentView(value: number,subView:string = "",subSubView: string ="") {
        // let sidebarParams = new viewSideBar( {indexView : value, subViewName : subView, subSubViewName : '' })
        let sidebarParams = new viewSideBar({indexView : value, subViewName : subView, subSubViewName : subSubView});
        // sidebarParams.indexView = value;
        // sidebarParams.subViewName = subView;
        // sidebarParams.subSubViewName = "";

            //   indexView: value, subViewName: subView,subSubViewName: ''}
        
        // console.log(sidebarParams)
          // console.log(sidebarParams);
        this.currentView = sidebarParams;
        // console.log(this.currentView)
        //Refresh Observable
        this.currentViewSubject.next(this.currentView);
    }
    getCurrentView(): Observable<any> {
        this.currentViewSubject.next(this.currentView);
        return this.currentViewSubject.asObservable();

    }
    getIndexCurrentView(){

        return this.currentView.indexView;
    }

    reloadAllDB(): Observable<any> {
        this.currentViewSubject2.next(true);
        return this.currentViewSubject2.asObservable();
    
    }
    

}