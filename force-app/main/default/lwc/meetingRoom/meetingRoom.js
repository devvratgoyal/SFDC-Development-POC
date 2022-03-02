import { LightningElement, track, api } from 'lwc';

export default class MeetingRoom extends LightningElement {
    @api meetingRoomInfo; //{roomName:'A-01',roomCapacity:12}
    @api showRoomInfo=false;

    get roomNameStr(){
        return `Meeting room name is ${this.meetingRoomInfo.roomName}`;
    }

    tileClickHandler(){
        const tileClicked = new CustomEvent('tileClick', {detail: this.meetingRoomInfo});
        this.dispatchEvent(tileClicked);
    }
}