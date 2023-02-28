import { Component, OnInit, Input } from '@angular/core'
import { ClientDataShared } from 'src/app/components/services/lp-client-data.service'
import { trigger, state, style, animate, transition } from '@angular/animations'
import { LpSecurityDataService } from 'src/app/services/security/lp-security-data.service'
import { EnumViews } from 'src/app/components/services/enumViews'


@Component({
  selector: 'app-side-nabvar',
  templateUrl: './side-nabvar.component.html',
  styleUrls: ['./side-nabvar.component.css'],
  animations: [
    trigger('displayState', [
      state('inactive', style({
        position: 'relative',
        height: 0,
        overflow: 'hidden'
      })),
      state('active', style({
      })),
      transition('inactive => active', animate('.35s ease')),
      transition('active => inactive', animate('.35s ease'))
    ])
  ]
})
export class SideNabvarComponent implements OnInit {
  //@HostBinding('class.is-open')
  //@HostBinding('class.collapse')

  @Input() isOpen = false
  optionSelect: number
  submenuToggleGestor: boolean = true
  submenuToggleReport: boolean = true
  submenuToggleNewReport: boolean = true
  submenuToggleHerramientas: boolean = true
  submenuToggleReportEstandar: boolean = true
  submenuToggleGestorPayIn: boolean = true
  submenuToggleGestorPayOut: boolean = true
  submenuToggleManageUsers: boolean = true
  submenuToggleMerchantReport: boolean = true
  submenuToggleManualEdit: boolean = true
  
  subItem: string = ''
  subSubItem: string = ''
  userPermission: string = ''

  submenuTogglePayin: boolean = true
  submenuTogglePayOut: boolean = true

  constructor(private clientData: ClientDataShared, private securityService: LpSecurityDataService) { }

  ngOnInit() {
    this.userPermission = this.securityService.userPermission

    this.clientData.getCurrentView().subscribe(view => {
      if (view !== undefined) {
        this.optionSelect = view.indexView;
        this.subItem = view.subViewName;
        this.subSubItem = view.subSubViewName;

        switch (this.optionSelect) {
          case EnumViews.DASHBOARD:
            this.submenuToggleReport = true
            this.submenuToggleNewReport = true
            this.submenuToggleGestor = true
            this.submenuToggleHerramientas = true
            break
          case EnumViews.REPORTS:
            this.submenuToggleReport = false
            if (this.subSubItem != '') {
              if (this.subItem == 'MerchantReport' ) {

                this.submenuToggleMerchantReport = false;
              }
            
            }
            
            break
          case EnumViews.FILE_MANAGER:
            this.submenuToggleGestor = false
            if (this.subSubItem != '') {
              if (this.subItem == 'PayOut') {

                this.submenuToggleGestorPayOut = false;
              }
              else {

                this.submenuToggleGestorPayIn = false;
              }
            }
            break
          case EnumViews.TOOLS:
            this.submenuToggleHerramientas = false
            break
          case EnumViews.NEWREPORTS:
            this.submenuToggleNewReport = false;
            break;
        }
      }
    })
  }

  openCloseSubmenuGestor() {
    this.submenuToggleGestor = !this.submenuToggleGestor
    this.submenuToggleReport = true
    this.submenuToggleHerramientas = true
    this.submenuToggleNewReport = true
  }

  openCloseSubmenuReport() {
    this.submenuToggleReport = !this.submenuToggleReport
    this.submenuToggleHerramientas = true
    this.submenuToggleGestor = true
    this.submenuToggleNewReport = true
  }

  openCloseSubmenuNewReport() {
    this.submenuToggleNewReport = !this.submenuToggleNewReport
    this.submenuToggleHerramientas = true
    this.submenuToggleGestor = true
    this.submenuToggleReport = true
  }

  openCloseSubmenuHerramientas() {
    this.submenuToggleHerramientas = !this.submenuToggleHerramientas
    this.submenuToggleReport = true
    this.submenuToggleGestor = true
    this.submenuToggleNewReport = true
  }

  openCloseSubmenuReportEstandar() {
    this.submenuToggleReportEstandar = !this.submenuToggleReportEstandar
  }

  openCloseSubmenuPayin() {
    this.submenuTogglePayin = !this.submenuTogglePayin
  }

  openCloseSubmenuPayOut() {
    this.submenuTogglePayOut = !this.submenuTogglePayOut
  }

  openCloseSubmenuGestorPayin() {

    this.submenuToggleGestorPayIn = !this.submenuToggleGestorPayIn
    this.submenuToggleGestorPayOut = true
  }

  openCloseSubmenuGestorPayOut() {

    this.submenuToggleGestorPayOut = !this.submenuToggleGestorPayOut
    this.submenuToggleGestorPayIn = true
  }

  openCloseSubmenuManageUsers() {
    this.submenuToggleManageUsers = !this.submenuToggleManageUsers
  }

  openCloseSubmenuManualEdit() {

    this.submenuToggleManualEdit = !this.submenuToggleManualEdit
  }

  openCloseSubmenuReportsMerchant() {

    this.submenuToggleMerchantReport = !this.submenuToggleMerchantReport;
  }


}
