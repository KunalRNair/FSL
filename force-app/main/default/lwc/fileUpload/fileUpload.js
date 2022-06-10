import { LightningElement, wire } from 'lwc';


import oppId from "@salesforce/apex/fileUpload.oppId";
import oppAtta from "@salesforce/apex/fileUpload.oppAtta";
import file from "@salesforce/apex/fileUpload.file";
import del from '@salesforce/apex/fileUpload.del';
import mail from '@salesforce/apex/fileUpload.mail';


import {NavigationMixin} from 'lightning/navigation';


export default class FileUpload extends NavigationMixin(LightningElement) {

    isModalOpen=false;
    opptions;
    data=[];
    currId;
    fileData;

    eatta;

    actions=[
                {label:'Preview',name:'preview'},
                {label:'Download',name:'download'},
                {label:'Email',name:'email'},
                {label:'Delete',name:'delete'}
            ]

    columns=[
        {label:'Title',fieldName:'Title',type:'text'},
        {label:'Id',fieldName:'Id',type:'text'},
        {
            type: 'action',
            typeAttributes: {
                rowActions: this.actions,
                menuAlignment: 'right'
            }
        },
        {
            fieldName: '',
            label: 'Dynamic Icon',
            cellAttributes: { iconName: { fieldName: 'dynamicIcon' } }
        }
    ]; 


    get acceptedFormats() {
        return ['.pdf', '.png','.jpg','.txt'];
    }

    handleUploadFinished(event) {
        oppAtta({di:this.currId}).then(res=>{
            console.log(res);
            this.data=JSON.parse(JSON.stringify(res));
            console.log(this.data);
                
            for(var i=0;i<this.data.length;i++)
            {
                console.log(this.data[i].FileExtension);
                
                this.data[i]['dynamicIcon']='doctype:'+this.data[i].FileExtension;
                console.log(this.data[i]);
            }
        }).catch(error=>{
            console.log(error);
        })
    }

    connectedCallback()
    {
        oppId().then(data=>{
            console.log(data);
            this.opptions=data;

        }).catch(error=>{console.log(error)})

    }    

   

    datatab(event)
    {
        this.currId=event.target.value;
        
        oppAtta({di:event.target.value}).then(res=>{

            this.data=JSON.parse(JSON.stringify(res));
            console.log(this.data);
                
            for(var i=0;i<this.data.length;i++)
            {
                console.log(this.data[i].FileExtension);
                
                this.data[i]['dynamicIcon']='doctype:'+this.data[i].FileExtension;
                console.log(this.data[i]);
            }
        }).catch(error=>{
            console.log(error);
        })

    }



    getfiles()
    {
        oppAtta({di:this.currId}).then(res=>{
            this.data=res;
            console.log(this.currId);

            // for(var i=0;i<this.data.length;i++)
            // {
            //     this.data[i]['dynamicIcon']='doctype:'+dat
            // }

            console.log(res);
            console.log(this.data);
        }).catch(error=>{
            console.log(error);
        })
    }






    sub()
    {
        file({base64:this.fileData.base64,filename:this.fileData.filename,parentid:this.fileData.parentid}).then(res=>{
            console.log(res);
            this.getfiles();
        }).catch(err=>{
            console.log(err);
        });
    }



    handleRowAction(event)
    {
        var nam=event.detail.action.name;
        var row=event.detail.row;
        switch ( nam ) {
            case 'preview':
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: row.Id,
                        actionName: 'view'
                    }
                });
                break;
            case 'delete':
                
                del({di:row.Id}).then(res=>{
                    console.log('Success');
                    
                    
                }).then(res=>{
                    console.log(this.currId);

                    this.getfiles();
                }).catch(err=>{
                    console.log(err);
                });


                break;
            case 'download':
                this[NavigationMixin.GenerateUrl]({
                    type: 'standard__webPage',
                    attributes: {
                        url: '/sfc/servlet.shepherd/document/download/' + row.Id
                    }
                }).then(generatedUrl => {
                    window.open(generatedUrl);
                });
                break;    
            case 'email':
                this.isModalOpen=true;
                this.eatta=row.Id;
                break;    
            default:
        }
    }


    closeModal()
    {
        this.isModalOpen=false;
        var t=this.template.querySelector('.to').value;
        console.log(t);
        mail({to:t,di:this.eatta}).then(res=>{
            console.log('send');
        });
    }
}