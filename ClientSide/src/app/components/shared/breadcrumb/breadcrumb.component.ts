import { Component, OnInit, Input, Output,EventEmitter  } from '@angular/core';
import { Observable } from 'rxjs/Rx';
import{ ClientDataShared } from 'src/app/components/services/lp-client-data.service';

@Component({
  selector: 'app-breadcrumb',
  templateUrl: './breadcrumb.component.html',
  styleUrls: ['./breadcrumb.component.css']
 
})
export class BreadcrumbComponent implements OnInit {
  
  breadCrumbItems:any = [];

  constructor(private clientData:ClientDataShared) { }

  
  ngOnInit() {

    this.clientData.inicializeBreadCrumb();  

    this.clientData.getItemsBreadCrumb().subscribe(items =>  
      this.breadCrumbItems = items
    )}
  }
