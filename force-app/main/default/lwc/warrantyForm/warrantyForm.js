import { LightningElement } from 'lwc';
import saveClaim from '@salesforce/apex/WarrantyController.saveClaim';

export default class WarrantyForm extends LightningElement {
    recordId;

    vin;
    vehicleType;
    partName;
    description;
    dealerName;
    partOptions = [
    { label: 'Battery Pack', value: 'Battery Pack' },
    { label: 'Electric Motor', value: 'Electric Motor' },
    { label: 'Inverter', value: 'Inverter' },
    { label: 'Charging Port', value: 'Charging Port' },
    { label: 'DC-DC Converter', value: 'DC-DC Converter' },
    { label: 'Thermal Management System', value: 'Thermal Management System' },
    { label: 'Brake System', value: 'Brake System' },
    { label: 'Control Unit', value: 'Control Unit' },
    { label: 'Wiring Harness', value: 'Wiring Harness' },
    { label: 'Power Electronics Module', value: 'Power Electronics Module' }
      ];
    handleVin(e){ this.vin = e.target.value; }
    handleVehicleType(e){ this.vehicleType = e.target.value; }
    handlePartName(e){ this.partName = e.target.value; }
    handleDescription(e){ this.description = e.target.value; }
    handleDealerName(e){ this.dealerName = e.target.value; }

    handleSubmit(){
        saveClaim({
            vin: this.vin,
            vehicleType: this.vehicleType,
            partName: this.partName,
            description: this.description,
            dealerName: this.dealerName
        })
        .then(result => {
            this.recordId = result;
            alert("Now upload image");
        })
        .catch(error => {
            console.error(error);
            alert("Error submitting claim: " + JSON.stringify(error));
        });
    }
    handleUploadFinished(){
        const uploadedFiles = e.detail.files;
        alert(uploadedFiles.length + " file(s) uploaded successfully!");
    }
}