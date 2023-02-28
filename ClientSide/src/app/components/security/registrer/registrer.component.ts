import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
@Component({
  selector: 'app-registrer',
  templateUrl: './registrer.component.html',
  styleUrls: ['./registrer.component.css']
})
export class RegistrerComponent implements OnInit {
  registrerForm: FormGroup;
  submitted = false;
  home:boolean = false;
  constructor(
    private formBuilder: FormBuilder,
  ) { }

  ngOnInit() {
    this.registrerForm = this.formBuilder.group({
      firstName: ['', Validators.required],
      lastName: ['', Validators.required],
      username: ['', Validators.required],
      password: ['', [Validators.required, Validators.minLength(6)]]
  });


  }
  onSubmit() {}


}
