import { Component, OnInit } from '@angular/core';
import { User } from 'src/app/models/userModel';


@Component({
  selector: 'app-body',
  templateUrl: './body.component.html',
  styleUrls: ['./body.component.css']
})
export class BodyComponent implements OnInit {
  currentUser: User;

  constructor() { }

  ngOnInit() {
  }

}
