import { Injectable } from "@angular/core";
import { BsModalService } from 'ngx-bootstrap/modal';
import { BsModalRef } from 'ngx-bootstrap/modal/bs-modal-ref.service';
import { ModalSuccessComponent } from 'src/app/components/shared/modals/modal-success/modal-success.component';
import { ModalErrorComponent } from 'src/app/components/shared/modals/modal-error/modal-error.component';
import { ModalConfirmComponent } from 'src/app/components/shared/modals/modal-confirm/modal-confirm.component';
import { SpinnerWaitComponent } from 'src/app/components/shared/spinner/spinner.component';
import { ModalUploadedComponent } from "../shared/modals/modal-uploaded/modal-uploaded.component";
import { ModalSessionExpiredComponent } from "../shared/modals/modal-session-expired/modal-session-expired.component";


//declare var jQuery: any;
declare var $: any;


@Injectable()

export class ModalServiceLp {

    modalRefAny: BsModalRef;
    modalRefSuccess: BsModalRef;
    modalRefError: BsModalRef;
    modalReConfirm: BsModalRef;
    modalRefSpinner: BsModalRef;
    modalRefSessionExpired: BsModalRef;
    _template: any = null;
    instanceSuccess: any;
    instanceError: any;
    instanceConfirm: any;
    instanceSpinner: any = null;

    constructor(private modalService: BsModalService) {

    }
    openModal(typeModal: string, _title: string = "", _message: string = "", _typeClass: string = ""): any {

        const initialState = {
            title: _title,
            message: _message
        };

        switch (typeModal) {

            case 'SUCCESS':

                this.modalRefSuccess = this.modalService.show(ModalSuccessComponent, { initialState });
                this.instanceSuccess = { name: 'SUCCESS', modalRef: this.modalRefSuccess }
                break;
            case 'ERROR':
                this.modalRefError = this.modalService.show(ModalErrorComponent, { initialState, class: _typeClass });
                this.instanceError = { name: 'ERROR', modalRef: this.modalService }



                break;
            case 'CONFIRM':

                this.modalReConfirm = this.modalService.show(ModalConfirmComponent, { initialState, class: _typeClass });
                this.instanceConfirm = { name: 'CONFIRM', modalRef: this.modalReConfirm }
                return this.modalReConfirm
                break;
            case 'UPLOADED':
                this.modalRefError = this.modalService.show(ModalUploadedComponent, { initialState, class: _typeClass });
                this.instanceError = { name: 'UPLOADED', modalRef: this.modalRefError }
                break;
            // case 'SESSION_EXPIRED':
            //     this.modalRefSessionExpired = this.modalService.show(ModalSessionExpiredComponent, { initialState, class: _typeClass });
            //     this.instanceError = { name: 'EXPIRED', modalRef: this.modalRefError }
            //     break;
            default:
                break;
        }
        if (_typeClass == 'second') {

            $('modal-container:first').append('<bs-modal-backdrop id="bd-second" class="modal-backdrop fade in show"></bs-modal-backdrop>')

        }
    }

    closeAnyModal(){
        this.modalRefAny.hide()
    }

    closeModal(name: string) {

        switch (name) {

            case 'SUCCESS':
                this.modalRefSuccess.hide();
                break;

            case 'ERROR':
                this.modalRefError.hide();
                break;
            case 'CONFIRM':
                this.modalReConfirm.hide();
                break;


            default:
                break;
        }
    }

    public get ModalService(): BsModalService {
        return this.modalService;
    }

    showSpinner() {

        $('.modalSpinner').modal('show');
    }

    hideSpinner() {
        $('.modalSpinner').modal('hide');

    }

    showModalSessionExpired(){
        const initialState = {
            title: 'Session Expired!',
            message: 'Your session is expired,   will be redirect to login page in '
        };
        this.modalRefSessionExpired = this.modalService.show(ModalSessionExpiredComponent, { initialState, class: '' });
        this.instanceError = { name: 'EXPIRED', modalRef: this.modalRefSessionExpired }
    }


}