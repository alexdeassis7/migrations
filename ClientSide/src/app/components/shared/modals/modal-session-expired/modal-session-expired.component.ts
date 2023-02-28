import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { BsModalRef } from 'ngx-bootstrap/modal';
import { interval } from 'rxjs';
import { environment } from 'src/environments/environment';

@Component({
  selector: 'app-modal-session-expired',
  templateUrl: './modal-session-expired.component.html',
  styleUrls: ['./modal-session-expired.component.css']
})
export class ModalSessionExpiredComponent implements OnInit {

  cont: number = 3;
  message: string;
  title:string
  messageClient: string="3";
  CheckIntervalSession: any

  constructor(private router: Router, public bsModalRef: BsModalRef) { }

  ngOnInit() {

    this.CheckIntervalSession = setInterval(() => {

      if (this.cont > 0) {
        this.messageClient  = this.cont.toString();
        this.cont--

      }
      else {
        clearInterval(this.CheckIntervalSession);       
        window.location.href = environment.baseHref
      }

     
    }, 1000)

 
  }

}
