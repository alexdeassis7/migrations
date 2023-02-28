import { Component, Input, Output } from '@angular/core';
import { User } from 'src/app/models/userModel';
import { NabvarComponent } from './components/shared/nabvar/nabvar.component';


@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  title = 'LP';
  currentUser: User;

  sideBarIsOpened = false;

  ngOnInit() {
    this.sideBarIsOpened = true;
  }

  toggleSideBar(shouldOpen: boolean) {
    this.sideBarIsOpened = !this.sideBarIsOpened;
  }
}
