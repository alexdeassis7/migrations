import { Component, OnInit, Input } from '@angular/core';
import { Subject, Subscription } from 'rxjs';
import { BsModalRef } from 'ngx-bootstrap/modal';

@Component({
  selector: 'app-create-key',
  templateUrl: './create-key.component.html',
  styleUrls: ['./create-key.component.css']
})
export class CreateKeyComponent implements OnInit {
  @Input() ListUser: any[] = [];
  UserSelect: any;
  public onClose: Subject<any>;
  constructor(public bsModalRef: BsModalRef) { }

  ngOnInit() {
    this.onClose = new Subject();
  }

  createKey() 
  {
    this.bsModalRef.hide();
    this.onClose.next(this.UserSelect);
  }

}
