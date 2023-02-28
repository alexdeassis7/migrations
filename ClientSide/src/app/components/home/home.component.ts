import { Component, Input, Output,OnInit } from '@angular/core';


@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.css']
})
export class HomeComponent implements OnInit {
  title = 'LP';
  // currentUser: User;
  shouldOpen:boolean;
  sideBarIsOpened = false;

  ngOnInit() {
    this.sideBarIsOpened = true;
    
    
  }

  toggleSideBar(shouldOpen: boolean) {
    this.sideBarIsOpened = !this.sideBarIsOpened;
  }

}
